import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';

import '../data/data_sources/auth_remote_data_source.dart';
import '../data/data_sources/cart_remote_data_source.dart';
import '../data/data_sources/cart_postgresql_data_source.dart';
import '../data/data_sources/negotiation_remote_data_source.dart';
import '../data/data_sources/order_remote_data_source.dart';
import '../data/data_sources/product_remote_data_source.dart';
import '../data/data_sources/quotation_api_data_source.dart';
import '../data/repositories/auth_repository.dart';
import '../data/repositories/cart_repository.dart';
import '../data/repositories/negotiation_repository.dart';
import '../data/repositories/order_repository.dart';
import '../data/repositories/product_repository.dart';
import '../presentation/cubit/auth_cubit.dart';
import '../presentation/cubit/cart_cubit.dart';
import '../presentation/cubit/login_cubit.dart';
import '../presentation/cubit/negotiation_cubit.dart';
import '../presentation/cubit/order_cubit.dart';
import '../presentation/cubit/product_search_cubit.dart';
import '../presentation/cubit/quotation_cubit.dart';
import 'app_config.dart';

final GetIt sl = GetIt.instance;

Future<void> init() async {
  // Core services
  sl.registerLazySingleton<Logger>(() => Logger());
  sl.registerLazySingleton<Dio>(() {
    final dio = Dio();
    // ใช้ URL จาก AppConfig
    dio.options.baseUrl = AppConfig.usePostgreSQL
        ? AppConfig.postgresqlApiUrl
        : AppConfig.apiBaseUrl;
    dio.options.connectTimeout = const Duration(seconds: 30);
    dio.options.receiveTimeout = const Duration(seconds: 30);
    return dio;
  });

  // Data Sources
  sl.registerLazySingleton<ProductDataSource>(
    () => ProductRemoteDataSource(dio: sl(), logger: sl()),
  );

  sl.registerLazySingleton<CartDataSource>(() {
    // เปลี่ยนมาใช้ PostgreSQL API เพื่อ debug error
    if (AppConfig.usePostgreSQL) {
      return CartPostgreSQLDataSource(logger: sl());
    } else {
      return CartRemoteDataSource(dio: sl(), logger: sl());
    }
  });

  sl.registerLazySingleton<QuotationApiDataSource>(
    () => QuotationApiDataSource(sl()),
  );

  sl.registerLazySingleton<AuthDataSource>(
    () => AuthRemoteDataSource(dio: sl(), logger: sl()),
  );

  sl.registerLazySingleton<OrderDataSource>(
    () => OrderRemoteDataSource(dio: sl(), logger: sl()),
  );

  sl.registerLazySingleton<NegotiationDataSource>(
    () => NegotiationRemoteDataSource(dio: sl(), logger: sl()),
  );

  // Repositories
  sl.registerLazySingleton<ProductRepository>(
    () => ProductRepositoryImpl(remoteDataSource: sl()),
  );

  sl.registerLazySingleton<CartRepository>(
    () => CartRepositoryImpl(remoteDataSource: sl()),
  );

  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(remoteDataSource: sl()),
  );

  sl.registerLazySingleton<OrderRepository>(
    () => OrderRepositoryImpl(remoteDataSource: sl()),
  );

  sl.registerLazySingleton<NegotiationRepository>(
    () => NegotiationRepositoryImpl(remoteDataSource: sl()),
  );

  // Cubits
  sl.registerFactory<ProductSearchCubit>(
    () => ProductSearchCubit(repository: sl(), logger: sl()),
  );

  sl.registerFactory<CartCubit>(
    () => CartCubit(repository: sl(), logger: sl()),
  );

  sl.registerFactory<QuotationCubit>(() => QuotationCubit(sl()));

  sl.registerFactory<LoginCubit>(() => LoginCubit());

  sl.registerFactory<AuthCubit>(
    () => AuthCubit(repository: sl(), logger: sl()),
  );

  sl.registerFactory<OrderCubit>(
    () => OrderCubit(repository: sl(), logger: sl()),
  );

  sl.registerFactory<NegotiationCubit>(
    () => NegotiationCubit(repository: sl(), logger: sl()),
  );
}
