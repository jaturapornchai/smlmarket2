import 'package:flutter/material.dart';

/// 📊 Widget แสดงสรุปข้อมูลตระกร้า
class CartSummaryWidget extends StatelessWidget {
  final int totalItems;
  final double totalAmount;

  const CartSummaryWidget({
    super.key,
    required this.totalItems,
    required this.totalAmount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.blue.shade600, Colors.blue.shade700],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.shade200,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // หัวข้อ
          Row(
            children: [
              Icon(Icons.shopping_cart, color: Colors.white, size: 24),
              const SizedBox(width: 8),
              const Text(
                'สรุปตระกร้าสินค้า',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // ข้อมูลสรุป
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // จำนวนสินค้า
              _buildSummaryItem(
                icon: Icons.inventory_2_outlined,
                label: 'จำนวนสินค้า',
                value: '$totalItems ชิ้น',
              ),

              // เส้นแบ่ง
              Container(
                height: 40,
                width: 1,
                color: Colors.white.withValues(alpha: 0.3),
              ),

              // ยอดรวม
              _buildSummaryItem(
                icon: Icons.payments_outlined,
                label: 'ยอดรวมทั้งหมด',
                value: '฿${totalAmount.toStringAsFixed(2)}',
                isHighlight: true,
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// สร้างรายการสรุป
  Widget _buildSummaryItem({
    required IconData icon,
    required String label,
    required String value,
    bool isHighlight = false,
  }) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: Colors.white.withValues(alpha: 0.9), size: 20),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withValues(alpha: 0.8),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: isHighlight ? 16 : 14,
              fontWeight: isHighlight ? FontWeight.bold : FontWeight.w600,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
