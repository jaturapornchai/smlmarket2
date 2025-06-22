import 'package:flutter/material.dart';

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
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      type: BottomNavigationBarType.fixed,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.search), label: 'ค้นหา'),
        BottomNavigationBarItem(
          icon: Icon(Icons.shopping_cart),
          label: 'ตระกร้า',
        ),
        BottomNavigationBarItem(icon: Icon(Icons.history), label: 'ประวัติ'),
        BottomNavigationBarItem(icon: Icon(Icons.login), label: 'Login'),
      ],
    );
  }
}
