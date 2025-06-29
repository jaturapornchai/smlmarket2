import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'data/models/order_model.dart';
import 'data/models/product_model.dart';
import 'data/models/quotation_model.dart';
import 'presentation/cubit/auth_cubit.dart';
import 'presentation/cubit/cart_cubit.dart';
import 'presentation/cubit/negotiation_cubit.dart';
import 'presentation/cubit/order_cubit.dart';
import 'presentation/cubit/product_search_cubit.dart';
import 'presentation/cubit/quotation_cubit.dart';
import 'presentation/screens/cart_screen.dart';
import 'presentation/screens/history_screen.dart';
import 'presentation/screens/login_screen.dart';
import 'presentation/screens/negotiation_screen.dart';
import 'presentation/screens/order_list_screen.dart';
import 'presentation/screens/order_detail_screen.dart';
import 'presentation/screens/payment_screen.dart';
import 'presentation/screens/product_detail_screen.dart';
import 'presentation/screens/product_search_screen.dart';
import 'presentation/screens/profile_screen.dart';
import 'presentation/screens/quotation_detail_screen.dart';
import 'presentation/screens/quotation_list_screen.dart';
import 'presentation/screens/register_screen.dart';
import 'presentation/screens/sales_dashboard_screen.dart';
import 'utils/service_locator.dart' as di;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await di.init();
  runApp(const SmlMarketApp());
}

class SmlMarketApp extends StatelessWidget {
  const SmlMarketApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => di.sl<ProductSearchCubit>()),
        BlocProvider(create: (_) => di.sl<CartCubit>()),
        BlocProvider(create: (_) => di.sl<QuotationCubit>()),
        BlocProvider(create: (_) => di.sl<AuthCubit>()),
        BlocProvider(create: (_) => di.sl<OrderCubit>()),
      ],
      child: MaterialApp(
        title: 'SML Market',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.blue,
            brightness: Brightness.light,
          ),
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: true,
          ),
        ),
        // Navigation แบบ Web App - ไม่ใช้ Bottom Navigation
        initialRoute: '/',
        routes: {
          '/': (context) => const ProductSearchScreen(),
          '/cart': (context) => const CartScreen(),
          '/history': (context) => const HistoryScreen(),
          '/profile': (context) => const ProfileScreen(),
          '/login': (context) => const LoginScreen(),
          '/register': (context) => const RegisterScreen(),
          '/quotations': (context) => const QuotationListScreen(customerId: 1),
          '/quotation-list': (context) =>
              const QuotationListScreen(customerId: 1),
          '/orders': (context) => const OrderListScreen(customerId: 1),
          '/sales-dashboard': (context) => const SalesDashboardScreen(),
        },
        onGenerateRoute: (settings) {
          // Handle dynamic routes with parameters
          if (settings.name?.startsWith('/product/') == true ||
              settings.name == '/product-detail') {
            // Extract product data from arguments
            final product = settings.arguments as ProductModel?;
            if (product != null) {
              return MaterialPageRoute(
                builder: (context) => ProductDetailScreen(product: product),
              );
            }
          }
          if (settings.name == '/quotation-detail') {
            // Extract quotation data from arguments
            final quotation = settings.arguments as Quotation?;
            if (quotation != null) {
              return MaterialPageRoute(
                builder: (context) =>
                    QuotationDetailScreen(quotation: quotation),
              );
            }
          }
          if (settings.name == '/order-detail') {
            // Extract order data from arguments
            final order = settings.arguments as OrderModel?;
            if (order != null) {
              return MaterialPageRoute(
                builder: (context) => OrderDetailScreen(order: order),
              );
            }
          }
          if (settings.name == '/payment') {
            // Extract order data from arguments
            final order = settings.arguments as OrderModel?;
            if (order != null) {
              return MaterialPageRoute(
                builder: (context) => PaymentScreen(order: order),
              );
            }
          }
          if (settings.name == '/negotiation') {
            // Extract quotation data from arguments
            final args = settings.arguments as Map<String, dynamic>?;
            final quotation = args?['quotation'] as Quotation?;
            final specificItem = args?['specificItem'] as QuotationItem?;
            if (quotation != null) {
              return MaterialPageRoute(
                builder: (context) => MultiBlocProvider(
                  providers: [
                    BlocProvider(
                      create: (context) => di.sl<NegotiationCubit>(),
                    ),
                    BlocProvider(create: (context) => di.sl<QuotationCubit>()),
                  ],
                  child: NegotiationScreen(
                    quotation: quotation,
                    specificItem: specificItem,
                  ),
                ),
              );
            }
          }
          return null;
        },
      ),
    );
  }
}
