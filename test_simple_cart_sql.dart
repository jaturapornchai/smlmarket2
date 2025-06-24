import 'dart:convert';
import 'package:dio/dio.dart';

void main() async {
  final dio = Dio();
  dio.options.baseUrl = 'https://smlgoapi.dedepos.com/v1';
  dio.options.connectTimeout = const Duration(minutes: 2);
  dio.options.receiveTimeout = const Duration(minutes: 2);

  // ทดสอบการเชื่อมต่อก่อน
  try {
    print('🔍 Testing API connection...');

    final testResponse = await dio.post(
      '/pgselect',
      data: {'query': 'SELECT 1 as test'},
      options: Options(headers: {'Content-Type': 'application/json'}),
    );

    print('✅ API Connection Status: ${testResponse.statusCode}');
    print('📄 API Response: ${jsonEncode(testResponse.data)}');

    if (testResponse.statusCode == 200) {
      print('🎉 API connection successful!');

      // ตอนนี้ลอง run Cart SQL (เฉพาะ DROP TABLE ก่อน)
      print('\n🚀 Testing Cart system DROP commands...');

      final dropSql = '''
DROP TABLE IF EXISTS order_items CASCADE;
DROP TABLE IF EXISTS orders CASCADE;
DROP TABLE IF EXISTS cart_items CASCADE;
DROP TABLE IF EXISTS carts CASCADE;
SELECT 'Tables dropped successfully!' as result;
      ''';

      final dropResponse = await dio.post(
        '/pgcommand',
        data: {'query': dropSql},
        options: Options(headers: {'Content-Type': 'application/json'}),
      );

      print('✅ Drop Response Status: ${dropResponse.statusCode}');
      print('📄 Drop Response Data: ${jsonEncode(dropResponse.data)}');
    }
  } catch (e) {
    print('💥 Error: $e');
    if (e is DioException) {
      print('📄 Response: ${e.response?.data}');
      print('📊 Status Code: ${e.response?.statusCode}');
    }
  }
}
