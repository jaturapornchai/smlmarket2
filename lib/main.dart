import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logger/logger.dart';

import 'data/data_sources/cart_remote_data_source.dart';
import 'data/data_sources/product_remote_data_source.dart';
import 'data/repositories/cart_repository.dart';
import 'data/repositories/product_repository.dart';
import 'presentation/cubit/cart_cubit.dart';
import 'presentation/cubit/product_search_cubit.dart';
import 'presentation/screens/product_search_screen.dart';

void main() {
  runApp(const SmlMarketApp());
}

class SmlMarketApp extends StatelessWidget {
  const SmlMarketApp({super.key});

  @override
  Widget build(BuildContext context) {
    final logger = Logger();
    final remoteDataSource = ProductRemoteDataSource(logger: logger);
    final repository = ProductRepositoryImpl(
      remoteDataSource: remoteDataSource,
    );

    final cartRemoteDataSource = CartRemoteDataSource(logger: logger);
    final cartRepository = CartRepositoryImpl(
      remoteDataSource: cartRemoteDataSource,
    );

    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) =>
              ProductSearchCubit(repository: repository, logger: logger),
        ),
        BlocProvider(
          create: (_) {
            final cartCubit = CartCubit(
              repository: cartRepository,
              logger: logger,
            );
            // โหลดข้อมูลตระกร้าทันทีเมื่อเริ่มต้นแอป (ใช้ customer_id = 1 เป็นตัวอย่าง)
            cartCubit.loadCart(customerId: '1');
            return cartCubit;
          },
        ),
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
