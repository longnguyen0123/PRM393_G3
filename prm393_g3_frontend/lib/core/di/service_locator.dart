import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import '../../features/products/data/datasources/product_remote_data_source.dart';
import '../../features/products/data/repositories/product_repository_impl.dart';
import '../../features/products/domain/repositories/product_repository.dart';
import '../../features/products/domain/usecases/get_products_usecase.dart';
import '../../features/products/presentation/bloc/product_bloc.dart';
import '../network/api_client.dart';

// ===== Branch Feature Imports =====
import '../../features/branches/data/datasources/branch_remote_datasource.dart';
import '../../features/branches/data/repositories/branch_repository_impl.dart';
import '../../features/branches/domain/repositories/branch_repository.dart';
import '../../features/branches/domain/usecases/get_branch.dart';
import '../../features/branches/presentation/bloc/branch_bloc.dart';

final getIt = GetIt.instance;

Future<void> configureDependencies() async {
  //localhost
  const baseUrl = 'http://localhost:3000/api';

  //emulator
  //const baseUrl = 'http://10.0.2.2:3000/api';

  getIt
    ..registerLazySingleton<Dio>(() => Dio(BaseOptions(baseUrl: baseUrl)))
    ..registerLazySingleton<ApiClient>(() => ApiClient(getIt()))
    ..registerLazySingleton<ProductRemoteDataSource>(
      () => ProductRemoteDataSourceImpl(apiClient: getIt()),
    )
    ..registerLazySingleton<ProductRepository>(
      () => ProductRepositoryImpl(remoteDataSource: getIt()),
    )
    ..registerLazySingleton<GetProductsUseCase>(
      () => GetProductsUseCase(repository: getIt()),
    )
    ..registerFactory<ProductBloc>(() => ProductBloc(getProductsUseCase: getIt()));

    // ===== Branch Feature =====

    getIt.registerLazySingleton(() => BranchRemoteDataSource(getIt()));

    getIt.registerLazySingleton<BranchRepository>(
      () => BranchRepositoryImpl(getIt()),
    );

    getIt.registerLazySingleton(() => GetBranches(getIt()));

    getIt.registerFactory(() => BranchBloc(getIt()));
}
