import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/product_model.dart';
import '../cubit/cart_cubit.dart';
import '../cubit/product_search_cubit.dart';
import '../cubit/product_search_state.dart';
import '../cubit/quotation_cubit.dart';
import '../widgets/app_navigation_bar.dart';
import '../widgets/product_grid.dart';
import '../widgets/search_bar_widget.dart';

class ProductSearchScreen extends StatefulWidget {
  const ProductSearchScreen({super.key});

  @override
  State<ProductSearchScreen> createState() => _ProductSearchScreenState();
}

class _ProductSearchScreenState extends State<ProductSearchScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // โหลดข้อมูลตระกร้าและใบเสนอราคาครั้งเดียวเมื่อเริ่มต้น
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<CartCubit>().loadCart(customerId: '1');
        context.read<QuotationCubit>().loadQuotations(1);
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearch(String query) {
    context.read<ProductSearchCubit>().searchProducts(
      query: query,
      aiEnabled: false, // ปิด AI ไว้ก่อน
    );
  }

  void _onAiToggle() {
    // ไม่ต้องทำอะไรในขั้นตอนนี้
  }

  void _onProductTap(ProductModel product) {
    Navigator.pushNamed(
      context,
      '/product/${product.code}',
      arguments: product,
    );
  }

  void _onLoadMore() {
    context.read<ProductSearchCubit>().loadMoreProducts();
  }

  Widget _buildSearchSummary(ProductSearchState state) {
    if (state is! ProductSearchSuccess &&
        state is! ProductSearchLoadingMore &&
        _searchController.text.isEmpty) {
      return const SizedBox.shrink();
    }

    String searchText = '';

    if (state is ProductSearchSuccess) {
      searchText = state.query;
    } else if (state is ProductSearchLoadingMore) {
      searchText = state.query;
    } else {
      searchText = _searchController.text;
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
                  ? (state.products.length < state.total
                        ? 'แสดง ${state.products.length} จาก ${state.total} รายการ สำหรับ "${state.query}"'
                        : 'พบ ${state.total} รายการ สำหรับ "${state.query}"')
                  : state is ProductSearchLoadingMore
                  ? 'แสดง ${state.currentProducts.length} รายการ สำหรับ "${state.query}" (กำลังโหลดเพิ่ม...)'
                  : 'ค้นหา "$searchText"',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          // แสดงสถานะ loading more
          if (state is ProductSearchLoadingMore)
            Container(
              margin: const EdgeInsets.only(left: 8),
              child: SizedBox(
                width: 12,
                height: 12,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Colors.blue.shade400,
                  ),
                ),
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
        } else if (state is ProductSearchError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64, color: Colors.red.shade400),
                const SizedBox(height: 16),
                Text(
                  'เกิดข้อผิดพลาด',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.red.shade600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  state.message,
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () {
                    if (_searchController.text.isNotEmpty) {
                      _onSearch(_searchController.text);
                    }
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('ลองใหม่'),
                ),
              ],
            ),
          );
        } else if (state is ProductSearchSuccess ||
            state is ProductSearchLoadingMore) {
          // สำหรับทั้ง success และ loading more
          final products = state is ProductSearchSuccess
              ? state.products
              : (state as ProductSearchLoadingMore).currentProducts;
          final hasReachedMax = state is ProductSearchSuccess
              ? state.hasReachedMax
              : false;
          final isLoadingMore = state is ProductSearchLoadingMore;

          if (products.isEmpty && !isLoadingMore) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.search_off, size: 64, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  Text(
                    'ไม่พบสินค้า',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'ลองใช้คำค้นหาอื่น',
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
                  ),
                ],
              ),
            );
          }

          return ProductGrid(
            products: products,
            isAiEnabled: state is ProductSearchSuccess
                ? state.aiEnabled
                : false,
            hasReachedMax: hasReachedMax,
            isLoadingMore: isLoadingMore,
            onProductTap: _onProductTap,
            onLoadMore: _onLoadMore,
          );
        } else {
          // Initial state - show welcome message
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.search, size: 64, color: Colors.blue.shade300),
                const SizedBox(height: 16),
                Text(
                  'ยินดีต้อนรับสู่ SML Market',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'ค้นหาสินค้าที่คุณต้องการ',
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                ),
              ],
            ),
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppNavigationBar(
        title: 'SML Market - ค้นหาสินค้า',
        showBackButton: false,
      ),
      body: Column(
        children: [
          // Search Section
          BlocBuilder<ProductSearchCubit, ProductSearchState>(
            builder: (context, state) {
              return SearchBarWidget(
                controller: _searchController,
                isAiEnabled: false, // ปิด AI ไว้ก่อน
                onSearch: _onSearch,
                onAiToggle: _onAiToggle,
              );
            },
          ),

          // Search Summary
          BlocBuilder<ProductSearchCubit, ProductSearchState>(
            builder: (context, state) {
              return _buildSearchSummary(state);
            },
          ),

          // Results Section
          Expanded(
            child: BlocBuilder<ProductSearchCubit, ProductSearchState>(
              builder: (context, state) {
                return _buildResultsSection(state);
              },
            ),
          ),
        ],
      ),
    );
  }
}
