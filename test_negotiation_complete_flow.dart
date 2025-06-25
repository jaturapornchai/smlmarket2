import 'dart:io';
import 'package:dio/dio.dart';

void main() async {
  final dio = Dio();
  dio.options.baseUrl = 'http://103.253.72.179:3000';
  dio.options.headers = {'Content-Type': 'application/json'};

  try {
    print('🔍 Testing complete negotiation flow...\n');

    // ขั้นตอนที่ 1: สร้างตระกร้าและใบเสนอราคา
    print('1. Creating cart and quotation...');

    // สร้างตระกร้า
    final createCartQuery = '''
      INSERT INTO carts (customer_id, status, total_amount, total_items) 
      VALUES (1, 'active', 0.00, 0)
      RETURNING id
    ''';

    final cartResponse = await dio.post(
      '/pgcommand',
      data: {'query': createCartQuery},
    );
    final cartId = cartResponse.data['data'][0]['id'];
    print('✅ Created cart ID: $cartId');

    // เพิ่มสินค้าทดสอบ
    final addItemQuery =
        '''
      INSERT INTO cart_items (cart_id, ic_code, quantity, unit_price, total_price)
      VALUES ($cartId, 'TEST001', 10, 100.0, 1000.0)
    ''';
    await dio.post('/pgcommand', data: {'query': addItemQuery});

    // อัปเดตยอดตระกร้า
    final updateCartQuery =
        '''
      UPDATE carts 
      SET total_amount = 1000.0, total_items = 10
      WHERE id = $cartId
    ''';
    await dio.post('/pgcommand', data: {'query': updateCartQuery});

    // สร้างใบเสนอราคา
    final quotationNumber = 'QU-TEST-${DateTime.now().millisecondsSinceEpoch}';
    final createQuotationQuery =
        '''
      INSERT INTO quotations (
        cart_id, customer_id, quotation_number, status, 
        total_amount, total_items, original_total_amount, notes
      ) VALUES ($cartId, 1, '$quotationNumber', 'pending', 1000.0, 10, 1000.0, 'ทดสอบการต่อรอง')
      RETURNING id
    ''';

    final quotationResponse = await dio.post(
      '/pgcommand',
      data: {'query': createQuotationQuery},
    );
    final quotationId = quotationResponse.data['data'][0]['id'];
    print('✅ Created quotation ID: $quotationId');

    // สร้างรายการสินค้าในใบเสนอราคา
    final createItemQuery =
        '''
      INSERT INTO quotation_items (
        quotation_id, ic_code, original_quantity, original_unit_price, original_total_price,
        requested_quantity, requested_unit_price, requested_total_price, status
      ) VALUES ($quotationId, 'TEST001', 10, 100.0, 1000.0, 10, 100.0, 1000.0, 'active')
      RETURNING id
    ''';

    final itemResponse = await dio.post(
      '/pgcommand',
      data: {'query': createItemQuery},
    );
    final itemId = itemResponse.data['data'][0]['id'];
    print('✅ Created quotation item ID: $itemId');

    // ขั้นตอนที่ 2: ทดสอบการส่งข้อเสนอการต่อรอง
    print('\n2. Testing negotiation creation...');

    final createNegotiationQuery =
        '''
      INSERT INTO quotation_negotiations (
        quotation_id, quotation_item_id, negotiation_type, 
        from_role, to_role, proposed_quantity, proposed_unit_price,
        proposed_total_price, message
      ) VALUES ($quotationId, NULL, 'price', 'customer', 'seller', 
               NULL, 90.0, 900.0, 'ขอลดราคาเป็น 90 บาทต่อชิ้น')
      RETURNING id
    ''';

    final negotiationResponse = await dio.post(
      '/pgcommand',
      data: {'query': createNegotiationQuery},
    );
    print('Negotiation response: ${negotiationResponse.data}');

    if (negotiationResponse.data['success'] &&
        negotiationResponse.data['data'].isNotEmpty) {
      final negotiationId = negotiationResponse.data['data'][0]['id'];
      print('✅ Created negotiation ID: $negotiationId');

      // ขั้นตอนที่ 3: ตรวจสอบการบันทึกข้อมูล
      print('\n3. Verifying saved data...');

      final verifyQuery =
          '''
        SELECT qn.id, qn.quotation_id, qn.negotiation_type, qn.from_role, qn.to_role,
               qn.proposed_unit_price, qn.proposed_total_price, qn.message, qn.status,
               q.quotation_number, q.total_amount
        FROM quotation_negotiations qn
        JOIN quotations q ON qn.quotation_id = q.id
        WHERE qn.id = $negotiationId
      ''';

      final verifyResponse = await dio.post(
        '/pgselect',
        data: {'query': verifyQuery},
      );
      print('Verify response: ${verifyResponse.data}');

      if (verifyResponse.data['success'] &&
          verifyResponse.data['data'].isNotEmpty) {
        final result = verifyResponse.data['data'][0];
        print('🎉 SUCCESS! Negotiation saved correctly:');
        print('  Negotiation ID: ${result['id']}');
        print('  Quotation: ${result['quotation_number']}');
        print('  Type: ${result['negotiation_type']}');
        print('  From: ${result['from_role']} -> To: ${result['to_role']}');
        print('  Proposed Price: ${result['proposed_unit_price']}');
        print('  Proposed Total: ${result['proposed_total_price']}');
        print('  Message: ${result['message']}');
        print('  Status: ${result['status']}');

        // ขั้นตอนที่ 4: ทดสอบการดึงข้อมูลเพื่อแสดงในหน้าจอ
        print('\n4. Testing data retrieval for display...');

        final getQuotationQuery =
            '''
          SELECT q.*, COUNT(qn.id) as negotiation_count
          FROM quotations q
          LEFT JOIN quotation_negotiations qn ON q.id = qn.quotation_id
          WHERE q.id = $quotationId
          GROUP BY q.id
        ''';

        final quotationDataResponse = await dio.post(
          '/pgselect',
          data: {'query': getQuotationQuery},
        );
        print('Quotation data: ${quotationDataResponse.data}');

        final getItemsQuery =
            '''
          SELECT * FROM quotation_items WHERE quotation_id = $quotationId
        ''';

        final itemsDataResponse = await dio.post(
          '/pgselect',
          data: {'query': getItemsQuery},
        );
        print('Items data: ${itemsDataResponse.data}');

        final getNegotiationsQuery =
            '''
          SELECT * FROM quotation_negotiations WHERE quotation_id = $quotationId ORDER BY created_at DESC
        ''';

        final negotiationsDataResponse = await dio.post(
          '/pgselect',
          data: {'query': getNegotiationsQuery},
        );
        print('Negotiations data: ${negotiationsDataResponse.data}');

        if (quotationDataResponse.data['success'] &&
            itemsDataResponse.data['success'] &&
            negotiationsDataResponse.data['success']) {
          final quotationData = quotationDataResponse.data['data'][0];
          final itemsData = itemsDataResponse.data['data'] as List;
          final negotiationsData =
              negotiationsDataResponse.data['data'] as List;

          print('🎉 COMPLETE SUCCESS!');
          print('  Quotation loaded: ${quotationData['quotation_number']}');
          print('  Items count: ${itemsData.length}');
          print('  Negotiations count: ${negotiationsData.length}');
          print(
            '  Last negotiation: ${negotiationsData.isNotEmpty ? negotiationsData.first['message'] : 'None'}',
          );
        }
      }
    } else {
      print('❌ Failed to create negotiation');
    }
  } catch (e) {
    print('❌ Error: $e');
  }

  exit(0);
}
