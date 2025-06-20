import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logger/logger.dart';
import '../../data/repositories/product_repository.dart';
import 'product_search_state.dart';

class ProductSearchCubit extends Cubit<ProductSearchState> {
  final ProductRepository repository;
  final Logger logger;
  static const int _pageSize = 50;

  ProductSearchCubit({required this.repository, Logger? logger})
    : logger = logger ?? Logger(),
      super(ProductSearchInitial());

  Future<void> searchProducts({
    required String query,
    required bool aiEnabled,
  }) async {
    if (query.trim().isEmpty) {
      emit(ProductSearchInitial());
      return;
    }

    try {
      emit(ProductSearchLoading());

      if (kDebugMode) {
        logger.d('Cubit: Searching for "$query" with AI: $aiEnabled');
        print('🔄 Cubit: Searching for "$query" with AI: $aiEnabled');
      }

      final response = await repository.searchProducts(
        query: query,
        aiEnabled: aiEnabled,
        limit: _pageSize,
        offset: 0,
      );

      if (response.success && response.data != null) {
        final products = response.data!.products;

        if (products.isEmpty) {
          emit(ProductSearchEmpty(query: query));
          if (kDebugMode) {
            logger.i('No products found for query: "$query"');
            print('🔍 No products found for query: "$query"');
          }
        } else {
          final hasReachedMax = products.length < _pageSize;
          emit(
            ProductSearchSuccess(
              products: products,
              query: query,
              aiEnabled: aiEnabled,
              total: response.data!.total,
              hasReachedMax: hasReachedMax,
            ),
          );
          if (kDebugMode) {
            logger.i(
              'Found ${products.length} products for query: "$query", hasReachedMax: $hasReachedMax',
            );
            print(
              '✅ Found ${products.length} products for query: "$query", hasReachedMax: $hasReachedMax',
            );
          }
        }
      } else {
        final errorMessage = response.message ?? 'Unknown error occurred';
        emit(ProductSearchError(message: errorMessage, query: query));
        if (kDebugMode) {
          logger.w('API returned unsuccessful response: $errorMessage');
          print('⚠️ API returned unsuccessful response: $errorMessage');
        }
      }
    } catch (e) {
      logger.e('Error in ProductSearchCubit: $e');
      if (kDebugMode) {
        print('💥 Error in ProductSearchCubit: $e');
      }

      emit(
        ProductSearchError(
          message: 'ไม่สามารถค้นหาสินค้าได้: $e',
          query: query,
        ),
      );
    }
  }

  Future<void> loadMoreProducts() async {
    final currentState = state;

    // ตรวจสอบว่า state ปัจจุบันเป็น ProductSearchSuccess และยังไม่ถึงสุด
    if (currentState is! ProductSearchSuccess || currentState.hasReachedMax) {
      return;
    }

    try {
      // แสดงสถานะ loading more
      emit(
        ProductSearchLoadingMore(
          currentProducts: currentState.products,
          query: currentState.query,
          aiEnabled: currentState.aiEnabled,
        ),
      );

      if (kDebugMode) {
        logger.d(
          'Loading more products for "${currentState.query}", offset: ${currentState.products.length}',
        );
        print(
          '🔄 Loading more products for "${currentState.query}", offset: ${currentState.products.length}',
        );
      }

      final response = await repository.searchProducts(
        query: currentState.query,
        aiEnabled: currentState.aiEnabled,
        limit: _pageSize,
        offset: currentState.products.length,
      );

      if (response.success && response.data != null) {
        final newProducts = response.data!.products;
        final hasReachedMax = newProducts.length < _pageSize;

        // รวมสินค้าเก่าและใหม่
        final allProducts = [...currentState.products, ...newProducts];
        emit(
          ProductSearchSuccess(
            products: allProducts,
            query: currentState.query,
            aiEnabled: currentState.aiEnabled,
            total:
                currentState.total, // ใช้ total เดิมที่ได้จากการค้นหาครั้งแรก
            hasReachedMax: hasReachedMax,
          ),
        );

        if (kDebugMode) {
          logger.i(
            'Loaded ${newProducts.length} more products. Total: ${allProducts.length}, hasReachedMax: $hasReachedMax',
          );
          print(
            '✅ Loaded ${newProducts.length} more products. Total: ${allProducts.length}, hasReachedMax: $hasReachedMax',
          );
        }
      } else {
        // กลับไปสถานะเดิมหาก load more ไม่สำเร็จ
        emit(currentState);
        final errorMessage =
            response.message ?? 'ไม่สามารถโหลดข้อมูลเพิ่มเติมได้';
        if (kDebugMode) {
          logger.w('Failed to load more: $errorMessage');
          print('⚠️ Failed to load more: $errorMessage');
        }
      }
    } catch (e) {
      // กลับไปสถานะเดิมหาก error
      emit(currentState);
      logger.e('Error loading more products: $e');
      if (kDebugMode) {
        print('💥 Error loading more products: $e');
      }
    }
  }

  void clearSearch() {
    emit(ProductSearchInitial());
  }
}
