import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
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
  final http.Client httpClient;
  final Logger logger;
  static const String baseUrl = 'http://localhost:8008';

  ProductRemoteDataSource({http.Client? httpClient, Logger? logger})
    : httpClient = httpClient ?? http.Client(),
      logger = logger ?? Logger();
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

      final uri = Uri.parse('$baseUrl/search');
      final body = json.encode({
        'query': query,
        'ai': aiEnabled ? 1 : 0,
        'limit': limit,
        'offset': offset,
      });

      final response = await httpClient.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      if (kDebugMode) {
        logger.d('API Response Status: ${response.statusCode}');
        logger.d('API Response Body: ${response.body}');
        print('📡 API Response Status: ${response.statusCode}');
        print('📦 API Response Body: ${response.body}');
      }

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        final searchResponse = SearchResponseModel.fromJson(jsonData);

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
