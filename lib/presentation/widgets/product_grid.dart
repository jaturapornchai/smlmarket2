import 'package:flutter/material.dart';
import '../../data/models/product_model.dart';
import 'product_card.dart';

class ProductGrid extends StatefulWidget {
  final List<ProductModel> products;
  final bool isAiEnabled;
  final bool hasReachedMax;
  final bool isLoadingMore;
  final Function(ProductModel)? onProductTap;
  final VoidCallback? onLoadMore;

  const ProductGrid({
    super.key,
    required this.products,
    required this.isAiEnabled,
    this.hasReachedMax = false,
    this.isLoadingMore = false,
    this.onProductTap,
    this.onLoadMore,
  });

  @override
  State<ProductGrid> createState() => _ProductGridState();
}

class _ProductGridState extends State<ProductGrid> {
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_isBottom && !widget.hasReachedMax && !widget.isLoadingMore) {
      widget.onLoadMore?.call();
    }
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll * 0.9); // Trigger when 90% scrolled
  }

  // Function to calculate optimal card width based on screen size
  double _calculateCardWidth(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final spacing = 1.0; // ลดช่องว่างระหว่าง card ลงเหลือ 1px

    // คำนวณจำนวนคอลัมน์โดยให้มีอย่างน้อย 2 คอลัมน์เสมอ
    int columnCount;
    if (screenWidth < 400) {
      columnCount = 2; // หน้าจอเล็กมาก ให้ 2 คอลัมน์
    } else if (screenWidth < 600) {
      columnCount = 2; // หน้าจอมือถือปกติ ให้ 2 คอลัมน์
    } else if (screenWidth < 800) {
      columnCount = 3; // หน้าจอกลาง ให้ 3 คอลัมน์
    } else if (screenWidth < 1000) {
      columnCount = 4; // หน้าจอใหญ่ ให้ 4 คอลัมน์
    } else {
      columnCount = 5; // หน้าจอใหญ่มาก ให้ 5 คอลัมน์
    }

    return (screenWidth - (spacing * (columnCount - 1))) / columnCount;
  }

  @override
  Widget build(BuildContext context) {
    final cardWidth = _calculateCardWidth(context);

    return SingleChildScrollView(
      controller: _scrollController,
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: [
          Wrap(
            spacing: 1, // ลดช่องว่างระหว่าง card แนวนอน
            runSpacing: 1, // ลดช่องว่างระหว่าง card แนวตั้ง
            alignment: WrapAlignment.start, // เริ่มจากซ้าย
            children: [
              // แสดง ProductCard ทั้งหมด
              ...widget.products.map(
                (product) => SizedBox(
                  width: cardWidth,
                  child: ProductCard(
                    product: product,
                    isAiEnabled: widget.isAiEnabled,
                  ),
                ),
              ),

              // Loading card ถ้ากำลังโหลด
              if (widget.isLoadingMore)
                SizedBox(width: cardWidth, child: _buildLoadingCard(context)),
            ],
          ), // แสดงข้อความเมื่อโหลดครบแล้ว
          if (widget.hasReachedMax && widget.products.isNotEmpty)
            Container(
              margin: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(
                child: Text(
                  'แสดงสินค้าครบทั้งหมดแล้ว (${widget.products.length} รายการ)',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLoadingCard(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(strokeWidth: 2),
            SizedBox(height: 12),
            Text(
              'กำลังโหลดข้อมูล...',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
