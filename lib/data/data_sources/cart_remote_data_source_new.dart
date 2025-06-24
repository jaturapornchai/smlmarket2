import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

import '../models/cart_item_model.dart';
import '../models/cart_model.dart';
import '../models/order_model.dart';

abstract class CartDataSource {
  Future<CartModel> getActiveCart({required int customerId});
  Future<CartModel> createCart({required int customerId});
  Future<CartItemModel> addToCart({
    required int cartId,
    required String icCode,
    required String? barcode,
    required String? unitCode,
    required int quantity,
    required double unitPrice,
  });
  Future<double> checkAvailableQuantity({required String icCode});
  Future<List<CartItemModel>> getCartItems({required int customerId});
  Future<void> updateCartItemQuantity({
    required int customerId,
    required String icCode,
    required int quantity,
  });
  Future<void> removeFromCart({
    required int customerId,
    required String icCode,
  });
  Future<void> clearCart({required int customerId});
  Future<OrderModel> createOrder({required int customerId});
}

class CartRemoteDataSource implements CartDataSource {
  final Dio dio;
  final Logger logger;

  CartRemoteDataSource({required this.dio, required this.logger});

  @override
  Future<CartModel> getActiveCart({required int customerId}) async {
    try {
      final query =
          """
        SELECT id, customer_id, status, total_amount, total_items, created_at, updated_at 
        FROM carts 
        WHERE customer_id = $customerId AND status = 'active'
        ORDER BY created_at DESC
        LIMIT 1
      """;

      final response = await dio.post('/pgselect', data: {'query': query});

      if (kDebugMode) {
        logger.d('🛒 [DATA_SOURCE] Get active cart response: ${response.data}');
      }

      if (response.data['success'] == true &&
          response.data['data'] != null &&
          response.data['data'].isNotEmpty) {
        return CartModel.fromJson(response.data['data'][0]);
      } else {
        // ถ้าไม่มีตระกร้า สร้างใหม่
        return await createCart(customerId: customerId);
      }
    } catch (e) {
      logger.e('⛔ Error getting active cart', error: e);
      if (kDebugMode) {
        debugPrint('💥 Error getting active cart: $e');
      }
      // ถ้า error ลองสร้างตระกร้าใหม่
      return await createCart(customerId: customerId);
    }
  }

  @override
  Future<CartModel> createCart({required int customerId}) async {
    try {
      final query =
          """
        INSERT INTO carts (customer_id, status, total_amount, total_items) 
        VALUES ($customerId, 'active', 0.00, 0)
        RETURNING id, customer_id, status, total_amount, total_items, created_at, updated_at
      """;

      final response = await dio.post('/pgcommand', data: {'query': query});

      if (kDebugMode) {
        logger.d('🛒 [DATA_SOURCE] Create cart response: ${response.data}');
      }

      if (response.data['success'] == true &&
          response.data['data'] != null &&
          response.data['data'].isNotEmpty) {
        return CartModel.fromJson(response.data['data'][0]);
      } else {
        throw Exception('Failed to create cart');
      }
    } catch (e) {
      logger.e('⛔ Error creating cart', error: e);
      if (kDebugMode) {
        debugPrint('💥 Error creating cart: $e');
      }
      throw Exception('Failed to create cart: $e');
    }
  }

  @override
  Future<CartItemModel> addToCart({
    required int cartId,
    required String icCode,
    required String? barcode,
    required String? unitCode,
    required int quantity,
    required double unitPrice,
  }) async {
    try {
      final totalPrice = quantity * unitPrice;

      // แทรกรายการใหม่หรืออัปเดตถ้ามีอยู่แล้ว
      final query =
          """
        INSERT INTO cart_items (cart_id, ic_code, barcode, unit_code, quantity, unit_price, total_price) 
        VALUES ($cartId, '$icCode', ${barcode != null ? "'$barcode'" : 'NULL'}, ${unitCode != null ? "'$unitCode'" : 'NULL'}, $quantity, $unitPrice, $totalPrice)
        ON CONFLICT (cart_id, ic_code, unit_code, unit_price) 
        DO UPDATE SET 
          quantity = cart_items.quantity + $quantity,
          total_price = (cart_items.quantity + $quantity) * cart_items.unit_price,
          updated_at = CURRENT_TIMESTAMP
        RETURNING id, cart_id, ic_code, barcode, unit_code, quantity, unit_price, total_price, created_at, updated_at
      """;

      final response = await dio.post('/pgcommand', data: {'query': query});

      if (kDebugMode) {
        logger.d('🛒 [DATA_SOURCE] Add to cart response: ${response.data}');
      }

      if (response.data['success'] == true &&
          response.data['data'] != null &&
          response.data['data'].isNotEmpty) {
        // อัปเดตยอดรวมในตระกร้า
        await _updateCartTotals(cartId);

        return CartItemModel.fromJson(response.data['data'][0]);
      } else {
        throw Exception('Failed to add item to cart');
      }
    } catch (e) {
      logger.e('⛔ Error adding to cart', error: e);
      if (kDebugMode) {
        debugPrint('💥 Error adding to cart: $e');
      }
      throw Exception('Failed to add item to cart: $e');
    }
  }

  @override
  Future<double> checkAvailableQuantity({required String icCode}) async {
    try {
      // ตรวจสอบจาก ic_inventory table
      final query =
          """
        SELECT qty_available 
        FROM ic_inventory 
        WHERE ic_code = '$icCode'
        LIMIT 1
      """;

      final response = await dio.post('/pgselect', data: {'query': query});

      if (response.data['success'] == true &&
          response.data['data'] != null &&
          response.data['data'].isNotEmpty) {
        return (response.data['data'][0]['qty_available'] ?? 0.0).toDouble();
      }

      return 0.0;
    } catch (e) {
      logger.e('⛔ Error checking available quantity', error: e);
      return 0.0;
    }
  }

  @override
  Future<List<CartItemModel>> getCartItems({required int customerId}) async {
    try {
      final query =
          """
        SELECT ci.id, ci.cart_id, ci.ic_code, ci.barcode, ci.unit_code, 
               ci.quantity, ci.unit_price, ci.total_price, ci.created_at, ci.updated_at
        FROM cart_items ci
        INNER JOIN carts c ON ci.cart_id = c.id
        WHERE c.customer_id = $customerId AND c.status = 'active'
        ORDER BY ci.created_at DESC
      """;

      final response = await dio.post('/pgselect', data: {'query': query});

      if (kDebugMode) {
        logger.d('🛒 [DATA_SOURCE] Get cart items response: ${response.data}');
      }

      if (response.data['success'] == true && response.data['data'] != null) {
        return (response.data['data'] as List)
            .map((item) => CartItemModel.fromJson(item))
            .toList();
      }

      return [];
    } catch (e) {
      logger.e('⛔ Error getting cart items', error: e);
      if (kDebugMode) {
        debugPrint('💥 Error getting cart items: $e');
      }
      return [];
    }
  }

  @override
  Future<void> updateCartItemQuantity({
    required int customerId,
    required String icCode,
    required int quantity,
  }) async {
    try {
      if (quantity <= 0) {
        await removeFromCart(customerId: customerId, icCode: icCode);
        return;
      }

      final query =
          """
        UPDATE cart_items 
        SET quantity = $quantity, 
            total_price = $quantity * unit_price,
            updated_at = CURRENT_TIMESTAMP
        WHERE cart_id IN (
          SELECT id FROM carts WHERE customer_id = $customerId AND status = 'active'
        ) AND ic_code = '$icCode'
      """;

      final response = await dio.post('/pgcommand', data: {'query': query});

      if (kDebugMode) {
        logger.d('🛒 [DATA_SOURCE] Update quantity response: ${response.data}');
      }

      // อัปเดตยอดรวมในตระกร้า
      final cart = await getActiveCart(customerId: customerId);
      await _updateCartTotals(cart.id!);
    } catch (e) {
      logger.e('⛔ Error updating cart item quantity', error: e);
      if (kDebugMode) {
        debugPrint('💥 Error updating cart item quantity: $e');
      }
      throw Exception('Failed to update item quantity: $e');
    }
  }

  @override
  Future<void> removeFromCart({
    required int customerId,
    required String icCode,
  }) async {
    try {
      final query =
          """
        DELETE FROM cart_items 
        WHERE cart_id IN (
          SELECT id FROM carts WHERE customer_id = $customerId AND status = 'active'
        ) AND ic_code = '$icCode'
      """;

      final response = await dio.post('/pgcommand', data: {'query': query});

      if (kDebugMode) {
        logger.d(
          '🛒 [DATA_SOURCE] Remove from cart response: ${response.data}',
        );
      }

      // อัปเดตยอดรวมในตระกร้า
      final cart = await getActiveCart(customerId: customerId);
      await _updateCartTotals(cart.id!);
    } catch (e) {
      logger.e('⛔ Error removing from cart', error: e);
      if (kDebugMode) {
        debugPrint('💥 Error removing from cart: $e');
      }
      throw Exception('Failed to remove item from cart: $e');
    }
  }

  @override
  Future<void> clearCart({required int customerId}) async {
    try {
      final query =
          """
        DELETE FROM cart_items 
        WHERE cart_id IN (
          SELECT id FROM carts WHERE customer_id = $customerId AND status = 'active'
        )
      """;

      final response = await dio.post('/pgcommand', data: {'query': query});

      if (kDebugMode) {
        logger.d('🛒 [DATA_SOURCE] Clear cart response: ${response.data}');
      }

      // อัปเดตยอดรวมในตระกร้า
      final cart = await getActiveCart(customerId: customerId);
      await _updateCartTotals(cart.id!);
    } catch (e) {
      logger.e('⛔ Error clearing cart', error: e);
      if (kDebugMode) {
        debugPrint('💥 Error clearing cart: $e');
      }
      throw Exception('Failed to clear cart: $e');
    }
  }

  @override
  Future<OrderModel> createOrder({required int customerId}) async {
    try {
      final cart = await getActiveCart(customerId: customerId);
      final cartItems = await getCartItems(customerId: customerId);

      if (cartItems.isEmpty) {
        throw Exception('Cart is empty');
      }

      // สร้างหมายเลขออเดอร์
      final orderNumber = 'ORD${DateTime.now().millisecondsSinceEpoch}';

      // สร้างออเดอร์
      final orderQuery =
          """
        INSERT INTO orders (cart_id, customer_id, order_number, total_amount, status, payment_status) 
        VALUES (${cart.id}, $customerId, '$orderNumber', ${cart.totalAmount}, 'pending', 'pending')
        RETURNING id, cart_id, customer_id, order_number, status, total_amount, shipping_address, 
                  payment_method, payment_status, notes, ordered_at
      """;

      final orderResponse = await dio.post(
        '/pgcommand',
        data: {'query': orderQuery},
      );

      if (orderResponse.data['success'] != true ||
          orderResponse.data['data'] == null ||
          orderResponse.data['data'].isEmpty) {
        throw Exception('Failed to create order');
      }

      final order = OrderModel.fromJson(orderResponse.data['data'][0]);

      // สร้างรายการสินค้าในออเดอร์
      for (var item in cartItems) {
        final itemQuery =
            """
          INSERT INTO order_items (order_id, ic_code, product_name, barcode, unit_code, quantity, unit_price, total_price)
          SELECT ${order.id}, '${item.icCode}', 
                 COALESCE(i.name, 'Unknown Product'), 
                 '${item.barcode ?? ''}', '${item.unitCode ?? ''}', 
                 ${item.quantity}, ${item.unitPrice}, ${item.totalPrice}
          FROM ic_inventory i 
          WHERE i.ic_code = '${item.icCode}'
        """;

        await dio.post('/pgcommand', data: {'query': itemQuery});
      }

      // อัปเดตสถานะตระกร้าเป็น completed
      final updateCartQuery =
          """
        UPDATE carts 
        SET status = 'completed', updated_at = CURRENT_TIMESTAMP
        WHERE id = ${cart.id}
      """;

      await dio.post('/pgcommand', data: {'query': updateCartQuery});

      if (kDebugMode) {
        logger.d('🛒 [DATA_SOURCE] Order created: ${order.orderNumber}');
      }

      return order;
    } catch (e) {
      logger.e('⛔ Error creating order', error: e);
      if (kDebugMode) {
        debugPrint('💥 Error creating order: $e');
      }
      throw Exception('Failed to create order: $e');
    }
  }

  /// อัปเดตยอดรวมและจำนวนรายการในตระกร้า
  Future<void> _updateCartTotals(int cartId) async {
    try {
      final query =
          """
        UPDATE carts 
        SET total_amount = (
          SELECT COALESCE(SUM(total_price), 0) 
          FROM cart_items 
          WHERE cart_id = $cartId
        ),
        total_items = (
          SELECT COALESCE(SUM(quantity), 0) 
          FROM cart_items 
          WHERE cart_id = $cartId
        ),
        updated_at = CURRENT_TIMESTAMP
        WHERE id = $cartId
      """;

      await dio.post('/pgcommand', data: {'query': query});

      if (kDebugMode) {
        logger.d('🛒 [DATA_SOURCE] Cart totals updated for cart: $cartId');
      }
    } catch (e) {
      logger.e('⛔ Error updating cart totals', error: e);
    }
  }
}
