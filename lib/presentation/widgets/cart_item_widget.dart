import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../data/models/cart_item_model.dart';
import '../../utils/number_formatter.dart';

/// 🛍️ Widget แสดงรายการสินค้าในตระกร้า
class CartItemWidget extends StatefulWidget {
  final CartItemModel item;
  final Function(double) onQuantityChanged;
  final VoidCallback onRemove;
  final double? qtyAvailable; // ยอดคงเหลือ

  const CartItemWidget({
    super.key,
    required this.item,
    required this.onQuantityChanged,
    required this.onRemove,
    this.qtyAvailable,
  });

  @override
  State<CartItemWidget> createState() => _CartItemWidgetState();
}

class _CartItemWidgetState extends State<CartItemWidget> {
  late TextEditingController _quantityController;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _quantityController = TextEditingController(
      text: NumberFormatter.formatQuantity(widget.item.quantity),
    );
  }

  @override
  void dispose() {
    _quantityController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(CartItemWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.item.quantity != widget.item.quantity && !_isEditing) {
      _quantityController.text = NumberFormatter.formatQuantity(widget.item.quantity);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ส่วนหัว - รหัสสินค้าและปุ่มลบ
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.item.icCode,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (widget.item.barcode != null && widget.item.barcode!.isNotEmpty)
                        Text(
                          'บาร์โค้ด: ${widget.item.barcode}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: widget.onRemove,
                  icon: Icon(Icons.delete_outline, color: Colors.red.shade400),
                  tooltip: 'ลบสินค้า',
                ),
              ],
            ),

            const SizedBox(height: 12),

            // ข้อมูลสินค้า
            _buildProductInfo(),

            const SizedBox(height: 16),

            // ส่วนควบคุมจำนวนและราคา
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // ควบคุมจำนวน
                _buildQuantityController(),

                // ราคารวม
                _buildTotalPrice(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// สร้างข้อมูลสินค้า
  Widget _buildProductInfo() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'ราคาต่อหน่วย:',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              Text(
                NumberFormatter.formatCurrency(widget.item.unitPrice ?? 0.0),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          if (widget.item.unitCode != null && widget.item.unitCode!.isNotEmpty) ...[
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'หน่วย:',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
                Text(
                  widget.item.unitCode!,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  /// สร้างตัวควบคุมจำนวน
  Widget _buildQuantityController() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ปุ่มลด
          InkWell(
            onTap: () {
              if (widget.item.quantity > 1.0) {
                widget.onQuantityChanged(widget.item.quantity - 1.0);
              }
            },
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(8),
              bottomLeft: Radius.circular(8),
            ),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: widget.item.quantity <= 1.0
                    ? Colors.grey.shade100
                    : Colors.blue.shade50,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(8),
                  bottomLeft: Radius.circular(8),
                ),
              ),
              child: Icon(
                Icons.remove,
                size: 20,
                color: widget.item.quantity <= 1.0
                    ? Colors.grey.shade400
                    : Colors.blue.shade600,
              ),
            ),
          ),

          // แสดงจำนวน
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.symmetric(
                vertical: BorderSide(color: Colors.grey.shade300),
              ),
            ),
            child: Text(
              NumberFormatter.formatQuantity(widget.item.quantity),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),

          // ปุ่มเพิ่ม
          InkWell(
            onTap: () => widget.onQuantityChanged(widget.item.quantity + 1.0),
            borderRadius: const BorderRadius.only(
              topRight: Radius.circular(8),
              bottomRight: Radius.circular(8),
            ),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(8),
                  bottomRight: Radius.circular(8),
                ),
              ),
              child: Icon(Icons.add, size: 20, color: Colors.blue.shade600),
            ),
          ),
        ],
      ),
    );
  }

  /// สร้างแสดงราคารวม
  Widget _buildTotalPrice() {
    final totalPrice = widget.item.totalPrice ?? 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        const Text(
          'ราคารวม',
          style: TextStyle(fontSize: 12, color: Colors.grey),
        ),
        Text(
          NumberFormatter.formatCurrency(totalPrice),
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.blue.shade600,
          ),
        ),
      ],
    );
  }
}