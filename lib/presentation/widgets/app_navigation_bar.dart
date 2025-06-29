import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/cart_cubit.dart';
import '../cubit/cart_state.dart';
import '../cubit/quotation_cubit.dart';
import '../cubit/quotation_state.dart';

/// Navigation Bar แสดงทุกหน้าจอ เพื่อให้ทำงานเหมือน Web App
class AppNavigationBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? additionalActions;
  final bool showBackButton;

  const AppNavigationBar({
    super.key,
    required this.title,
    this.additionalActions,
    this.showBackButton = true,
  });

  Widget _buildCartIcon(double itemCount) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        const Icon(Icons.shopping_cart, size: 24),
        if (itemCount > 0)
          Positioned(
            right: -6,
            top: -6,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(10),
              ),
              constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
              child: Text(
                itemCount.toInt().toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildQuotationIcon(int quotationCount) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        const Icon(Icons.receipt_long, size: 24),
        if (quotationCount > 0)
          Positioned(
            right: -6,
            top: -6,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: Colors.orange,
                borderRadius: BorderRadius.circular(10),
              ),
              constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
              child: Text(
                quotationCount.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title),
      backgroundColor: Colors.white,
      foregroundColor: Colors.black,
      elevation: 1,
      automaticallyImplyLeading: showBackButton,
      actions: [
        // หน้าแรก (ค้นหาสินค้า)
        IconButton(
          onPressed: () {
            Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
          },
          icon: const Icon(Icons.home),
          tooltip: 'หน้าแรก',
        ),

        // ตะกร้าสินค้า
        BlocBuilder<CartCubit, CartState>(
          builder: (context, state) {
            final itemCount = state is CartLoaded ? state.totalItems : 0.0;
            return IconButton(
              onPressed: () {
                Navigator.pushNamed(context, '/cart');
              },
              icon: _buildCartIcon(itemCount),
              tooltip: 'ตะกร้าสินค้า',
            );
          },
        ),

        // ใบเสนอราคา
        BlocBuilder<QuotationCubit, QuotationState>(
          builder: (context, state) {
            final quotationCount = state is QuotationLoaded
                ? state.quotations.length
                : 0;
            return IconButton(
              onPressed: () {
                Navigator.pushNamed(context, '/quotations');
              },
              icon: _buildQuotationIcon(quotationCount),
              tooltip: 'ใบเสนอราคา',
            );
          },
        ),

        // ประวัติการสั่งซื้อ
        IconButton(
          onPressed: () {
            Navigator.pushNamed(context, '/history');
          },
          icon: const Icon(Icons.history),
          tooltip: 'ประวัติการสั่งซื้อ',
        ),

        // โปรไฟล์
        IconButton(
          onPressed: () {
            Navigator.pushNamed(context, '/profile');
          },
          icon: const Icon(Icons.person),
          tooltip: 'โปรไฟล์',
        ),

        // Additional actions if provided
        if (additionalActions != null) ...additionalActions!,

        const SizedBox(width: 8),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
