import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logger/logger.dart';

import 'data/data_sources/product_remote_data_source.dart';
import 'data/repositories/product_repository.dart';
import 'presentation/cubit/product_search_cubit.dart';
import 'presentation/screens/product_search_screen.dart';

void main() {
  runApp(const SmlMarketApp());
}

class SmlMarketApp extends StatelessWidget {
  const SmlMarketApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize dependencies
    final logger = Logger();
    final remoteDataSource = ProductRemoteDataSource(logger: logger);
    final repository = ProductRepositoryImpl(
      remoteDataSource: remoteDataSource,
    );

    return MaterialApp(
      title: 'SML Market',
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
      home: BlocProvider(
        create: (context) =>
            ProductSearchCubit(repository: repository, logger: logger),
        child: const ProductSearchScreen(),
      ),
    );
  }
}
