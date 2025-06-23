import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/cart_cubit.dart';
import '../cubit/cart_state.dart';

class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const BottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CartCubit, CartState>(
      builder: (context, cartState) {
        // คำนวณจำนวนรวมของสินค้าในตระกร้า
        int totalItemCount = 0;
        if (cartState is CartLoaded) {
          totalItemCount = cartState.totalItems;
        }

        return BottomNavigationBar(
          currentIndex: currentIndex,
          onTap: onTap,
          type: BottomNavigationBarType.fixed,
          items: [
            const BottomNavigationBarItem(
              icon: Icon(Icons.search),
              label: 'ค้นหา',
            ),
            BottomNavigationBarItem(
              icon: _buildCartIcon(totalItemCount),
              label: 'ตระกร้า',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.history),
              label: 'ประวัติ',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.login),
              label: 'Login',
            ),
          ],
        );
      },
    );
  }

  /// สร้าง icon ตระกร้าพร้อมแสดงจำนวนสินค้า
  Widget _buildCartIcon(int itemCount) {
    return Stack(
      children: [
        const Icon(Icons.shopping_cart),
        if (itemCount > 0)
          Positioned(
            right: 0,
            top: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(10),
              ),
              constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
              child: Text(
                itemCount > 99 ? '99+' : '$itemCount',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }
}
