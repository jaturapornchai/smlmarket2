import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/navigation_cubit.dart';
import '../widgets/bottom_nav_bar.dart';
import 'cart_screen.dart';
import 'history_screen.dart';
import 'login_screen.dart';
import 'product_search_screen.dart';

class MainNavigationScreen extends StatelessWidget {
  const MainNavigationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NavigationCubit, int>(
      builder: (context, index) {
        Widget currentScreen;
        switch (index) {
          case 0:
            currentScreen = const ProductSearchScreen();
            break;
          case 1:
            currentScreen = const CartScreen();
            break;
          case 2:
            currentScreen = const HistoryScreen();
            break;
          case 3:
            currentScreen = const LoginScreen();
            break;
          default:
            currentScreen = const ProductSearchScreen();
        }

        return Scaffold(
          body: currentScreen,
          bottomNavigationBar: BottomNavBar(
            currentIndex: index,
            onTap: (i) => context.read<NavigationCubit>().setTab(i),
          ),
        );
      },
    );
  }
}
