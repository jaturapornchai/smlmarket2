import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/product_search_cubit.dart';
import '../cubit/product_search_state.dart';
import '../widgets/search_bar_widget.dart';
import '../widgets/product_grid.dart';
import '../../data/models/product_model.dart';
import 'product_detail_screen.dart';

class ProductSearchScreen extends StatefulWidget {
  const ProductSearchScreen({super.key});

  @override
  State<ProductSearchScreen> createState() => _ProductSearchScreenState();
}

class _ProductSearchScreenState extends State<ProductSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isAiEnabled = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearch(String query) {
    context.read<ProductSearchCubit>().searchProducts(
      query: query,
      aiEnabled: _isAiEnabled,
    );
  }

  void _onAiToggle() {
    setState(() {
      _isAiEnabled = !_isAiEnabled;
    });
  }

  void _onProductTap(ProductModel product) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ProductDetailScreen(product: product),
      ),
    );
  }

  void _onLoadMore() {
    context.read<ProductSearchCubit>().loadMoreProducts();
  }

  Widget _buildSearchSummary(ProductSearchState state) {
    if (state is! ProductSearchSuccess && _searchController.text.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        children: [
          Icon(Icons.search_outlined, size: 16, color: Colors.grey.shade600),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              state is ProductSearchSuccess
                  ? 'พบ ${state.total} รายการ สำหรับ "${state.query}"'
                  : 'ค้นหา "${_searchController.text}"',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          if (_isAiEnabled && state is ProductSearchSuccess)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.purple.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.psychology,
                    size: 12,
                    color: Colors.purple.shade600,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'AI',
                    style: TextStyle(
                      color: Colors.purple.shade600,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildResultsSection(ProductSearchState state) {
    return BlocBuilder<ProductSearchCubit, ProductSearchState>(
      builder: (context, state) {
        if (state is ProductSearchLoading) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('กำลังค้นหา...'),
              ],
            ),
          );
        }

        if (state is ProductSearchError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64, color: Colors.red.shade300),
                const SizedBox(height: 16),
                Text(
                  state.message,
                  style: const TextStyle(fontSize: 16, color: Colors.red),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => _onSearch(state.query ?? ''),
                  child: const Text('ลองใหม่'),
                ),
              ],
            ),
          );
        }

        if (state is ProductSearchEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.search_off, size: 64, color: Colors.grey.shade400),
                const SizedBox(height: 16),
                const Text(
                  'ไม่พบสินค้าที่ค้นหา',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
                const SizedBox(height: 8),
                const Text(
                  'ลองค้นหาด้วยคำอื่น',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
          );
        }
        if (state is ProductSearchSuccess ||
            state is ProductSearchLoadingMore) {
          final products = state is ProductSearchSuccess
              ? state.products
              : (state as ProductSearchLoadingMore).currentProducts;
          final isLoadingMore = state is ProductSearchLoadingMore;
          final hasReachedMax = state is ProductSearchSuccess
              ? state.hasReachedMax
              : false;
          final aiEnabled = state is ProductSearchSuccess
              ? state.aiEnabled
              : (state as ProductSearchLoadingMore).aiEnabled;

          return ProductGrid(
            products: products,
            isAiEnabled: aiEnabled,
            hasReachedMax: hasReachedMax,
            isLoadingMore: isLoadingMore,
            onProductTap: _onProductTap,
            onLoadMore: _onLoadMore,
          );
        }

        // ProductSearchInitial or any other state
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.shopping_bag_outlined,
                size: 80,
                color: Colors.blue.shade200,
              ),
              const SizedBox(height: 16),
              const Text(
                'เริ่มค้นหาสินค้า',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'พิมพ์ชื่อสินค้าที่คุณต้องการในช่องค้นหา',
                style: TextStyle(fontSize: 14, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Search Section
          BlocBuilder<ProductSearchCubit, ProductSearchState>(
            builder: (context, state) {
              return SearchBarWidget(
                controller: _searchController,
                isAiEnabled: _isAiEnabled,
                onSearch: _onSearch,
                onAiToggle: _onAiToggle,
                isLoading: state is ProductSearchLoading,
              );
            },
          ),

          // Search Results Summary
          BlocBuilder<ProductSearchCubit, ProductSearchState>(
            builder: (context, state) => _buildSearchSummary(state),
          ),

          // Results Section
          Expanded(
            child: BlocBuilder<ProductSearchCubit, ProductSearchState>(
              builder: (context, state) => _buildResultsSection(state),
            ),
          ),
        ],
      ),
    );
  }
}

class SearchResponseModel {
  final bool success;
  final String message;
  final List<ProductModel> products;
  final int totalCount;
  final String query;
  final double durationMs;

  SearchResponseModel({
    required this.success,
    required this.message,
    required this.products,
    required this.totalCount,
    required this.query,
    required this.durationMs,
  });

  factory SearchResponseModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? {};
    final productList = data['data'] as List<dynamic>? ?? [];

    return SearchResponseModel(
      success: json['success'] as bool? ?? false,
      message: json['message'] as String? ?? '',
      products: productList
          .map((item) => ProductModel.fromJson(item as Map<String, dynamic>))
          .toList(),
      totalCount: data['total_count'] as int? ?? productList.length,
      query: data['query'] as String? ?? '',
      durationMs: data['duration_ms'] as double? ?? 0.0,
    );
  }
}
