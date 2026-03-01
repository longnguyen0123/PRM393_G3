import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import '../../features/products/data/datasources/product_remote_data_source.dart';
import '../../features/products/data/repositories/product_repository_impl.dart';
import '../../features/products/domain/repositories/product_repository.dart';
import '../../features/products/presentation/bloc/product_bloc.dart';
import '../network/api_client.dart';

// ===== Branch Feature Imports =====
import '../../features/branches/data/datasources/branch_remote_datasource.dart';
import '../../features/branches/data/repositories/branch_repository_impl.dart';
import '../../features/branches/domain/repositories/branch_repository.dart';
import '../../features/branches/domain/usecases/get_branch.dart';
import '../../features/branches/presentation/bloc/branch_bloc.dart';

// ===== Variant Feature Imports =====
import '../../features/variants/data/datasources/variant_remote_data_source.dart';
import '../../features/variants/data/repositories/variant_repository_impl.dart';
import '../../features/variants/domain/repositories/variant_repository.dart';
import '../../features/variants/domain/usecases/get_variants_usecase.dart';
import '../../features/variants/presentation/bloc/variant_bloc.dart';

// ===== Brand Feature Imports =====
import '../../features/brands/data/datasources/brand_remote_data_source.dart';
import '../../features/brands/data/repositories/brand_repository_impl.dart';
import '../../features/brands/domain/repositories/brand_repository.dart';
import '../../features/brands/domain/usecases/get_brands_usecase.dart';
import '../../features/brands/presentation/bloc/brand_bloc.dart';

// ===== Category Feature Imports =====
import '../../features/categories/data/datasources/category_remote_data_source.dart';
import '../../features/categories/data/repositories/category_repository_impl.dart';
import '../../features/categories/domain/repositories/category_repository.dart';
import '../../features/categories/domain/usecases/get_categories_usecase.dart';
import '../../features/categories/presentation/bloc/category_bloc.dart';

final getIt = GetIt.instance;

Future<void> configureDependencies() async {
  //localhost
  const baseUrl = 'http://localhost:3000/api';

  //emulator
  //const baseUrl = 'http://10.0.2.2:3000/api';

  getIt
    ..registerLazySingleton<Dio>(() => Dio(BaseOptions(baseUrl: baseUrl)))
    ..registerLazySingleton<ApiClient>(() => ApiClient(getIt()));

  // ===== Product Feature =====
  getIt
    ..registerLazySingleton<ProductRemoteDataSource>(
      () => ProductRemoteDataSourceImpl(apiClient: getIt()),
    )
    ..registerLazySingleton<ProductRepository>(
      () => ProductRepositoryImpl(remoteDataSource: getIt()),
    )
    ..registerFactory<ProductBloc>(() => ProductBloc(repository: getIt()));

  // ===== Branch Feature =====
  getIt
    ..registerLazySingleton(() => BranchRemoteDataSource(getIt()))
    ..registerLazySingleton<BranchRepository>(
      () => BranchRepositoryImpl(getIt()),
    )
    ..registerLazySingleton(() => GetBranches(getIt()))
    ..registerFactory(() => BranchBloc(getIt()));

  // ===== Variant Feature =====
  getIt
    ..registerLazySingleton<VariantRemoteDataSource>(
      () => VariantRemoteDataSourceImpl(apiClient: getIt()),
    )
    ..registerLazySingleton<VariantRepository>(
      () => VariantRepositoryImpl(remoteDataSource: getIt()),
    )
    ..registerLazySingleton<GetVariantsUseCase>(
      () => GetVariantsUseCase(repository: getIt()),
    )
    ..registerFactory<VariantBloc>(() => VariantBloc(getVariantsUseCase: getIt()));

  // ===== Brand Feature =====
  getIt
    ..registerLazySingleton<BrandRemoteDataSource>(
      () => BrandRemoteDataSourceImpl(apiClient: getIt()),
    )
    ..registerLazySingleton<BrandRepository>(
      () => BrandRepositoryImpl(remoteDataSource: getIt()),
    )
    ..registerLazySingleton<GetBrandsUseCase>(
      () => GetBrandsUseCase(repository: getIt()),
    )
    ..registerFactory<BrandBloc>(() => BrandBloc(getBrandsUseCase: getIt()));

  // ===== Category Feature =====
  getIt
    ..registerLazySingleton<CategoryRemoteDataSource>(
      () => CategoryRemoteDataSourceImpl(apiClient: getIt()),
    )
    ..registerLazySingleton<CategoryRepository>(
      () => CategoryRepositoryImpl(remoteDataSource: getIt()),
    )
    ..registerLazySingleton<GetCategoriesUseCase>(
      () => GetCategoriesUseCase(repository: getIt()),
    )
    ..registerFactory<CategoryBloc>(() => CategoryBloc(getCategoriesUseCase: getIt()));
}
