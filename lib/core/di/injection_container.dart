import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';

import '../../data/datasources/auth_local_datasource.dart';
import '../../data/datasources/auth_remote_datasource.dart';
import '../../data/datasources/cafe_remote_datasource.dart';
import '../../data/datasources/city_remote_datasource.dart';
import '../../data/datasources/product_remote_datasource.dart';
import '../../data/datasources/wallet_remote_datasource.dart';
import '../../data/datasources/order_remote_datasource.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../data/repositories/cafe_repository_impl.dart';
import '../../data/repositories/city_repository_impl.dart';
import '../../data/repositories/product_repository_impl.dart';
import '../../data/repositories/wallet_repository_impl.dart';
import '../../data/repositories/order_repository_impl.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/repositories/cafe_repository.dart';
import '../../domain/repositories/city_repository.dart';
import '../../domain/repositories/product_repository.dart';
import '../../domain/repositories/wallet_repository.dart';
import '../../domain/repositories/order_repository.dart';
import '../../presentation/blocs/auth/auth_bloc.dart';
import '../../presentation/blocs/cafe/cafe_bloc.dart';
import '../../presentation/blocs/city/city_bloc.dart';
import '../../presentation/blocs/product/product_bloc.dart';
import '../../presentation/blocs/wallet/wallet_bloc.dart';
import '../../presentation/blocs/order/order_bloc.dart';
import '../../presentation/blocs/search/search_bloc.dart';
import '../network/api_client.dart';

final sl = GetIt.instance;

Future<void> initializeDependencies() async {
  // ==================== External ====================
  const secureStorage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  );
  sl.registerLazySingleton<FlutterSecureStorage>(() => secureStorage);

  // ==================== Core ====================
  sl.registerLazySingleton<ApiClient>(
    () => ApiClient(secureStorage: sl<FlutterSecureStorage>()),
  );

  // ==================== Data Sources ====================
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(apiClient: sl<ApiClient>()),
  );

  sl.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSourceImpl(secureStorage: sl<FlutterSecureStorage>()),
  );

  sl.registerLazySingleton<CityRemoteDataSource>(
    () => CityRemoteDataSourceImpl(apiClient: sl<ApiClient>()),
  );

  sl.registerLazySingleton<CafeRemoteDataSource>(
    () => CafeRemoteDataSourceImpl(apiClient: sl<ApiClient>()),
  );

  sl.registerLazySingleton<ProductRemoteDataSource>(
    () => ProductRemoteDataSourceImpl(apiClient: sl<ApiClient>()),
  );

  sl.registerLazySingleton<WalletRemoteDataSource>(
    () => WalletRemoteDataSourceImpl(apiClient: sl<ApiClient>()),
  );

  sl.registerLazySingleton<OrderRemoteDataSource>(
    () => OrderRemoteDataSourceImpl(apiClient: sl<ApiClient>()),
  );

  // ==================== Repositories ====================
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: sl<AuthRemoteDataSource>(),
      localDataSource: sl<AuthLocalDataSource>(),
    ),
  );

  sl.registerLazySingleton<CityRepository>(
    () => CityRepositoryImpl(remoteDataSource: sl<CityRemoteDataSource>()),
  );

  sl.registerLazySingleton<CafeRepository>(
    () => CafeRepositoryImpl(remoteDataSource: sl<CafeRemoteDataSource>()),
  );

  sl.registerLazySingleton<ProductRepository>(
    () => ProductRepositoryImpl(remoteDataSource: sl<ProductRemoteDataSource>()),
  );

  sl.registerLazySingleton<WalletRepository>(
    () => WalletRepositoryImpl(remoteDataSource: sl<WalletRemoteDataSource>()),
  );

  sl.registerLazySingleton<OrderRepository>(
    () => OrderRepositoryImpl(remoteDataSource: sl<OrderRemoteDataSource>()),
  );

  // ==================== BLoCs ====================
  sl.registerFactory<AuthBloc>(
    () => AuthBloc(authRepository: sl<AuthRepository>()),
  );

  sl.registerFactory<CityBloc>(
    () => CityBloc(cityRepository: sl<CityRepository>()),
  );

  sl.registerFactory<CafeBloc>(
    () => CafeBloc(cafeRepository: sl<CafeRepository>()),
  );

  sl.registerFactory<ProductBloc>(
    () => ProductBloc(repository: sl<ProductRepository>()),
  );

  sl.registerFactory<WalletBloc>(
    () => WalletBloc(walletRepository: sl<WalletRepository>()),
  );

  sl.registerFactory<OrderBloc>(
    () => OrderBloc(orderRepository: sl<OrderRepository>()),
  );

  sl.registerFactory<SearchBloc>(
    () => SearchBloc(),
  );
}
