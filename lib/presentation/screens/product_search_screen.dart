import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/product_model.dart';
import '../../utils/number_formatter.dart';
import '../cubit/cart_cubit.dart';
import '../cubit/cart_state.dart';
import '../cubit/product_search_cubit.dart';
import '../cubit/product_search_state.dart';
import '../widgets/product_grid.dart';
import '../widgets/search_bar_widget.dart';
import 'cart_screen.dart';
import 'login_screen.dart';
import 'product_detail_screen.dart';

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
    // โหลดข้อมูลตระกร้าครั้งเดียวเมื่อเริ่มต้น
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<CartCubit>().loadCart(customerId: '1');
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
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ProductDetailScreen(product: product),
      ),
    );
  }

  void _onLoadMore() {
    context.read<ProductSearchCubit>().loadMoreProducts();
  }

  void _onCartTap() async {
    // นำทางไปยังตระกร้า (ไม่ต้องโหลดใหม่เพราะ CartScreen จะโหลดเอง)
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => const CartScreen()));
  }

  void _onLoginTap() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => const LoginScreen()));
  }

  /// สร้าง icon ตระกร้าพร้อมแสดงจำนวนสินค้า
  Widget _buildCartIcon(double itemCount) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        const Icon(Icons.shopping_cart, size: 24),
        if (itemCount > 0)
          Positioned(
            right: -6,
            top: -6,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 2,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              constraints: const BoxConstraints(minWidth: 20, minHeight: 20),
              child: Text(
                itemCount > 99
                    ? '99+'
                    : NumberFormatter.formatQuantity(itemCount),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
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
      appBar: AppBar(
        title: const Text(
          'SML Market',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        surfaceTintColor: Colors.white,
        actions: [
          // Cart Button with Badge
          BlocBuilder<CartCubit, CartState>(
            builder: (context, cartState) {
              double totalItemCount = 0.0;
              if (cartState is CartLoaded) {
                totalItemCount = cartState.totalItems;
              }

              return IconButton(
                onPressed: _onCartTap,
                icon: _buildCartIcon(totalItemCount),
                tooltip: 'ตระกร้าสินค้า',
              );
            },
          ),
          // Login Button
          IconButton(
            onPressed: _onLoginTap,
            icon: const Icon(Icons.login),
            tooltip: 'เข้าสู่ระบบ',
          ),
          const SizedBox(width: 8),
        ],
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
