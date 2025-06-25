import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'presentation/cubit/cart_cubit.dart';
import 'presentation/cubit/product_search_cubit.dart';
import 'presentation/cubit/quotation_cubit.dart';
import 'presentation/screens/product_search_screen.dart';
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
        home: const ProductSearchScreen(),
      ),
    );
  }
}
