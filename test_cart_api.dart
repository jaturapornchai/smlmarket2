import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  print('🔄 Testing Cart API with real endpoints...');
  
  const String baseUrl = 'https://smlgoapi.dedepos.com';
  
  try {
    // ทดสอบ checkAvailableQuantity
    await testCheckStock(baseUrl);
    
    // ทดสอบ createCart
    await testCreateCart(baseUrl);
    
    // ทดสอบ addToCart
    await testAddToCart(baseUrl);
    
  } catch (e) {
    print('❌ Error: $e');
  }
}

Future<void> testCheckStock(String baseUrl) async {
  print('\n📊 Testing checkAvailableQuantity...');
  
  const String query = '''
    WITH product_stock AS (
      SELECT qty_available 
      FROM products 
      WHERE id = 1
    ),
    cart_reserved AS (
      SELECT COALESCE(SUM(ci.quantity), 0) as cart_qty
      FROM cart_items ci
      INNER JOIN carts c ON ci.cart_id = c.id
      WHERE ci.product_id = 1
      AND c.status = 'active'
    ),
    order_reserved AS (
      SELECT COALESCE(SUM(oi.quantity), 0) as order_qty
      FROM order_items oi
      INNER JOIN orders o ON oi.order_id = o.id
      WHERE oi.product_id = 1
      AND o.status IN ('pending', 'confirmed', 'processing')
    )
    SELECT 
      ps.qty_available,
      cr.cart_qty,
      or_.order_qty,
      (ps.qty_available - cr.cart_qty - or_.order_qty) as available_qty
    FROM product_stock ps, cart_reserved cr, order_reserved or_
  ''';

  try {
    final response = await http.post(
      Uri.parse('$baseUrl/v1/pgselect'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'query': query}),
    );

    print('📡 Request to: $baseUrl/v1/pgselect');
    print('📊 Status Code: ${response.statusCode}');
    
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print('✅ Stock check success: ${data}');
      
      if (data['rows'] != null && data['rows'].isNotEmpty) {
        final row = data['rows'][0];
        print('📦 Available quantity: ${row['available_qty']}');
        print('🏪 Stock quantity: ${row['qty_available']}');
        print('🛒 Cart reserved: ${row['cart_qty']}');
        print('📋 Order reserved: ${row['order_qty']}');
      }
    } else {
      print('❌ Stock check failed: ${response.statusCode}');
      print('📄 Response: ${response.body}');
    }
  } catch (e) {
    print('❌ Stock check error: $e');
  }
}

Future<void> testCreateCart(String baseUrl) async {
  print('\n🛒 Testing createCart...');
  
  const String query = '''
    INSERT INTO carts (user_id, status, total_amount, total_items)
    VALUES (1, 'active', 0.00, 0)
    RETURNING *
  ''';

  try {
    final response = await http.post(
      Uri.parse('$baseUrl/v1/pgcommand'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'query': query}),
    );

    print('📡 Request to: $baseUrl/v1/pgcommand');
    print('📊 Status Code: ${response.statusCode}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print('✅ Create cart success: ${data}');
      
      if (data['rows'] != null && data['rows'].isNotEmpty) {
        final cartId = data['rows'][0]['id'];
        print('📝 Created cart ID: $cartId');
        
        // ทดสอบเพิ่มสินค้าเข้าตะกร้า
        await testAddToCartWithId(baseUrl, cartId);
      }
    } else {
      print('❌ Create cart failed: ${response.statusCode}');
      print('📄 Response: ${response.body}');
    }
  } catch (e) {
    print('❌ Create cart error: $e');
  }
}

Future<void> testAddToCart(String baseUrl) async {
  print('\n➕ Testing addToCart (finding existing cart)...');
  
  // หาตะกร้าที่ active อยู่
  const String findCartQuery = '''
    SELECT id FROM carts WHERE user_id = 1 AND status = 'active' LIMIT 1
  ''';

  try {
    final response = await http.post(
      Uri.parse('$baseUrl/v1/pgselect'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'query': findCartQuery}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['rows'] != null && data['rows'].isNotEmpty) {
        final cartId = data['rows'][0]['id'];
        print('📝 Found existing cart ID: $cartId');
        await testAddToCartWithId(baseUrl, cartId);
      } else {
        print('⚠️ No active cart found, creating new one...');
        await testCreateCart(baseUrl);
      }
    }
  } catch (e) {
    print('❌ Find cart error: $e');
  }
}

Future<void> testAddToCartWithId(String baseUrl, int cartId) async {
  print('\n📦 Testing addToCart with cart ID: $cartId...');
  
  const int productId = 1;
  const String barcode = '1234567890123';
  const String unitCode = 'PCS';
  const int quantity = 2;
  const double unitPrice = 199.99;
  final double totalPrice = quantity * unitPrice;
  
  final String query = '''
    WITH upsert AS (
      INSERT INTO cart_items (cart_id, product_id, barcode, unit_code, quantity, unit_price, total_price)
      VALUES ($cartId, $productId, '$barcode', '$unitCode', $quantity, $unitPrice, $totalPrice)
      ON CONFLICT (cart_id, product_id)
      DO UPDATE SET 
        quantity = cart_items.quantity + $quantity,
        total_price = (cart_items.quantity + $quantity) * cart_items.unit_price,
        updated_at = CURRENT_TIMESTAMP
      RETURNING *
    )
    SELECT * FROM upsert
  ''';

  try {
    final response = await http.post(
      Uri.parse('$baseUrl/v1/pgcommand'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'query': query}),
    );

    print('📡 Request to: $baseUrl/v1/pgcommand');
    print('📊 Status Code: ${response.statusCode}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print('✅ Add to cart success: ${data}');
      
      if (data['rows'] != null && data['rows'].isNotEmpty) {
        final item = data['rows'][0];
        print('📝 Cart Item Details:');
        print('   - Cart ID: ${item['cart_id']}');
        print('   - Product ID: ${item['product_id']}');
        print('   - Quantity: ${item['quantity']}');
        print('   - Unit Price: ${item['unit_price']}');
        print('   - Total Price: ${item['total_price']}');
        print('   - Barcode: ${item['barcode']}');
        print('   - Unit Code: ${item['unit_code']}');
      }
    } else {
      print('❌ Add to cart failed: ${response.statusCode}');
      print('📄 Response: ${response.body}');
    }
  } catch (e) {
    print('❌ Add to cart error: $e');
  }
}
