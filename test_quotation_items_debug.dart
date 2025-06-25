import 'dart:io';
import 'package:dio/dio.dart';

void main() async {
  final dio = Dio();
  dio.options.baseUrl = 'http://103.253.72.179:3000';
  dio.options.headers = {'Content-Type': 'application/json'};

  try {
    print('🔍 Testing quotation items debug...\n');

    // 1. ตรวจสอบตะกร้าที่มีข้อมูล
    print('1. Checking existing carts...');
    final cartQuery = '''
      SELECT c.id, c.customer_id, c.status, 
             COUNT(ci.id) as item_count,
             SUM(ci.quantity * ci.unit_price) as total_value
      FROM carts c
      LEFT JOIN cart_items ci ON c.id = ci.cart_id
      WHERE c.status = 'active'
      GROUP BY c.id
      ORDER BY c.created_at DESC
      LIMIT 5
    ''';

    final cartResponse = await dio.post(
      '/pgselect',
      data: {'query': cartQuery},
    );
    print('Cart response: ${cartResponse.data}');

    if (cartResponse.data['success'] && cartResponse.data['data'].isNotEmpty) {
      final carts = cartResponse.data['data'] as List;
      print('Found ${carts.length} active carts:');
      for (var cart in carts) {
        print(
          '  Cart ID: ${cart['id']}, Customer: ${cart['customer_id']}, Items: ${cart['item_count']}, Total: ${cart['total_value']}',
        );
      }

      // 2. เลือกตะกร้าแรกที่มีข้อมูลและดูรายการสินค้า
      final testCart = carts.first;
      final cartId = testCart['id'];

      print('\n2. Checking cart items for cart ID: $cartId');
      final cartItemsQuery =
          '''
        SELECT ci.*, p.product_name, p.product_name_thai 
        FROM cart_items ci
        LEFT JOIN products p ON ci.ic_code = p.ic_code
        WHERE ci.cart_id = $cartId
      ''';

      final itemsResponse = await dio.post(
        '/pgselect',
        data: {'query': cartItemsQuery},
      );
      print('Cart items response: ${itemsResponse.data}');

      if (itemsResponse.data['success'] &&
          itemsResponse.data['data'].isNotEmpty) {
        final items = itemsResponse.data['data'] as List;
        print('Found ${items.length} items in cart:');
        for (var item in items) {
          print(
            '  - ${item['ic_code']}: ${item['product_name_thai'] ?? item['product_name']} x${item['quantity']} @ ${item['unit_price']}',
          );
        }

        // 3. ตรวจสอบใบเสนอราคาที่สร้างจากตะกร้านี้
        print('\n3. Checking quotations from this cart...');
        final quotationQuery =
            '''
          SELECT q.*, COUNT(qi.id) as item_count
          FROM quotations q
          LEFT JOIN quotation_items qi ON q.id = qi.quotation_id
          WHERE q.cart_id = $cartId
          GROUP BY q.id
          ORDER BY q.created_at DESC
        ''';

        final quotationResponse = await dio.post(
          '/pgselect',
          data: {'query': quotationQuery},
        );
        print('Quotations response: ${quotationResponse.data}');

        if (quotationResponse.data['success'] &&
            quotationResponse.data['data'].isNotEmpty) {
          final quotations = quotationResponse.data['data'] as List;
          print('Found ${quotations.length} quotations from this cart:');
          for (var quotation in quotations) {
            print(
              '  Quotation ID: ${quotation['id']}, Items: ${quotation['item_count']}, Status: ${quotation['status']}',
            );

            // 4. ตรวจสอบรายการสินค้าในใบเสนอราคา
            final quotationId = quotation['id'];
            print(
              '\n4. Checking quotation items for quotation ID: $quotationId',
            );
            final quotationItemsQuery =
                '''
              SELECT qi.*, p.product_name, p.product_name_thai
              FROM quotation_items qi
              LEFT JOIN products p ON qi.ic_code = p.ic_code
              WHERE qi.quotation_id = $quotationId
            ''';

            final quotationItemsResponse = await dio.post(
              '/pgselect',
              data: {'query': quotationItemsQuery},
            );
            print('Quotation items response: ${quotationItemsResponse.data}');

            if (quotationItemsResponse.data['success'] &&
                quotationItemsResponse.data['data'].isNotEmpty) {
              final quotationItems =
                  quotationItemsResponse.data['data'] as List;
              print('Found ${quotationItems.length} items in quotation:');
              for (var item in quotationItems) {
                print(
                  '  - ${item['ic_code']}: ${item['product_name_thai'] ?? item['product_name']} x${item['requested_quantity']} @ ${item['requested_unit_price']}',
                );
              }
            } else {
              print('❌ No items found in quotation!');
            }
          }
        } else {
          print('No quotations found for this cart');
        }
      }
    } else {
      print('No active carts found');
    }
  } catch (e) {
    print('❌ Error: $e');
  }

  exit(0);
}
