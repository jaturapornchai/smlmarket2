import 'dart:io';
import 'package:dio/dio.dart';

void main() async {
  final dio = Dio();
  dio.options.baseUrl = 'http://103.253.72.179:3000';
  dio.options.headers = {'Content-Type': 'application/json'};

  try {
    print('🔍 Testing quotation items and negotiation fix...\n');

    // 1. ตรวจสอบตะกร้าที่มีอยู่
    print('1. Checking existing carts with items...');
    final cartQuery = '''
      SELECT c.id, c.customer_id, c.status, 
             COUNT(ci.id) as item_count,
             SUM(ci.total_price) as total_value
      FROM carts c
      LEFT JOIN cart_items ci ON c.id = ci.cart_id
      WHERE c.status = 'active' AND c.customer_id = 1
      GROUP BY c.id, c.customer_id, c.status
      HAVING COUNT(ci.id) > 0
      ORDER BY c.created_at DESC
      LIMIT 3
    ''';

    final cartResponse = await dio.post(
      '/pgselect',
      data: {'query': cartQuery},
    );

    if (cartResponse.data['success'] && cartResponse.data['data'].isNotEmpty) {
      final carts = cartResponse.data['data'] as List;
      print('Found ${carts.length} carts with items:');

      for (var cart in carts) {
        print(
          '  Cart ID: ${cart['id']}, Items: ${cart['item_count']}, Total: ฿${cart['total_value']}',
        );

        final cartId = cart['id'];

        // 2. ดูรายการสินค้าในตะกร้า
        final itemsQuery =
            '''
          SELECT ci.*, p.name as product_name, p.name_thai
          FROM cart_items ci
          LEFT JOIN ic_inventory p ON ci.ic_code = p.ic_code
          WHERE ci.cart_id = $cartId
        ''';

        final itemsResponse = await dio.post(
          '/pgselect',
          data: {'query': itemsQuery},
        );
        if (itemsResponse.data['success'] &&
            itemsResponse.data['data'].isNotEmpty) {
          final items = itemsResponse.data['data'] as List;
          print('    Cart items:');
          for (var item in items) {
            print(
              '    - ${item['ic_code']}: ${item['product_name'] ?? item['name_thai'] ?? 'Unknown'} x${item['quantity']} @ ฿${item['unit_price']}',
            );
          }

          // 3. สร้างใบเสนอราคาจากตะกร้านี้
          if (cartId == carts.first['id']) {
            // ใช้เฉพาะตะกร้าแรก
            print('\n2. Creating quotation from cart $cartId...');

            final quotationNumber =
                'QU-${DateTime.now().year}-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}';
            final createQuotationQuery =
                '''
              INSERT INTO quotations (
                cart_id, customer_id, quotation_number, status, 
                total_amount, total_items, original_total_amount, notes
              ) VALUES ($cartId, 1, '$quotationNumber', 'pending', 
                        ${cart['total_value']}, ${cart['item_count']}, ${cart['total_value']}, 
                        'สร้างจากระบบทดสอบ') 
              RETURNING id
            ''';

            final quotationResponse = await dio.post(
              '/pgcommand',
              data: {'query': createQuotationQuery},
            );

            if (quotationResponse.data['success'] &&
                quotationResponse.data['data'].isNotEmpty) {
              final quotationId = quotationResponse.data['data'][0]['id'];
              print('✅ Created quotation ID: $quotationId');

              // 4. สร้างรายการสินค้าในใบเสนอราคา
              print('3. Creating quotation items...');

              int itemCount = 0;
              for (var item in items) {
                final createItemQuery =
                    '''
                  INSERT INTO quotation_items (
                    quotation_id, ic_code, barcode, unit_code,
                    original_quantity, original_unit_price, original_total_price,
                    requested_quantity, requested_unit_price, requested_total_price,
                    status, item_notes
                  ) VALUES ($quotationId, '${item['ic_code']}', 
                            ${item['barcode'] != null ? "'${item['barcode']}'" : 'NULL'}, 
                            ${item['unit_code'] != null ? "'${item['unit_code']}'" : 'NULL'},
                            ${item['quantity']}, ${item['unit_price']}, ${item['total_price']},
                            ${item['quantity']}, ${item['unit_price']}, ${item['total_price']},
                            'active', 'สร้างจากตะกร้า')
                  RETURNING id
                ''';

                final itemResponse = await dio.post(
                  '/pgcommand',
                  data: {'query': createItemQuery},
                );
                if (itemResponse.data['success']) {
                  itemCount++;
                  print('  ✅ Created quotation item for ${item['ic_code']}');
                }
              }

              print('✅ Created $itemCount quotation items');

              // 5. ทดสอบการต่อรอง
              print('\n4. Testing negotiation creation...');

              final negotiationQuery =
                  '''
                INSERT INTO quotation_negotiations (
                  quotation_id, quotation_item_id, negotiation_type, 
                  from_role, to_role, proposed_quantity, proposed_unit_price,
                  proposed_total_price, message
                ) VALUES ($quotationId, NULL, 'note', 'customer', 'seller', 
                          NULL, NULL, NULL, 'ข้อความทดสอบการต่อรอง')
                RETURNING id
              ''';

              final negotiationResponse = await dio.post(
                '/pgcommand',
                data: {'query': negotiationQuery},
              );

              if (negotiationResponse.data['success'] &&
                  negotiationResponse.data['data'].isNotEmpty) {
                final negotiationId = negotiationResponse.data['data'][0]['id'];
                print('✅ Created negotiation ID: $negotiationId');

                // 6. ตรวจสอบข้อมูลที่สร้างแล้ว
                print('\n5. Verifying created data...');

                final verifyQuery =
                    '''
                  SELECT q.id, q.quotation_number, q.status,
                         COUNT(qi.id) as item_count,
                         COUNT(qn.id) as negotiation_count
                  FROM quotations q
                  LEFT JOIN quotation_items qi ON q.id = qi.quotation_id
                  LEFT JOIN quotation_negotiations qn ON q.id = qn.quotation_id
                  WHERE q.id = $quotationId
                  GROUP BY q.id, q.quotation_number, q.status
                ''';

                final verifyResponse = await dio.post(
                  '/pgselect',
                  data: {'query': verifyQuery},
                );

                if (verifyResponse.data['success'] &&
                    verifyResponse.data['data'].isNotEmpty) {
                  final result = verifyResponse.data['data'][0];
                  print('✅ Quotation verification:');
                  print('  - ID: ${result['id']}');
                  print('  - Number: ${result['quotation_number']}');
                  print('  - Status: ${result['status']}');
                  print('  - Items: ${result['item_count']}');
                  print('  - Negotiations: ${result['negotiation_count']}');

                  if (result['item_count'] > 0 &&
                      result['negotiation_count'] > 0) {
                    print(
                      '\n🎉 SUCCESS: Both quotation items and negotiation work correctly!',
                    );
                  } else {
                    print('\n❌ ISSUE: Missing items or negotiations');
                  }
                } else {
                  print('❌ Failed to verify quotation data');
                }
              } else {
                print('❌ Failed to create negotiation');
              }
            } else {
              print('❌ Failed to create quotation');
            }
            break; // ใช้เฉพาะตะกร้าแรก
          }
        }
      }
    } else {
      print('❌ No active carts with items found for customer 1');

      // สร้างข้อมูลทดสอบ
      print('\n📝 Creating test data...');

      // สร้างตะกร้าทดสอบ
      final createCartQuery = '''
        INSERT INTO carts (customer_id, status, total_amount, total_items) 
        VALUES (1, 'active', 1500.0, 2)
        RETURNING id
      ''';

      final newCartResponse = await dio.post(
        '/pgcommand',
        data: {'query': createCartQuery},
      );
      if (newCartResponse.data['success'] &&
          newCartResponse.data['data'].isNotEmpty) {
        final newCartId = newCartResponse.data['data'][0]['id'];
        print('✅ Created test cart ID: $newCartId');

        // เพิ่มสินค้าทดสอบ
        final testItems = [
          {
            'ic_code': 'TEST001',
            'quantity': 10,
            'unit_price': 100.0,
            'total_price': 1000.0,
          },
          {
            'ic_code': 'TEST002',
            'quantity': 5,
            'unit_price': 100.0,
            'total_price': 500.0,
          },
        ];

        for (var item in testItems) {
          final addItemQuery =
              '''
            INSERT INTO cart_items (cart_id, ic_code, quantity, unit_price, total_price)
            VALUES ($newCartId, '${item['ic_code']}', ${item['quantity']}, ${item['unit_price']}, ${item['total_price']})
          ''';
          await dio.post('/pgcommand', data: {'query': addItemQuery});
          print('  ✅ Added test item: ${item['ic_code']}');
        }

        print('✅ Test cart created with items. Please run the script again.');
      }
    }
  } catch (e) {
    print('❌ Error: $e');
    if (e is DioException) {
      print('Response: ${e.response?.data}');
    }
  }

  exit(0);
}
