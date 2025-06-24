import 'package:dio/dio.dart';

void main() async {
  final dio = Dio();
  dio.options.baseUrl = 'https://smlgoapi.dedepos.com/v1';

  try {
    // Test search API
    print('Testing search API...');
    final searchResponse = await dio.post(
      '/search',
      data: {'keyword': 'ข้าว', 'page': 1, 'per_page': 3},
    );

    if (searchResponse.data['success'] == true &&
        searchResponse.data['data'] != null &&
        searchResponse.data['data'].isNotEmpty) {
      final firstProduct = searchResponse.data['data'][0];
      print('Product data from search API:');
      print('- id: ${firstProduct['id']}');
      print('- ic_code: ${firstProduct['ic_code']}');
      print('- qty_available: ${firstProduct['qty_available']}');
      print('- name: ${firstProduct['name']}');

      // Test stock check API
      final icCode = firstProduct['id'] ?? firstProduct['ic_code'];
      print('\nTesting stock check for ic_code: $icCode');

      final stockQuery =
          '''
        SELECT qty_available 
        FROM ic_inventory 
        WHERE ic_code = '$icCode'
        LIMIT 1
      ''';

      final stockResponse = await dio.post(
        '/pgselect',
        data: {'query': stockQuery},
      );
      print('Stock check response:');
      print('success: ${stockResponse.data['success']}');
      print('data: ${stockResponse.data['data']}');

      if (stockResponse.data['success'] == true &&
          stockResponse.data['data'] != null &&
          stockResponse.data['data'].isNotEmpty) {
        final stockQty = stockResponse.data['data'][0]['qty_available'];
        print('Stock quantity from ic_inventory: $stockQty');
        print('Product quantity from search: ${firstProduct['qty_available']}');
      } else {
        print('No stock data found in ic_inventory table');
      }
    }
  } catch (e) {
    print('Error: $e');
  }
}
