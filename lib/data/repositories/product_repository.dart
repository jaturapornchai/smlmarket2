import '../models/search_response_model.dart';
import '../data_sources/product_remote_data_source.dart';

abstract class ProductRepository {
  Future<SearchResponseModel> searchProducts({
    required String query,
    required bool aiEnabled,
    int limit = 50,
    int offset = 0,
  });
}

class ProductRepositoryImpl implements ProductRepository {
  final ProductDataSource remoteDataSource;

  ProductRepositoryImpl({required this.remoteDataSource});
  @override
  Future<SearchResponseModel> searchProducts({
    required String query,
    required bool aiEnabled,
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      return await remoteDataSource.searchProducts(
        query: query,
        aiEnabled: aiEnabled,
        limit: limit,
        offset: offset,
      );
    } catch (e) {
      // Repository ไม่ควรจัดการ error เอง ให้ pass ไปยัง layer ที่สูงกว่า
      rethrow;
    }
  }
}
