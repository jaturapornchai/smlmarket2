import 'package:flutter/material.dart';
import '../../data/models/product_model.dart';
import '../screens/product_detail_screen.dart';

class ProductCard extends StatelessWidget {
  final ProductModel product;
  final bool isAiEnabled;

  const ProductCard({
    super.key,
    required this.product,
    required this.isAiEnabled,
  });

  String _getRandomImageUrl(String productId) {
    final List<String> imageUrls = [
      // Using Lorem Picsum with specific photo IDs
      'https://picsum.photos/id/1/400/400',
      'https://picsum.photos/id/2/400/400',
      'https://picsum.photos/id/3/400/400',
      'https://picsum.photos/id/4/400/400',
      'https://picsum.photos/id/5/400/400',

      // Using DummyImage.com as backup
      'https://dummyimage.com/400x400/4A90E2/FFFFFF&text=Product+1',
      'https://dummyimage.com/400x400/E74C3C/FFFFFF&text=Product+2',
      'https://dummyimage.com/400x400/2ECC71/FFFFFF&text=Product+3',
      'https://dummyimage.com/400x400/F39C12/FFFFFF&text=Product+4',
      'https://dummyimage.com/400x400/9B59B6/FFFFFF&text=Product+5',

      // Using Placeholder.com as additional backup
      'https://via.placeholder.com/400x400/FF6B6B/FFFFFF?text=Item+1',
      'https://via.placeholder.com/400x400/4ECDC4/FFFFFF?text=Item+2',
      'https://via.placeholder.com/400x400/45B7D1/FFFFFF?text=Item+3',
      'https://via.placeholder.com/400x400/96CEB4/FFFFFF?text=Item+4',
      'https://via.placeholder.com/400x400/FCEA2B/FFFFFF?text=Item+5',

      // More Picsum IDs
      'https://picsum.photos/id/10/400/400',
      'https://picsum.photos/id/11/400/400',
      'https://picsum.photos/id/12/400/400',
      'https://picsum.photos/id/13/400/400',
      'https://picsum.photos/id/14/400/400',
    ];

    final int index = productId.hashCode.abs() % imageUrls.length;
    return imageUrls[index];
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => ProductDetailScreen(product: product),
            ),
          );
        },
        borderRadius: BorderRadius.circular(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min, // ให้ Column ขยายตามเนื้อหา
          children: [
            // Product Image Section - ขนาดคงที่
            Container(
              height: 140, // ความสูงคงที่สำหรับรูป
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
                child: Image.network(
                  // Use original image if available, otherwise use random image
                  (product.imgUrl != null && product.imgUrl!.isNotEmpty)
                      ? product.imgUrl!
                      : _getRandomImageUrl(product.id ?? product.code ?? '0'),
                  fit: BoxFit.cover,
                  width: double.infinity,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      width: double.infinity,
                      color: Colors.grey.shade100,
                      child: Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                    loadingProgress.expectedTotalBytes!
                              : null,
                          strokeWidth: 2,
                        ),
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: double.infinity,
                      color: Colors.grey.shade100,
                      child: Icon(
                        Icons.inventory,
                        size: 48,
                        color: Colors.grey.shade400,
                      ),
                    );
                  },
                ),
              ),
            ),

            // Product Info Section - ไล่ข้อมูลลงมาตามเนื้อหา
            Container(
              padding: const EdgeInsets.all(4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [                  // Product Name - แสดงเต็มไม่ตัด
                  Text(
                    product.name ?? 'ไม่ระบุชื่อสินค้า',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                      height: 1.3,
                    ),
                  ),
                  // Product Code and Barcode
                  const SizedBox(height: 2),
                  Wrap(
                    spacing: 4,
                    runSpacing: 2,
                    children: [
                      // รหัสสินค้า
                      if (product.code != null && product.code!.isNotEmpty)
                        Text(
                          'รหัส: ${product.code}',
                          style: TextStyle(
                            fontSize: 8,
                            color: Colors.grey[600],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      // Barcode
                      if (product.barcodes != null && product.barcodes!.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 4,
                            vertical: 1,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.orange[100],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'BC: ${_getFirstBarcode(product.barcodes!)}',
                            style: TextStyle(
                              fontSize: 7,
                              color: Colors.orange[800],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Wrap(
                    children: [
                      if (product.premiumWord != null &&
                          product.premiumWord!.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.orange.shade100,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            product.premiumWord!,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.orange.shade700,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      if (_hasDiscountOrMultiPacking()) ...[
                        _buildDiscountAndInfoRow(),
                      ],
                    ],
                  ),
                  // ราคาปกติ - ย้ายลงมา
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      (product.hasPriceDiscrepancy)
                          ? Text(
                              product.salePrice != null &&
                                      product.salePrice! > 0
                                  ? 'ราคาปกติ: ฿${product.salePrice!.toStringAsFixed(0)}'
                                  : 'ราคาปกติ: ไม่พบราคา',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade500,
                                decoration: TextDecoration.lineThrough,
                                height: 1.0,
                              ),
                            )
                          : const SizedBox.shrink(),
                      Spacer(),
                      // Sales info
                      (product.hasSoldQty)
                          ? Text(
                              'ขายแล้ว ${product.soldQty!.toInt()}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.amber.shade700,
                                fontWeight: FontWeight.w500,
                              ),
                            )
                          : const SizedBox.shrink(),
                    ],
                  ),
                  if (product.similarityScore != null && isAiEnabled) ...[
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.psychology,
                          size: 8,
                          color: Colors.purple.shade600,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          'AI: ${product.similarityScore!.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 7,
                            color: Colors.purple.shade600,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        product.displayPrice > 0
                            ? '฿${product.displayPrice.toStringAsFixed(0)}'
                            : 'ไม่พบราคา',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: product.displayPrice > 0
                              ? (product.hasPriceDiscrepancy
                                    ? Colors.red.shade700
                                    : Colors.blue.shade700)
                              : Colors.grey.shade600,
                          fontSize: product.displayPrice > 0 ? 24 : 16,
                          height: 1.0,
                        ),
                      ),
                      Spacer(),
                      (product.availableQty > 0)
                          ? Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.green.shade100,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                'คงเหลือ ${product.availableQty.toInt()}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.green.shade700,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            )
                          : Container(
                              margin: const EdgeInsets.only(bottom: 6),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.red.shade100,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                'หมดสต็อก',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.red.shade700,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper method to check if there are discount or multi-packing details
  bool _hasDiscountOrMultiPacking() {
    return product.hasDiscountPrice ||
        product.hasDiscountPercent ||
        product.hasDiscountWord ||
        product.hasMultiPackingName;
  }

  // Helper method to build discount and info row
  Widget _buildDiscountAndInfoRow() {
    List<Widget> rowItems = [];

    // Show discount_price if not zero
    if (product.hasDiscountPrice) {
      rowItems.add(
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 1),
          decoration: BoxDecoration(
            color: Colors.red.shade100,
            borderRadius: BorderRadius.circular(3),
          ),
          child: Text(
            'ลด ฿${product.discountPrice!.toStringAsFixed(0)}',
            style: TextStyle(
              fontSize: 12,
              color: Colors.red.shade700,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      );
    }

    // Show discount_percent if not zero
    if (product.hasDiscountPercent) {
      rowItems.add(
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 1),
          decoration: BoxDecoration(
            color: Colors.orange.shade100,
            borderRadius: BorderRadius.circular(3),
          ),
          child: Text(
            '${product.discountPercent!.toStringAsFixed(0)}%',
            style: TextStyle(
              fontSize: 12,
              color: Colors.orange.shade700,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      );
    }

    // Show discount_word if not empty
    if (product.hasDiscountWord) {
      rowItems.add(
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 1),
          decoration: BoxDecoration(
            color: Colors.purple.shade100,
            borderRadius: BorderRadius.circular(3),
          ),
          child: Text(
            product.discountWord!,
            style: TextStyle(
              fontSize: 12,
              color: Colors.purple.shade700,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      );
    }

    // Show multi_packing_name if not empty
    if (product.hasMultiPackingName) {
      rowItems.add(
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 1),
          decoration: BoxDecoration(
            color: Colors.blue.shade100,
            borderRadius: BorderRadius.circular(3),
          ),
          child: Text(
            product.multiPackingName!,
            style: TextStyle(
              fontSize: 12,
              color: Colors.blue.shade700,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      );
    }

    if (rowItems.isEmpty) {
      return const SizedBox.shrink();
    }    return Wrap(spacing: 2, runSpacing: 1, children: rowItems);
  }

  // Helper method to get first barcode from comma-separated string
  String _getFirstBarcode(String barcodes) {
    if (barcodes.isEmpty) return '';
    final List<String> barcodeList = barcodes.split(',');
    return barcodeList.first.trim();
  }
}
