import 'package:flutter/material.dart';

import '../../data/models/product_model.dart';
import '../screens/product_detail_screen.dart';

class ProductCard extends StatelessWidget {
  final ProductModel product;

  const ProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final finalPrice =
        product.finalPrice ?? product.salePrice ?? product.price ?? 0.0;
    final qtyAvailable = product.qtyAvailable ?? 0;

    return Card(
      margin: const EdgeInsets.all(8),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => ProductDetailScreen(product: product),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Colors.white,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product Image
              _buildProductImage(),

              // Product Details
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Product Name - ไม่ตัดบรรทัด
                      Text(
                        product.name ?? 'ไม่มีชื่อสินค้า',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                          height: 1.2,
                        ),
                        overflow: TextOverflow.visible,
                        softWrap: true,
                      ),
                      const SizedBox(height: 8),

                      // Product Code
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: Colors.blue.shade200),
                        ),
                        child: Text(
                          'รหัส: ${product.code ?? 'N/A'}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Colors.blue.shade700,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Stock Information
                      _buildStockInfo(qtyAvailable.toInt()),
                      const SizedBox(height: 12),

                      // Price - ราคาตัวใหญ่เข้มสีส้มมีกรอบและเงา
                      _buildPriceSection(finalPrice),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProductImage() {
    final imageUrl =
        product.imgUrl != null &&
            product.imgUrl!.isNotEmpty &&
            product.imgUrl != 'N/A'
        ? product.imgUrl!
        : 'https://via.placeholder.com/200x150/E0E0E0/666666?text=No+Image';

    return Container(
      height: 150,
      width: double.infinity,
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
        child: Image.network(
          imageUrl,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Container(
              color: Colors.grey[100],
              child: const Center(
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: Colors.grey[100],
              child: Icon(Icons.inventory, size: 40, color: Colors.grey[400]),
            );
          },
        ),
      ),
    );
  }

  Widget _buildStockInfo(int qtyAvailable) {
    Color bgColor;
    Color textColor;
    String text;
    IconData icon;

    if (qtyAvailable <= 0) {
      bgColor = Colors.red.shade100;
      textColor = Colors.red.shade700;
      text = 'หมด';
      icon = Icons.remove_shopping_cart;
    } else if (qtyAvailable <= 5) {
      bgColor = Colors.orange.shade100;
      textColor = Colors.orange.shade700;
      text = 'เหลือ $qtyAvailable';
      icon = Icons.warning;
    } else {
      bgColor = Colors.green.shade100;
      textColor = Colors.green.shade700;
      text = 'มี $qtyAvailable';
      icon = Icons.check_circle;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: textColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: textColor),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceSection(double finalPrice) {
    if (finalPrice <= 0) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.orange.shade50,
          border: Border.all(color: Colors.orange.shade300, width: 1.5),
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.orange.shade200,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          'สอบราคา',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.orange.shade700,
          ),
          textAlign: TextAlign.center,
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        border: Border.all(color: Colors.orange.shade300, width: 1.5),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.shade200,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        '฿${finalPrice.toStringAsFixed(0)}',
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.orange.shade700,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
