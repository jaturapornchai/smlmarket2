import 'dart:io';
import 'package:dio/dio.dart';

void main() async {
  final dio = Dio();
  dio.options.baseUrl = 'http://103.253.72.179:3000';
  dio.options.headers = {'Content-Type': 'application/json'};

  try {
    print('🔍 Testing quotation creation from cart...\n');

    // 1. สร้างตระกร้าทดสอบ
    print('1. Creating test cart...');
    final createCartQuery = '''
      INSERT INTO carts (customer_id, status, total_amount, total_items) 
      VALUES (1, 'active', 0.00, 0)
      RETURNING id
    ''';

    final cartResponse = await dio.post(
      '/pgcommand',
      data: {'query': createCartQuery},
    );
    print('Cart response: ${cartResponse.data}');

    if (!cartResponse.data['success'] || cartResponse.data['data'].isEmpty) {
      throw Exception('Failed to create cart');
    }

    final cartId = cartResponse.data['data'][0]['id'];
    print('✅ Created cart with ID: $cartId');

    // 2. เพิ่มสินค้าทดสอบเข้าตระกร้า
    print('\n2. Adding test items to cart...');
    final testItems = [
      {'ic_code': 'TEST001', 'quantity': 5.0, 'unit_price': 100.0},
      {'ic_code': 'TEST002', 'quantity': 3.0, 'unit_price': 200.0},
    ];

    for (var item in testItems) {
      final quantity = item['quantity'] as double;
      final unitPrice = item['unit_price'] as double;
      final totalPrice = quantity * unitPrice;
      final addItemQuery =
          '''
        INSERT INTO cart_items (cart_id, ic_code, quantity, unit_price, total_price)
        VALUES ($cartId, '${item['ic_code']}', $quantity, $unitPrice, $totalPrice)
      ''';

      final itemResponse = await dio.post(
        '/pgcommand',
        data: {'query': addItemQuery},
      );
      print('Added item ${item['ic_code']}: ${itemResponse.data}');
    }

    // 3. อัปเดตยอดรวมตระกร้า
    final updateCartQuery =
        '''
      UPDATE carts 
      SET total_amount = (SELECT SUM(total_price) FROM cart_items WHERE cart_id = $cartId),
          total_items = (SELECT SUM(quantity) FROM cart_items WHERE cart_id = $cartId)
      WHERE id = $cartId
    ''';
    await dio.post('/pgcommand', data: {'query': updateCartQuery});

    // 4. สร้างใบเสนอราคาจากตระกร้า
    print('\n3. Creating quotation from cart...');
    final quotationNumber = 'QU-TEST-${DateTime.now().millisecondsSinceEpoch}';

    final createQuotationQuery =
        '''
      INSERT INTO quotations (
        cart_id, customer_id, quotation_number, status, 
        total_amount, total_items, original_total_amount, notes
      ) 
      SELECT $cartId, 1, '$quotationNumber', 'pending',
             c.total_amount, c.total_items, c.total_amount, 'สร้างจากตระกร้าทดสอบ'
      FROM carts c 
      WHERE c.id = $cartId
      RETURNING id
    ''';

    final quotationResponse = await dio.post(
      '/pgcommand',
      data: {'query': createQuotationQuery},
    );
    print('Quotation response: ${quotationResponse.data}');

    if (!quotationResponse.data['success'] ||
        quotationResponse.data['data'].isEmpty) {
      throw Exception('Failed to create quotation');
    }

    final quotationId = quotationResponse.data['data'][0]['id'];
    print('✅ Created quotation with ID: $quotationId');

    // 5. สร้างรายการสินค้าในใบเสนอราคา
    print('\n4. Creating quotation items...');
    final createItemsQuery =
        '''
      INSERT INTO quotation_items (
        quotation_id, ic_code, original_quantity, original_unit_price, original_total_price,
        requested_quantity, requested_unit_price, requested_total_price, status
      )
      SELECT $quotationId, ci.ic_code, ci.quantity, ci.unit_price, ci.total_price,
             ci.quantity, ci.unit_price, ci.total_price, 'active'
      FROM cart_items ci
      WHERE ci.cart_id = $cartId
      RETURNING id, ic_code, requested_quantity
    ''';

    final itemsResponse = await dio.post(
      '/pgcommand',
      data: {'query': createItemsQuery},
    );
    print('Items response: ${itemsResponse.data}');

    if (itemsResponse.data['success'] &&
        itemsResponse.data['data'].isNotEmpty) {
      final items = itemsResponse.data['data'] as List;
      print('✅ Created ${items.length} quotation items:');
      for (var item in items) {
        print(
          '  - Item ID: ${item['id']}, IC Code: ${item['ic_code']}, Qty: ${item['requested_quantity']}',
        );
      }
    }

    // 6. ตรวจสอบผลลัพธ์สุดท้าย
    print('\n5. Verifying final result...');
    final verifyQuery =
        '''
      SELECT q.id, q.quotation_number, q.total_amount, q.total_items,
             COUNT(qi.id) as item_count
      FROM quotations q
      LEFT JOIN quotation_items qi ON q.id = qi.quotation_id
      WHERE q.id = $quotationId
      GROUP BY q.id, q.quotation_number, q.total_amount, q.total_items
    ''';

    final verifyResponse = await dio.post(
      '/pgselect',
      data: {'query': verifyQuery},
    );
    print('Verify response: ${verifyResponse.data}');

    if (verifyResponse.data['success'] &&
        verifyResponse.data['data'].isNotEmpty) {
      final result = verifyResponse.data['data'][0];
      print('🎉 SUCCESS!');
      print('  Quotation ID: ${result['id']}');
      print('  Quotation Number: ${result['quotation_number']}');
      print('  Total Amount: ${result['total_amount']}');
      print('  Total Items: ${result['total_items']}');
      print('  Item Count: ${result['item_count']}');
    }

    print('\n✅ Test completed successfully!');
  } catch (e) {
    print('❌ Error: $e');
  }

  exit(0);
}
