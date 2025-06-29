import 'package:flutter/material.dart';

/// 🛒 Popup สำหรับเลือกขั้นตอนต่อไปของตะกร้าสินค้า
/// ประหยัดพื้นที่จอและให้ UX ที่ดีขึ้น
class CartActionPopup extends StatelessWidget {
  final VoidCallback onQuickOrder;
  final VoidCallback onNegotiate;
  final VoidCallback onCreateQuotation;
  final double totalAmount;
  final int itemCount;

  const CartActionPopup({
    super.key,
    required this.onQuickOrder,
    required this.onNegotiate,
    required this.onCreateQuotation,
    required this.totalAmount,
    required this.itemCount,
  });

  /// แสดง Popup การเลือกขั้นตอนต่อไป
  static Future<void> show(
    BuildContext context, {
    required VoidCallback onQuickOrder,
    required VoidCallback onNegotiate,
    required VoidCallback onCreateQuotation,
    required double totalAmount,
    required int itemCount,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => CartActionPopup(
        onQuickOrder: onQuickOrder,
        onNegotiate: onNegotiate,
        onCreateQuotation: onCreateQuotation,
        totalAmount: totalAmount,
        itemCount: itemCount,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 8,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header พร้อมปุ่มปิด
              Row(
                children: [
                  Icon(
                    Icons.shopping_cart,
                    color: Colors.blue.shade600,
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'เลือกขั้นตอนต่อไป',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.close, color: Colors.grey.shade600),
                    tooltip: 'ปิด',
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // สรุปคำสั่งซื้อ
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'จำนวนสินค้า',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          '$itemCount รายการ',
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'ยอดรวม',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          '฿${_formatCurrency(totalAmount)}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Colors.blue.shade600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // คำอธิบายตัวเลือก
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: Colors.blue.shade700,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'เลือกวิธีการดำเนินการ:',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Colors.blue.shade800,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildInfoRow(
                      '• สั่งซื้อทันที:',
                      'ส่งคำสั่งซื้อให้ Admin อนุมัติทันที',
                    ),
                    const SizedBox(height: 6),
                    _buildInfoRow(
                      '• ต่อรองราคา:',
                      'เจรจาราคาและเงื่อนไขก่อนสั่งซื้อ',
                    ),
                    const SizedBox(height: 6),
                    _buildInfoRow(
                      '• สร้างใบเสนอราคา:',
                      'สร้างใบเสนอราคาเพื่อขอยืนยัน',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // ปุ่มต่างๆ
              Column(
                children: [
                  // ปุ่มสั่งซื้อทันที
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        onQuickOrder();
                      },
                      icon: const Icon(
                        Icons.flash_on,
                        color: Colors.white,
                        size: 20,
                      ),
                      label: const Text(
                        'สั่งซื้อทันที (Quick Order)',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade600,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // ปุ่มต่อรองราคา และ สร้างใบเสนอราคา
                  Row(
                    children: [
                      // ปุ่มต่อรองราคา
                      Expanded(
                        child: SizedBox(
                          height: 50,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.pop(context);
                              onNegotiate();
                            },
                            icon: const Icon(
                              Icons.handshake,
                              color: Colors.white,
                              size: 18,
                            ),
                            label: const Text(
                              'ต่อรองราคา',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange.shade600,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 2,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),

                      // ปุ่มสร้างใบเสนอราคา
                      Expanded(
                        child: SizedBox(
                          height: 50,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.pop(context);
                              onCreateQuotation();
                            },
                            icon: const Icon(
                              Icons.description,
                              color: Colors.white,
                              size: 18,
                            ),
                            label: const Text(
                              'สร้างใบเสนอราคา',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green.shade600,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 2,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // ปุ่มยกเลิก
              TextButton(
                onPressed: () => Navigator.pop(context),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 24,
                  ),
                ),
                child: Text(
                  'ยกเลิก',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String title, String description) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.blue.shade700,
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            description,
            style: TextStyle(
              fontSize: 13,
              color: Colors.blue.shade700,
              height: 1.3,
            ),
          ),
        ),
      ],
    );
  }

  String _formatCurrency(double amount) {
    // ฟอร์แมตเงินแบบง่าย เช่น 12,575.50 หรือ 12,575
    final formatted = amount.toStringAsFixed(2);
    if (formatted.endsWith('.00')) {
      return formatted.substring(0, formatted.length - 3);
    }
    return formatted;
  }
}
