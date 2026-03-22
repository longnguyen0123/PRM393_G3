import '../../domain/entities/brand.dart';
import '../../domain/repositories/brand_repository.dart';
import '../datasources/brand_remote_data_source.dart';

class BrandRepositoryImpl implements BrandRepository {
  BrandRepositoryImpl({required this.remoteDataSource});

  final BrandRemoteDataSource remoteDataSource;

  @override
  Future<List<Brand>> getBrands() async {
    return remoteDataSource.fetchBrands();
  }

  @override
  Future<Brand> createBrand({required String name, String? status}) {
    return remoteDataSource.createBrand(name: name, status: status);
  }

  @override
  Future<Brand> updateBrand({required String id, String? name, String? status}) {
    return remoteDataSource.updateBrand(id: id, name: name, status: status);
  }
}
