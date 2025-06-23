import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/product_model.dart';
import '../cubit/cart_cubit.dart';
import '../cubit/cart_state.dart';

class ProductDetailScreen extends StatefulWidget {
  final ProductModel product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int quantity = 1;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CartCubit>().loadCart(customerId: '1');
    });
  }

  void _addToCart() async {
    try {
      final cartCubit = context.read<CartCubit>();
      final icCode = widget.product.id ?? '';

      if (icCode.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('รหัสสินค้าไม่ถูกต้อง'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 2),
          ),
        );
        return;
      }

      await cartCubit.addToCart(
        product: widget.product,
        quantity: quantity,
        userId: 1,
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error in _addToCart: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CartCubit, CartState>(
      listener: (context, state) {
        if (state is CartLoading) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Row(
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                  SizedBox(width: 16),
                  Text('กำลังเพิ่มเข้าตะกร้า...'),
                ],
              ),
              duration: Duration(seconds: 3),
            ),
          );
        } else if (state is CartSuccess) {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'เพิ่ม ${widget.product.name} เข้าตะกร้าแล้ว (จำนวน: $quantity)',
              ),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
            ),
          );

          context.read<CartCubit>().loadCart(customerId: '1');

          Future.delayed(const Duration(milliseconds: 500), () {
            if (mounted && context.mounted) {
              Navigator.of(context).pop();
            }
          });
        } else if (state is CartError) {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            widget.product.name ?? 'รายละเอียดสินค้า',
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
          ),
          backgroundColor: Colors.blue[600],
          foregroundColor: Colors.white,
          elevation: 2,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Product Image
                      _buildProductImage(),
                      const SizedBox(height: 16),

                      // Product Name
                      Text(
                        widget.product.name ?? 'ไม่มีชื่อสินค้า',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[700],
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Product Code
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.blue.shade200),
                        ),
                        child: Text(
                          'รหัสสินค้า: ${widget.product.code ?? 'N/A'}',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.blue.shade700,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Stock Status
                      _buildStockStatus(),
                      const SizedBox(height: 16),

                      // Price Section - ราคาตัวใหญ่เข้มสีส้มมีกรอบและเงา
                      _buildPriceSection(),
                      const SizedBox(height: 24),

                      // Cart Status Check
                      _buildCartStatusSection(),
                    ],
                  ),
                ),
              ),

              // Back Button
              Container(
                padding: const EdgeInsets.all(16),
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[600],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.arrow_back, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'กลับไปหน้าจอค้นหา',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
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
        widget.product.imgUrl != null &&
            widget.product.imgUrl!.isNotEmpty &&
            widget.product.imgUrl != 'N/A'
        ? widget.product.imgUrl!
        : 'https://via.placeholder.com/400x400/E0E0E0/666666?text=No+Image';

    return Container(
      height: 300,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade300,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.network(
          imageUrl,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Container(
              color: Colors.grey[100],
              child: const Center(child: CircularProgressIndicator()),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: Colors.grey[100],
              child: Icon(Icons.inventory, size: 80, color: Colors.grey[400]),
            );
          },
        ),
      ),
    );
  }

  Widget _buildStockStatus() {
    final qtyAvailable = widget.product.qtyAvailable ?? 0;

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
      text = 'เหลือน้อย ($qtyAvailable ชิ้น)';
      icon = Icons.warning;
    } else {
      bgColor = Colors.green.shade100;
      textColor = Colors.green.shade700;
      text = 'มีสินค้า ($qtyAvailable ชิ้น)';
      icon = Icons.check_circle;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: textColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: textColor),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceSection() {
    final finalPrice =
        widget.product.finalPrice ??
        widget.product.salePrice ??
        widget.product.price ??
        0.0;
    final originalPrice = widget.product.price ?? 0.0;
    final hasDiscount =
        (widget.product.discountPrice != null &&
            widget.product.discountPrice! > 0) ||
        (widget.product.discountPercent != null &&
            widget.product.discountPercent! > 0);

    if (finalPrice <= 0) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.orange.shade50,
          border: Border.all(color: Colors.orange.shade300, width: 2),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.orange.shade200,
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Text(
          'ติดต่อสอบถามราคา',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.orange.shade700,
          ),
          textAlign: TextAlign.center,
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'ราคา',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 8),

        // Final Price with Orange Style, Border and Shadow
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.orange.shade50,
            border: Border.all(color: Colors.orange.shade300, width: 2),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.orange.shade200,
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Text(
            '฿${finalPrice.toStringAsFixed(0)}',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.orange.shade700,
            ),
          ),
        ),

        // Original Price (if different)
        if (hasDiscount && originalPrice > finalPrice) ...[
          const SizedBox(height: 8),
          Text(
            'ราคาเดิม: ฿${originalPrice.toStringAsFixed(0)}',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade500,
              decoration: TextDecoration.lineThrough,
            ),
          ),
        ],

        // Discount Info
        if (widget.product.discountPercent != null &&
            widget.product.discountPercent! > 0) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.red.shade100,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              'ลด ${widget.product.discountPercent!.toStringAsFixed(0)}%',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.red.shade700,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildCartStatusSection() {
    return BlocBuilder<CartCubit, CartState>(
      builder: (context, state) {
        final icCode = widget.product.id ?? '';
        if (icCode.isEmpty) return const SizedBox.shrink();

        final cartCubit = context.read<CartCubit>();
        final isInCart = cartCubit.isProductInCart(icCode);
        final quantityInCart = cartCubit.getProductQuantityInCart(icCode);
        final canAddToCart = (widget.product.qtyAvailable ?? 0) > 0;

        if (isInCart) {
          // สินค้าอยู่ในตะกร้าแล้ว - แสดงข้อความ
          return Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              border: Border.all(color: Colors.green.shade300),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.check_circle_outline,
                  size: 48,
                  color: Colors.green.shade600,
                ),
                const SizedBox(height: 12),
                Text(
                  'สินค้าตัวนี้มีอยู่ในตะกร้าแล้ว',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.green.shade700,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'จำนวน: $quantityInCart ชิ้น',
                  style: TextStyle(fontSize: 16, color: Colors.green.shade600),
                ),
              ],
            ),
          );
        } else {
          // สินค้าไม่อยู่ในตะกร้า - แสดงปุ่มเพิ่มเข้าตะกร้า
          return Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            child: ElevatedButton(
              onPressed: canAddToCart ? _addToCart : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: canAddToCart
                    ? Colors.green[600]
                    : Colors.grey[400],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: canAddToCart ? 3 : 0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    canAddToCart ? Icons.shopping_cart : Icons.not_interested,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    canAddToCart ? 'เพิ่มลงตะกร้า' : 'สินค้าหมด',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          );
        }
      },
    );
  }
}
