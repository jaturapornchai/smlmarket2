import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';

import '../data/data_sources/cart_remote_data_source.dart';
import '../data/data_sources/product_remote_data_source.dart';
import '../data/repositories/cart_repository.dart';
import '../data/repositories/product_repository.dart';
import '../presentation/cubit/cart_cubit.dart';
import '../presentation/cubit/login_cubit.dart';
import '../presentation/cubit/product_search_cubit.dart';

final GetIt sl = GetIt.instance;

Future<void> init() async {
  // Core services
  sl.registerLazySingleton<Logger>(() => Logger());
  sl.registerLazySingleton<Dio>(() {
    final dio = Dio();
    dio.options.baseUrl = 'https://smlgoapi.dedepos.com/v1';
    dio.options.connectTimeout = const Duration(seconds: 30);
    dio.options.receiveTimeout = const Duration(seconds: 30);
    return dio;
  });

  // Data Sources
  sl.registerLazySingleton<ProductDataSource>(
    () => ProductRemoteDataSource(dio: sl(), logger: sl()),
  );

  sl.registerLazySingleton<CartDataSource>(
    () => CartRemoteDataSource(dio: sl(), logger: sl()),
  );

  // Repositories
  sl.registerLazySingleton<ProductRepository>(
    () => ProductRepositoryImpl(remoteDataSource: sl()),
  );

  sl.registerLazySingleton<CartRepository>(
    () => CartRepositoryImpl(remoteDataSource: sl()),
  );

  // Cubits
  sl.registerFactory<ProductSearchCubit>(
    () => ProductSearchCubit(repository: sl(), logger: sl()),
  );

  sl.registerFactory<CartCubit>(
    () => CartCubit(repository: sl(), logger: sl()),
  );

  sl.registerFactory<LoginCubit>(() => LoginCubit());
}
