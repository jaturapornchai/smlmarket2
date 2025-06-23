import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/navigation_cubit.dart';

/// 🗳️ Widget แสดงเมื่อตระกร้าว่าง
class EmptyCartWidget extends StatelessWidget {
  const EmptyCartWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // ไอคอนตระกร้าว่าง
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.shopping_cart_outlined,
                size: 80,
                color: Colors.grey.shade400,
              ),
            ),

            const SizedBox(height: 24),

            // ข้อความหลัก
            Text(
              'ตระกร้าว่างเปล่า',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade600,
              ),
            ),

            const SizedBox(height: 12),

            // ข้อความอธิบาย
            Text(
              'คุณยังไม่ได้เพิ่มสินค้าใดลงในตระกร้า\nเริ่มช็อปปิ้งเพื่อเพิ่มสินค้าที่คุณต้องการ',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade500,
                height: 1.5,
              ),
            ),

            const SizedBox(height: 32),

            // ปุ่มเริ่มช็อปปิ้ง
            ElevatedButton.icon(
              onPressed: () {
                // Navigate to search tab (index 0)
                context.read<NavigationCubit>().setTab(0);
              },
              icon: const Icon(Icons.shopping_bag),
              label: const Text(
                'เริ่มช็อปปิ้ง',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade600,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
              ),
            ),

            const SizedBox(height: 16),

            // ปุ่มค้นหาสินค้า
            OutlinedButton.icon(
              onPressed: () {
                // Navigate to search tab (index 0)
                context.read<NavigationCubit>().setTab(0);
              },
              icon: const Icon(Icons.search),
              label: const Text('ค้นหาสินค้า'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.blue.shade600,
                side: BorderSide(color: Colors.blue.shade600),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
