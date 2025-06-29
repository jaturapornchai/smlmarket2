import 'package:flutter/material.dart';

import '../../data/models/product_model.dart';
import '../../utils/number_formatter.dart';

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

    final discountPrice = widget.product.discountPrice;
    final hasDiscount =
        discountPrice != null &&
        discountPrice > 0 &&
        discountPrice < finalPrice;
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
                onTap: qtyAvailable > 0
                    ? () {
                        Navigator.pushNamed(
                          context,
                          '/product-detail',
                          arguments: widget.product,
                        );
                      }
                    : null, // ถ้าสินค้าหมดจะกดไม่ได้
                onTapDown: qtyAvailable > 0
                    ? (_) => _animationController.forward()
                    : null,
                onTapUp: qtyAvailable > 0
                    ? (_) => _animationController.reverse()
                    : null,
                onTapCancel: qtyAvailable > 0
                    ? () => _animationController.reverse()
                    : null,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  height: 480, // เพิ่มความสูงเพื่อรองรับชื่อสินค้าแบบยาว
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.white,
                    // เพิ่มสีขอบแดงถ้าสินค้าหมด
                    border: qtyAvailable <= 0
                        ? Border.all(color: Colors.red.shade300, width: 2)
                        : null,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Product Image
                      _buildProductImage(),

                      // Product Details
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Product Name - แสดงเต็มไม่ตัดบรรทัด
                              Container(
                                width: double.infinity,
                                child: Text(
                                  widget.product.name ?? 'ไม่มีชื่อสินค้า',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                    height: 1.2,
                                  ),
                                  // ไม่จำกัดบรรทัด แสดงเต็ม
                                ),
                              ),
                              const SizedBox(height: 8),

                              // Product code and unit name
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

                              // Premium word
                              if (widget.product.premiumWord != null &&
                                  widget.product.premiumWord!.isNotEmpty &&
                                  widget.product.premiumWord != 'N/A')
                                _buildPremiumWord(widget.product.premiumWord!),

                              // Discount information
                              if (widget.product.discountPrice != null &&
                                  widget.product.discountPrice! > 0)
                                _buildDiscountInfo(),

                              // Multi-packing information
                              if (widget.product.hasMultiPackingName)
                                _buildMultiPackingInfo(),

                              // Sold quantity
                              if (widget.product.soldQty != null &&
                                  widget.product.soldQty! > 0)
                                _buildSoldQuantityInfo(),

                              // Barcode
                              if (widget.product.barcodes != null &&
                                  widget.product.barcodes!.isNotEmpty &&
                                  widget.product.barcodes != 'N/A')
                                _buildBarcodeInfo(widget.product.barcodes!),

                              // Stock quantity (ยอดคงเหลือ with comma separator)
                              _buildStockInfo(qtyAvailable),

                              // Spacer
                              const Spacer(),
                            ],
                          ),
                        ),
                      ),

                      // Price Section (large, bold, orange color with border and shadow, comma separator, no .00)
                      Container(
                        padding: const EdgeInsets.all(12),
                        child: _buildPriceSection(
                          finalPrice,
                          hasDiscount,
                          discountPrice,
                        ),
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
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildPriceSection(
    double finalPrice,
    bool hasDiscount,
    double? discountPrice,
  ) {
    final qtyAvailable = widget.product.qtyAvailable ?? 0;
    final hasPrice = finalPrice > 0;
    final hasStock = qtyAvailable > 0;

    // กรณีที่ 1: สินค้าหมด แต่มีราคา - แสดงราคาและบอกว่าสินค้าหมด
    if (!hasStock && hasPrice) {
      return Column(
        children: [
          // แสดงราคา (large, bold, orange color with border and shadow, comma separator, no .00)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.orange.shade400, Colors.orange.shade600],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.orange.shade700, width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.orange.withValues(alpha: 0.4),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // แสดงราคาเดิมถ้ามีส่วนลด
                if (hasDiscount &&
                    discountPrice != null &&
                    discountPrice < finalPrice) ...[
                  Text(
                    '฿${NumberFormatter.formatPrice(finalPrice)}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white70,
                      decoration: TextDecoration.lineThrough,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '฿${NumberFormatter.formatPrice(discountPrice)}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ] else
                  Text(
                    '฿${NumberFormatter.formatPrice(finalPrice)}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          // แสดงสถานะสินค้าหมด
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.red.shade600,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.red.shade700, width: 1),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.remove_shopping_cart, color: Colors.white, size: 16),
                const SizedBox(width: 4),
                Text(
                  'สินค้าหมด',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }

    // กรณีที่ 2: สินค้าหมด และไม่มีราคา - แสดงยังไม่กำหนดราคา
    if (!hasStock && !hasPrice) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.grey.shade600,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade700, width: 1),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.help_outline, color: Colors.white, size: 16),
            const SizedBox(width: 4),
            Text(
              'ยังไม่กำหนดราคา',
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

    // กรณีที่ 3: มียอดคงเหลือ แต่ไม่มีราคา - แสดงขอราคา
    if (hasStock && !hasPrice) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade400, Colors.blue.shade600],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.blue.shade700, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.blue.withValues(alpha: 0.3),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.contact_support, color: Colors.white, size: 16),
            const SizedBox(width: 4),
            Text(
              'ขอราคา',
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

    // กรณีที่ 4: มียอดคงเหลือ และมีราคา - แสดงราคาปกติ (large, bold, orange color with border and shadow, comma separator, no .00)
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
        border: Border.all(color: Colors.orange.shade700, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withValues(alpha: 0.4),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // แสดงราคาเดิมถ้ามีส่วนลด
          if (hasDiscount &&
              discountPrice != null &&
              discountPrice < finalPrice) ...[
            Text(
              '฿${NumberFormatter.formatPrice(finalPrice)}',
              style: TextStyle(
                fontSize: 14,
                color: Colors.white70,
                decoration: TextDecoration.lineThrough,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '฿${NumberFormatter.formatPrice(discountPrice)}',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ] else
            Text(
              '฿${NumberFormatter.formatPrice(finalPrice)}',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
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
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Colors.amber.shade800,
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
          if (discountPercent > 0)
            Text(
              'ลด ${discountPercent.toStringAsFixed(0)}%',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Colors.red.shade800,
              ),
            )
          else if (discountPrice > 0)
            Text(
              'ลด ${NumberFormatter.formatCurrency(discountPrice)}',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Colors.red.shade800,
              ),
            )
          else if (discountWord != null && discountWord.isNotEmpty)
            Text(
              discountWord,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Colors.red.shade800,
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
        color: Colors.purple.shade50,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.purple.shade200),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.inventory_2, size: 12, color: Colors.purple.shade700),
          const SizedBox(width: 4),
          Text(
            'แพ็ค: ${widget.product.packingOptions.join(", ")}',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Colors.purple.shade800,
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
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.trending_up, size: 12, color: Colors.green.shade700),
          const SizedBox(width: 4),
          Text(
            'ขายแล้ว: ${NumberFormatter.formatQuantity(soldQty)}',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Colors.green.shade800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBarcodeInfo(String barcodes) {
    final barcodeList = barcodes.split(',').map((e) => e.trim()).take(1);

    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.qr_code_2, size: 12, color: Colors.grey.shade700),
          const SizedBox(width: 4),
          Text(
            'บาร์โค้ด: ${barcodeList.first}',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStockInfo(double qtyAvailable) {
    Color bgColor;
    Color textColor;
    String text;
    IconData icon;

    if (qtyAvailable <= 0) {
      bgColor = Colors.red.shade100;
      textColor = Colors.red.shade700;
      text = 'สินค้าหมด';
      icon = Icons.remove_shopping_cart;
    } else if (qtyAvailable <= 5) {
      bgColor = Colors.orange.shade100;
      textColor = Colors.orange.shade700;
      text = 'เหลือน้อย (${NumberFormatter.formatQuantity(qtyAvailable)} ชิ้น)';
      icon = Icons.warning;
    } else {
      bgColor = Colors.green.shade100;
      textColor = Colors.green.shade700;
      text =
          'พร้อมจำหน่าย: ${NumberFormatter.formatQuantity(qtyAvailable)} ชิ้น';
      icon = Icons.check_circle;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: textColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: textColor),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}
