import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/ic_inventory_model.dart';
import '../models/ar_customer_model.dart';
import '../../utils/app_config.dart';

class PostgreSQLService {
  // ใช้ URL จาก AppConfig
  static String get baseUrl => AppConfig.postgresqlApiUrl;

  // Headers for API requests
  static const Map<String, String> headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  /// Execute SELECT query via /pgselect endpoint
  static Future<List<Map<String, dynamic>>> executeSelect(String query) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/pgselect'),
        headers: headers,
        body: jsonEncode({'query': query}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          return List<Map<String, dynamic>>.from(data['data'] ?? []);
        } else {
          throw Exception('Query failed: ${data['message']}');
        }
      } else {
        throw Exception('HTTP Error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('PostgreSQL Select Error: $e');
    }
  }

  /// Execute INSERT/UPDATE/DELETE via /pgcommand endpoint
  static Future<Map<String, dynamic>> executeCommand(String command) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/pgcommand'),
        headers: headers,
        body: jsonEncode({'query': command}), // ใช้ 'query' ไม่ใช่ 'command'
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          return data;
        } else {
          throw Exception('Command failed: ${data['message']}');
        }
      } else {
        throw Exception('HTTP Error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('PostgreSQL Command Error: $e');
    }
  }

  // === INVENTORY METHODS ===

  /// Get all inventory items
  static Future<List<IcInventoryModel>> getAllInventory() async {
    const query = '''
      SELECT code, name, unit_standard_code, item_type, row_order_ref, 
             price, sale_price, final_price, discount_price, discount_percent,
             qty_available, img_url, balance_qty, sold_qty, is_active,
             created_at, updated_at
      FROM ic_inventory 
      WHERE is_active = true
      ORDER BY name
    ''';

    final results = await executeSelect(query);
    return results.map((json) => IcInventoryModel.fromJson(json)).toList();
  }

  /// Get inventory by code
  static Future<IcInventoryModel?> getInventoryByCode(String code) async {
    final query =
        '''
      SELECT code, name, unit_standard_code, item_type, row_order_ref, 
             price, sale_price, final_price, discount_price, discount_percent,
             qty_available, img_url, balance_qty, sold_qty, is_active,
             created_at, updated_at
      FROM ic_inventory 
      WHERE code = '$code' AND is_active = true
    ''';

    final results = await executeSelect(query);
    if (results.isNotEmpty) {
      return IcInventoryModel.fromJson(results.first);
    }
    return null;
  }

  /// Search inventory items
  static Future<List<IcInventoryModel>> searchInventory(
    String searchTerm,
  ) async {
    final query =
        '''
      SELECT code, name, unit_standard_code, item_type, row_order_ref, 
             price, sale_price, final_price, discount_price, discount_percent,
             qty_available, img_url, balance_qty, sold_qty, is_active,
             created_at, updated_at
      FROM ic_inventory 
      WHERE is_active = true 
        AND (LOWER(name) LIKE '%${searchTerm.toLowerCase()}%' 
             OR LOWER(code) LIKE '%${searchTerm.toLowerCase()}%')
      ORDER BY name
      LIMIT 100
    ''';

    final results = await executeSelect(query);
    return results.map((json) => IcInventoryModel.fromJson(json)).toList();
  }

  // === CUSTOMER METHODS ===

  /// Get all customers
  static Future<List<ArCustomerModel>> getAllCustomers() async {
    const query = '''
      SELECT code, price_level, row_order_ref
      FROM ar_customer 
      ORDER BY code
    ''';

    final results = await executeSelect(query);
    return results.map((json) => ArCustomerModel.fromJson(json)).toList();
  }

  /// Get customer by code
  static Future<ArCustomerModel?> getCustomerByCode(String code) async {
    final query =
        '''
      SELECT code, price_level, row_order_ref
      FROM ar_customer 
      WHERE code = '$code'
    ''';

    final results = await executeSelect(query);
    if (results.isNotEmpty) {
      return ArCustomerModel.fromJson(results.first);
    }
    return null;
  }

  // === CART METHODS ===

  /// Get active cart for customer
  static Future<List<Map<String, dynamic>>> getActiveCart(
    String customerCode,
  ) async {
    final query =
        '''
      SELECT c.id, c.cart_uuid, c.customer_code, c.customer_name,
             c.status, c.total_items, c.total_amount, c.discount_amount,
             c.tax_amount, c.net_amount, c.notes, c.expires_at,
             c.created_at, c.updated_at
      FROM carts c
      WHERE c.customer_code = '$customerCode' AND c.status = 'active'
      ORDER BY c.created_at DESC
      LIMIT 1
    ''';

    return await executeSelect(query);
  }

  /// Get cart items
  static Future<List<Map<String, dynamic>>> getCartItems(int cartId) async {
    final query =
        '''
      SELECT ci.id, ci.cart_id, ci.ic_code, ci.ic_name, ci.unit_code,
             ci.quantity, ci.unit_price, ci.discount_percent, ci.discount_amount,
             ci.line_total, ci.notes, ci.created_at, ci.updated_at,
             ic.name as inventory_name, ic.img_url, ic.qty_available
      FROM cart_items ci
      LEFT JOIN ic_inventory ic ON ci.ic_code = ic.code
      WHERE ci.cart_id = $cartId
      ORDER BY ci.created_at
    ''';

    return await executeSelect(query);
  }

  // === QUOTATION METHODS ===

  /// Get quotations for customer
  static Future<List<Map<String, dynamic>>> getCustomerQuotations(
    String customerCode,
  ) async {
    final query =
        '''
      SELECT q.id, q.quotation_number, q.customer_code, q.customer_name,
             q.status, q.total_items, q.total_amount, q.discount_amount,
             q.tax_amount, q.net_amount, q.valid_until, q.notes,
             q.created_at, q.updated_at
      FROM quotations q
      WHERE q.customer_code = '$customerCode'
      ORDER BY q.created_at DESC
    ''';

    return await executeSelect(query);
  }

  // === ORDER METHODS ===

  /// Get orders for customer
  static Future<List<Map<String, dynamic>>> getCustomerOrders(
    String customerCode,
  ) async {
    final query =
        '''
      SELECT o.id, o.order_number, o.customer_code, o.customer_name,
             o.status, o.total_items, o.total_amount, o.discount_amount,
             o.tax_amount, o.net_amount, o.delivery_date, o.notes,
             o.created_at, o.updated_at
      FROM orders o
      WHERE o.customer_code = '$customerCode'
      ORDER BY o.created_at DESC
    ''';

    return await executeSelect(query);
  }

  // === CART OPERATIONS ===

  /// Add item to cart via PostgreSQL
  static Future<Map<String, dynamic>> addToCart({
    required int cartId,
    required String icCode,
    required String? barcode,
    required String? unitCode,
    required double quantity,
    required double unitPrice,
  }) async {
    final totalPrice = quantity * unitPrice;

    final command =
        '''
      INSERT INTO cart_items (cart_id, ic_code, barcode, unit_code, quantity, unit_price, total_price) 
      VALUES ($cartId, '$icCode', ${barcode != null ? "'$barcode'" : 'NULL'}, ${unitCode != null ? "'$unitCode'" : 'NULL'}, $quantity, $unitPrice, $totalPrice)
      ON CONFLICT (cart_id, ic_code, unit_code, unit_price) 
      DO UPDATE SET 
        quantity = cart_items.quantity + $quantity,
        total_price = (cart_items.quantity + $quantity) * cart_items.unit_price,
        updated_at = CURRENT_TIMESTAMP
      RETURNING id, cart_id, ic_code, barcode, unit_code, quantity, unit_price, total_price, created_at, updated_at
    ''';

    return await executeCommand(command);
  }

  /// Create new cart
  static Future<Map<String, dynamic>> createCart({
    required int customerId,
    String customerCode = '',
    String customerName = '',
  }) async {
    final command =
        '''
      INSERT INTO carts (customer_id, customer_code, customer_name, status, total_items, total_amount, discount_amount, tax_amount, net_amount)
      VALUES ($customerId, '$customerCode', '$customerName', 'active', 0, 0, 0, 0, 0)
      RETURNING id, cart_uuid, customer_id, customer_code, customer_name, status, total_items, total_amount, discount_amount, tax_amount, net_amount, created_at, updated_at
    ''';

    return await executeCommand(command);
  }

  /// Update cart totals
  static Future<void> updateCartTotals(int cartId) async {
    final command =
        '''
      UPDATE carts SET 
        total_items = (SELECT COALESCE(SUM(quantity), 0) FROM cart_items WHERE cart_id = $cartId),
        total_amount = (SELECT COALESCE(SUM(total_price), 0) FROM cart_items WHERE cart_id = $cartId),
        net_amount = (SELECT COALESCE(SUM(total_price), 0) FROM cart_items WHERE cart_id = $cartId),
        updated_at = CURRENT_TIMESTAMP
      WHERE id = $cartId
    ''';

    await executeCommand(command);
  }

  /// Check available quantity for an item
  static Future<double> checkAvailableQuantity(String icCode) async {
    final query =
        '''
      SELECT 
        COALESCE(ic.qty_available, 0) - COALESCE(cart_reserved.reserved_qty, 0) as available_qty
      FROM ic_inventory ic
      LEFT JOIN (
        SELECT 
          ci.ic_code,
          SUM(ci.quantity) as reserved_qty
        FROM cart_items ci
        JOIN carts c ON ci.cart_id = c.id
        WHERE c.status = 'active' AND ci.ic_code = '$icCode'
        GROUP BY ci.ic_code
      ) cart_reserved ON ic.code = cart_reserved.ic_code
      WHERE ic.code = '$icCode'
    ''';

    final results = await executeSelect(query);
    if (results.isNotEmpty) {
      final availableQty = results.first['available_qty'];
      return (availableQty is num) ? availableQty.toDouble() : 0.0;
    }
    return 0.0;
  }
}
