import '../../domain/entities/variant.dart';
import '../../domain/repositories/variant_repository.dart';
import '../datasources/variant_remote_data_source.dart';

class VariantRepositoryImpl implements VariantRepository {
  VariantRepositoryImpl({required this.remoteDataSource});

  final VariantRemoteDataSource remoteDataSource;

  @override
  Future<List<Variant>> getVariantsByProductId(String productId) async {
    return remoteDataSource.fetchVariantsByProductId(productId);
  }
}
