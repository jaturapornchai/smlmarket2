import 'package:flutter/material.dart';

import '../../data/models/product_model.dart';
import '../../utils/number_formatter.dart';
import '../screens/product_detail_screen.dart';

class ProductCard extends StatefulWidget {
  final ProductModel product;

  const ProductCard({super.key, required this.product});

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _fadeAnimation = Tween<double>(begin: 1.0, end: 0.8).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final finalPrice =
        widget.product.finalPrice ??
        widget.product.salePrice ??
        widget.product.price ??
        0.0;
    final qtyAvailable = widget.product.qtyAvailable ?? 0;

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: Card(
              margin: const EdgeInsets.all(8),
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: InkWell(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) =>
                          ProductDetailScreen(product: widget.product),
                    ),
                  );
                },
                onTapDown: (_) => _animationController.forward(),
                onTapUp: (_) => _animationController.reverse(),
                onTapCancel: () => _animationController.reverse(),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  height: 450, // เพิ่มความสูงเพื่อรองรับข้อมูลเพิ่มเติม
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.white,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Product Image
                      _buildProductImage(),

                      // Product Details - ใช้ flex ที่กำหนดเพื่อควบคุมพื้นที่
                      Expanded(
                        flex: 5,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Product Name (no line breaks) / ชื่อสินค้า (ไม่ตัดบรรทัด)
                              Text(
                                widget.product.name ?? 'ไม่มีชื่อสินค้า',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                  height: 1.2,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 8),

                              // Product code and unit name / รหัสสินค้า และชื่อหน่วย
                              Row(
                                children: [
                                  Expanded(
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.blue.shade50,
                                        borderRadius: BorderRadius.circular(6),
                                        border: Border.all(
                                          color: Colors.blue.shade200,
                                        ),
                                      ),
                                      child: Text(
                                        'รหัส: ${widget.product.code ?? 'N/A'}',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.blue.shade700,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.green.shade50,
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(
                                        color: Colors.green.shade200,
                                      ),
                                    ),
                                    child: Text(
                                      widget.product.unitStandardCode ?? 'N/A',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.green.shade700,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),

                              // Premium word / คำพิเศษ
                              if (widget.product.premiumWord != null &&
                                  widget.product.premiumWord!.isNotEmpty &&
                                  widget.product.premiumWord != 'N/A')
                                _buildPremiumWord(widget.product.premiumWord!),

                              // Discount information / ข้อมูลส่วนลด
                              if (widget.product.discountPrice != null &&
                                  widget.product.discountPrice! > 0)
                                _buildDiscountInfo(),

                              // Multi-packing information / ข้อมูลการบรรจุหลายชิ้น
                              if (widget.product.hasMultiplePacking)
                                _buildMultiPackingInfo(),

                              // Sold quantity / จำนวนที่ขายไปแล้ว
                              if (widget.product.soldQty != null &&
                                  widget.product.soldQty! > 0)
                                _buildSoldQuantityInfo(),

                              // Barcode (if available) / Barcode (ถ้ามี)
                              if (widget.product.barcodes != null &&
                                  widget.product.barcodes!.isNotEmpty &&
                                  widget.product.barcodes != 'N/A')
                                _buildBarcodeInfo(widget.product.barcodes!),

                              // Stock quantity (with comma separator) / ยอดคงเหลือ (ใส่ comma คั่นหลักพัน)
                              _buildStockInfo(qtyAvailable),

                              // Spacer เพื่อดันราคาไปด้านล่าง
                              const Spacer(),
                            ],
                          ),
                        ),
                      ),

                      // Price Section - อยู่ด้านล่างสุดของกล่องสินค้าเสมอ
                      Container(
                        padding: const EdgeInsets.all(12),
                        child: _buildPriceSection(finalPrice),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildProductImage() {
    final imageUrl =
        widget.product.imgUrl != null &&
            widget.product.imgUrl!.isNotEmpty &&
            widget.product.imgUrl != 'N/A'
        ? widget.product.imgUrl!
        : 'https://via.placeholder.com/200x150?text=No+Image';

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
      child: Container(
        height: 150,
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.grey.shade100, Colors.grey.shade200],
          ),
        ),
        child: Image.network(
          imageUrl,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: Colors.grey.shade100,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.image_not_supported,
                    size: 40,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'ไม่มีรูปภาพ',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                  ),
                ],
              ),
            );
          },
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Container(
              color: Colors.grey.shade50,
              child: Center(
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded /
                            (loadingProgress.expectedTotalBytes ?? 1)
                      : null,
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildStockInfo(double qtyAvailable) {
    final isAvailable = qtyAvailable > 0;
    final stockText = isAvailable
        ? 'คงเหลือ ${NumberFormatter.formatQuantity(qtyAvailable)}'
        : 'หมด';
    final stockColor = isAvailable ? Colors.green : Colors.red;
    final stockIcon = isAvailable ? Icons.check_circle : Icons.cancel;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: stockColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: stockColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(stockIcon, size: 14, color: stockColor),
          const SizedBox(width: 4),
          Text(
            stockText,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: stockColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceSection(double finalPrice) {
    // ถ้าราคาเป็น 0 ให้แสดงข้อความแทน
    if (finalPrice <= 0) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.grey.shade400, Colors.grey.shade600],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade700, width: 1),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.help_outline, color: Colors.white, size: 16),
            const SizedBox(width: 4),
            Text(
              'สอบถามราคา',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.orange.shade400, Colors.orange.shade600],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.orange.shade700, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withValues(alpha: 0.3),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end, // ชิดขวาตามคำแนะนำ
        children: [
          // Price (large, bold, orange color with border and shadow, comma separator, no .00)
          Text(
            NumberFormatter.formatCurrency(finalPrice),
            style: const TextStyle(
              fontSize: 20, // เพิ่มขนาดให้ใหญ่ขึ้น
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 8),
          Icon(
            Icons.local_offer,
            color: Colors.white.withValues(alpha: 0.8),
            size: 18, // เพิ่มขนาด icon ให้สัมพันธ์กับขนาดตัวอักษร
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumWord(String premiumWord) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.amber.shade50,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.amber.shade200),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.star, size: 12, color: Colors.amber.shade700),
          const SizedBox(width: 4),
          Text(
            premiumWord,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: Colors.amber.shade700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDiscountInfo() {
    final discountPrice = widget.product.discountPrice ?? 0;
    final discountPercent = widget.product.discountPercent ?? 0;
    final discountWord = widget.product.discountWord;

    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.local_offer, size: 12, color: Colors.red.shade700),
          const SizedBox(width: 4),
          Text(
            discountWord != null &&
                    discountWord.isNotEmpty &&
                    discountWord != 'N/A'
                ? discountWord
                : discountPercent > 0
                ? 'ลด ${NumberFormatter.formatPrice(discountPercent)}%'
                : 'ลด ฿${NumberFormatter.formatPrice(discountPrice)}',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: Colors.red.shade700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMultiPackingInfo() {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.indigo.shade50,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.indigo.shade200),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.inventory_2, size: 12, color: Colors.indigo.shade700),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              'แพ็ค: ${widget.product.packingOptions.join(", ")}',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: Colors.indigo.shade700,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSoldQuantityInfo() {
    final soldQty = widget.product.soldQty ?? 0;
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.teal.shade50,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.teal.shade200),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.trending_up, size: 12, color: Colors.teal.shade700),
          const SizedBox(width: 4),
          Text(
            'ขายแล้ว: ${NumberFormatter.formatQuantity(soldQty)}',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: Colors.teal.shade700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBarcodeInfo(String barcodes) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.purple.shade50,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.purple.shade200),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.qr_code, size: 12, color: Colors.purple.shade700),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              'Barcode: $barcodes',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: Colors.purple.shade700,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
