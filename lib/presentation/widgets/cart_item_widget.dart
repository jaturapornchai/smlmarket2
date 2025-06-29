import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../data/models/cart_item_model.dart';
import '../../utils/number_formatter.dart';

/// 🛍️ Widget แสดงรายการสินค้าในตะกร้า (เวอร์ชันใหม่ที่มีการควบคุมยอดคงเหลือ)
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
      _quantityController.text = NumberFormatter.formatQuantity(
        widget.item.quantity,
      );
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
                      if (widget.item.barcode != null &&
                          widget.item.barcode!.isNotEmpty)
                        Text(
                          'บาร์โค้ด: ${widget.item.barcode}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      if (widget.qtyAvailable != null)
                        Text(
                          'ยอดที่สั่งเพิ่มได้: ${NumberFormatter.formatQuantity(widget.qtyAvailable!)} ชิ้น',
                          style: TextStyle(
                            fontSize: 12,
                            color: widget.qtyAvailable! > 0
                                ? Colors.green.shade600
                                : Colors.red.shade600,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: widget.onRemove,
                  icon: const Icon(Icons.delete_outline),
                  color: Colors.red.shade600,
                  tooltip: 'ลบสินค้า',
                ),
              ],
            ),

            const Divider(height: 24),

            // ส่วนข้อมูลสินค้า
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // ราคาต่อหน่วย
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'ราคาต่อหน่วย',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    Text(
                      NumberFormatter.formatCurrency(
                        widget.item.unitPrice ?? 0.0,
                      ),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),

                // จำนวนและราคารวม
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _buildQuantityController(),
                    const SizedBox(height: 8),
                    _buildTotalPrice(),
                  ],
                ),
              ],
            ),

            // หน่วย (ถ้ามี)
            if (widget.item.unitCode != null &&
                widget.item.unitCode!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Text(
                    'หน่วย:',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  const SizedBox(width: 8),
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
          ), // ช่องแก้ไขจำนวน
          InkWell(
            onTap: () => _showQuantityEditDialog(),
            child: Container(
              width: 80,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.symmetric(
                  vertical: BorderSide(color: Colors.grey.shade300),
                ),
              ),
              child: Text(
                NumberFormatter.formatQuantity(widget.item.quantity),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ), // ปุ่มเพิ่ม
          InkWell(
            onTap: () {
              final newQuantity = widget.item.quantity + 1.0;
              // ⭐ สำหรับรายการในตะกร้า: ยอดสูงสุดที่สั่งได้ = ยอดคงเหลือ + จำนวนในตะกร้าปัจจุบัน
              final maxAllowedQuantity = widget.qtyAvailable != null
                  ? widget.qtyAvailable! + widget.item.quantity
                  : double.infinity;

              if (newQuantity <= maxAllowedQuantity) {
                widget.onQuantityChanged(newQuantity);
              } else {
                _showStockLimitDialog();
              }
            },
            borderRadius: const BorderRadius.only(
              topRight: Radius.circular(8),
              bottomRight: Radius.circular(8),
            ),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _canIncrease()
                    ? Colors.blue.shade50
                    : Colors.grey.shade100,
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(8),
                  bottomRight: Radius.circular(8),
                ),
              ),
              child: Icon(
                Icons.add,
                size: 20,
                color: _canIncrease()
                    ? Colors.blue.shade600
                    : Colors.grey.shade400,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// ตรวจสอบว่าสามารถเพิ่มจำนวนได้หรือไม่
  bool _canIncrease() {
    if (widget.qtyAvailable == null) return true;
    // ⭐ สำหรับรายการในตะกร้า: ยอดสูงสุดที่สั่งได้ = ยอดคงเหลือ + จำนวนในตะกร้าปัจจุบัน
    final maxAllowedQuantity = widget.qtyAvailable! + widget.item.quantity;
    return widget.item.quantity < maxAllowedQuantity;
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

  /// แสดง Dialog สำหรับแก้ไขจำนวน
  void _showQuantityEditDialog() {
    _quantityController.text = NumberFormatter.formatQuantity(
      widget.item.quantity,
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('แก้ไขจำนวน'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _quantityController,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
              ],
              decoration: InputDecoration(
                labelText: 'จำนวน',
                suffixText: 'ชิ้น',
                helperText: widget.qtyAvailable != null
                    ? 'ยอดที่สั่งเพิ่มได้อีก: ${NumberFormatter.formatQuantity(widget.qtyAvailable!)} ชิ้น'
                    : null,
                border: const OutlineInputBorder(),
              ),
              autofocus: true,
              onChanged: (value) {
                setState(() => _isEditing = true);
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ยกเลิก'),
          ),
          TextButton(
            onPressed: () => _saveQuantity(),
            child: const Text('บันทึก'),
          ),
        ],
      ),
    ).then((_) {
      setState(() => _isEditing = false);
    });
  }

  /// บันทึกจำนวนใหม่
  void _saveQuantity() {
    final text = _quantityController.text.trim();
    final newQuantity = double.tryParse(text);

    if (newQuantity == null || newQuantity <= 0) {
      _showErrorDialog('กรุณาใส่จำนวนที่ถูกต้อง');
      return;
    } // ⭐ สำหรับรายการในตะกร้า: ยอดสูงสุดที่สั่งได้ = ยอดคงเหลือ + จำนวนในตะกร้าปัจจุบัน
    if (widget.qtyAvailable != null) {
      final maxAllowedQuantity = widget.qtyAvailable! + widget.item.quantity;
      if (newQuantity > maxAllowedQuantity) {
        _showErrorDialog(
          'จำนวนเกินยอดที่สั่งเพิ่มได้อีก (สูงสุด ${NumberFormatter.formatQuantity(maxAllowedQuantity)} ชิ้น)',
        );
        return;
      }
    }

    Navigator.pop(context);
    widget.onQuantityChanged(newQuantity);
  }

  /// แสดงข้อผิดพลาดเมื่อเกินยอดคงเหลือ
  void _showStockLimitDialog() {
    final maxAllowedQuantity = widget.qtyAvailable != null
        ? widget.qtyAvailable! + widget.item.quantity
        : 0.0;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.warning_amber, color: Colors.orange.shade600),
            const SizedBox(width: 8),
            const Text('ไม่สามารถเพิ่มได้'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'สินค้าคงเหลือที่สามารถสั่งเพิ่มได้อีก:',
              style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
            ),
            Text(
              '${NumberFormatter.formatQuantity(widget.qtyAvailable ?? 0)} ชิ้น',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.red.shade600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'จำนวนสูงสุดที่สั่งได้ทั้งหมด (รวมในตะกร้า):',
              style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
            ),
            Text(
              '${NumberFormatter.formatQuantity(maxAllowedQuantity)} ชิ้น',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ตกลง'),
          ),
        ],
      ),
    );
  }

  /// แสดงข้อผิดพลาด
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ข้อผิดพลาด'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ตกลง'),
          ),
        ],
      ),
    );
  }
}
