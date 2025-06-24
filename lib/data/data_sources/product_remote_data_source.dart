import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
import '../models/search_response_model.dart';

abstract class ProductDataSource {
  Future<SearchResponseModel> searchProducts({
    required String query,
    required bool aiEnabled,
    int limit = 50,
    int offset = 0,
  });
}

class ProductRemoteDataSource implements ProductDataSource {
  final Dio dio;
  final Logger logger;

  ProductRemoteDataSource({required this.dio, required this.logger});
  @override
  Future<SearchResponseModel> searchProducts({
    required String query,
    required bool aiEnabled,
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      if (kDebugMode) {
        logger.d(
          'Searching products: query="$query", ai=${aiEnabled ? 1 : 0}, limit=$limit, offset=$offset',
        );
        print(
          '🔍 Searching products: query="$query", ai=${aiEnabled ? 1 : 0}, limit=$limit, offset=$offset',
        );
      }

      final data = {
        'query': query,
        'ai': aiEnabled ? 1 : 0,
        'limit': limit,
        'offset': offset,
      };

      final response = await dio.post('/search', data: data);

      if (kDebugMode) {
        logger.d('API Response Status: ${response.statusCode}');
        logger.d('API Response Data: ${response.data}');
        print('📡 API Response Status: ${response.statusCode}');
        print('📦 API Response Data: ${response.data}');
      }

      if (response.statusCode == 200) {
        final searchResponse = SearchResponseModel.fromJson(response.data);

        if (kDebugMode) {
          logger.i(
            'Successfully parsed ${searchResponse.data?.total ?? 0} products',
          );
          print(
            '✅ Successfully parsed ${searchResponse.data?.total ?? 0} products',
          );
        }

        return searchResponse;
      } else {
        final errorMessage = 'HTTP Error: ${response.statusCode}';
        logger.e(errorMessage);
        if (kDebugMode) {
          print('❌ $errorMessage');
        }
        throw Exception(errorMessage);
      }
    } catch (e, stackTrace) {
      logger.e('Error searching products: $e');
      if (kDebugMode) {
        print('💥 Error searching products: $e');
        print('Stack trace: $stackTrace');
      }
      throw Exception('Failed to search products: $e');
    }
  }
}
