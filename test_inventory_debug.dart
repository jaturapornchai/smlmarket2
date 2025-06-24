import 'package:dio/dio.dart';

void main() async {
  final dio = Dio();
  dio.options.baseUrl = 'https://smlgoapi.dedepos.com/v1';

  try {
    // Test ic_inventory table structure
    print('Testing ic_inventory table...');
    final inventoryQuery = '''
      SELECT ic_code, qty_available 
      FROM ic_inventory 
      LIMIT 5
    ''';

    final inventoryResponse = await dio.post(
      '/pgselect',
      data: {'query': inventoryQuery},
    );
    print('Inventory response:');
    print('success: ${inventoryResponse.data['success']}');
    print('data: ${inventoryResponse.data['data']}');

    if (inventoryResponse.data['success'] == true) {
      print('Sample inventory data:');
      for (var item in inventoryResponse.data['data']) {
        print(
          '- ic_code: ${item['ic_code']}, qty_available: ${item['qty_available']}',
        );
      }
    }
  } catch (e) {
    print('Error: $e');
  }
}
