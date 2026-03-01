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
}
