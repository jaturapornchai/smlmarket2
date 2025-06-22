import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import '../models/cart_model.dart';
import '../models/cart_item_model.dart';

abstract class CartDataSource {
  Future<CartModel> getActiveCart({required int userId});
  Future<CartModel> createCart({required int userId});
  Future<CartItemModel> addToCart({
    required int cartId,
    required int productId,
    required String? barcode,
    required String? unitCode,
    required int quantity,
    required double unitPrice,
  });
  Future<double> checkAvailableQuantity({required int productId});
}

class CartRemoteDataSource implements CartDataSource {
  final http.Client httpClient;
  final Logger logger;
  
  static const String baseUrl = kDebugMode
      ? 'https://smlgoapi.dedepos.com'
      : 'https://smlgoapi.dedepos.com';

  CartRemoteDataSource({http.Client? httpClient, Logger? logger})
      : httpClient = httpClient ?? http.Client(),
        logger = logger ?? Logger();

  @override
  Future<CartModel> getActiveCart({required int userId}) async {
    try {
      final query = '''
        SELECT * FROM carts 
        WHERE user_id = $userId AND status = 'active' 
        ORDER BY created_at DESC 
        LIMIT 1
      ''';

      final response = await httpClient.post(
        Uri.parse('$baseUrl/pgcommand'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'query': query}),
      );

      if (kDebugMode) {
        logger.d('Get active cart response: ${response.statusCode}');
        logger.d('Response body: ${response.body}');
      }

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['rows'] != null && data['rows'].isNotEmpty) {
          return CartModel.fromJson(data['rows'][0]);
        } else {
          throw Exception('No active cart found');
        }
      } else {
        throw Exception('Failed to get active cart: ${response.statusCode}');
      }
    } catch (e) {
      logger.e('Error getting active cart: $e');
      rethrow;
    }
  }

  @override
  Future<CartModel> createCart({required int userId}) async {
    try {
      final query = '''
        INSERT INTO carts (user_id, status, total_amount, total_items)
        VALUES ($userId, 'active', 0.00, 0)
        RETURNING *
      ''';

      final response = await httpClient.post(
        Uri.parse('$baseUrl/pgcommand'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'query': query}),
      );

      if (kDebugMode) {
        logger.d('Create cart response: ${response.statusCode}');
        logger.d('Response body: ${response.body}');
      }

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['rows'] != null && data['rows'].isNotEmpty) {
          return CartModel.fromJson(data['rows'][0]);
        } else {
          throw Exception('Failed to create cart');
        }
      } else {
        throw Exception('Failed to create cart: ${response.statusCode}');
      }
    } catch (e) {
      logger.e('Error creating cart: $e');
      rethrow;
    }
  }

  @override
  Future<double> checkAvailableQuantity({required int productId}) async {
    try {
      // ตรวจสอบจำนวนสินค้าในตระกร้าและคำสั่งซื้อ
      final query = '''
        WITH product_stock AS (
          SELECT qty_available 
          FROM products 
          WHERE id = $productId
        ),
        cart_reserved AS (
          SELECT COALESCE(SUM(ci.quantity), 0) as cart_qty
          FROM cart_items ci
          INNER JOIN carts c ON ci.cart_id = c.id
          WHERE ci.product_id = $productId 
          AND c.status = 'active'
        ),
        order_reserved AS (
          SELECT COALESCE(SUM(oi.quantity), 0) as order_qty
          FROM order_items oi
          INNER JOIN orders o ON oi.order_id = o.id
          WHERE oi.product_id = $productId 
          AND o.status IN ('pending', 'confirmed', 'processing')
        )
        SELECT 
          ps.qty_available,
          cr.cart_qty,
          or_.order_qty,
          (ps.qty_available - cr.cart_qty - or_.order_qty) as available_qty
        FROM product_stock ps, cart_reserved cr, order_reserved or_
      ''';

      final response = await httpClient.post(
        Uri.parse('$baseUrl/pgcommand'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'query': query}),
      );

      if (kDebugMode) {
        logger.d('Check quantity response: ${response.statusCode}');
        logger.d('Response body: ${response.body}');
      }

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['rows'] != null && data['rows'].isNotEmpty) {
          final row = data['rows'][0];
          return (row['available_qty'] ?? 0).toDouble();
        } else {
          return 0.0;
        }
      } else {
        throw Exception('Failed to check quantity: ${response.statusCode}');
      }
    } catch (e) {
      logger.e('Error checking quantity: $e');
      return 0.0;
    }
  }

  @override
  Future<CartItemModel> addToCart({
    required int cartId,
    required int productId,
    required String? barcode,
    required String? unitCode,
    required int quantity,
    required double unitPrice,
  }) async {
    try {
      final totalPrice = quantity * unitPrice;
      
      // ใช้ UPSERT เพื่อเพิ่มหรืออัพเดทสินค้าในตระกร้า
      final query = '''
        WITH upsert AS (
          INSERT INTO cart_items (cart_id, product_id, barcode, unit_code, quantity, unit_price, total_price)
          VALUES ($cartId, $productId, ${barcode != null ? "'$barcode'" : 'NULL'}, ${unitCode != null ? "'$unitCode'" : 'NULL'}, $quantity, $unitPrice, $totalPrice)
          ON CONFLICT (cart_id, product_id)
          DO UPDATE SET 
            quantity = cart_items.quantity + $quantity,
            total_price = (cart_items.quantity + $quantity) * cart_items.unit_price,
            updated_at = CURRENT_TIMESTAMP
          RETURNING *
        )
        SELECT * FROM upsert;
        
        -- อัพเดทยอดรวมในตระกร้า
        SELECT update_cart_totals($cartId);
      ''';

      final response = await httpClient.post(
        Uri.parse('$baseUrl/pgcommand'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'query': query}),
      );

      if (kDebugMode) {
        logger.d('Add to cart response: ${response.statusCode}');
        logger.d('Response body: ${response.body}');
      }

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['rows'] != null && data['rows'].isNotEmpty) {
          return CartItemModel.fromJson(data['rows'][0]);
        } else {
          throw Exception('Failed to add item to cart');
        }
      } else {
        throw Exception('Failed to add to cart: ${response.statusCode}');
      }
    } catch (e) {
      logger.e('Error adding to cart: $e');
      rethrow;
    }
  }
}
