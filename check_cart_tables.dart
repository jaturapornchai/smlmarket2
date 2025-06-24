import 'dart:convert';
import 'package:dio/dio.dart';

void main() async {
  final dio = Dio();
  dio.options.baseUrl = 'https://smlgoapi.dedepos.com/v1';
  dio.options.connectTimeout = const Duration(seconds: 30);
  dio.options.receiveTimeout = const Duration(seconds: 30);

  try {
    print('🔍 Checking existing tables...');
    
    final checkTablesQuery = '''
SELECT table_name 
FROM information_schema.tables 
WHERE table_schema = 'public' 
AND table_name IN ('carts', 'cart_items', 'orders', 'order_items')
ORDER BY table_name;
    ''';

    final response = await dio.post(
      '/pgselect',
      data: {'query': checkTablesQuery},
      options: Options(headers: {'Content-Type': 'application/json'}),
    );

    print('✅ Response Status: ${response.statusCode}');
    print('📄 Response Data: ${jsonEncode(response.data)}');

    if (response.statusCode == 200 && response.data['success'] == true) {
      print('🎉 Query successful!');
      final tables = response.data['data'] as List;
      if (tables.isEmpty) {
        print('📋 No cart tables found - ready for creation');
      } else {
        print('📋 Found existing cart tables:');
        for (var table in tables) {
          print('  - ${table['table_name']}');
        }
      }
    }
  } catch (e) {
    print('💥 Error: $e');
    if (e is DioException) {
      print('📄 Response: ${e.response?.data}');
    }
  }
}
