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

  @override
  Future<Variant> createVariant({
    required String productId,
    required String sku,
    String? barcode,
    required double price,
    String status = 'ACTIVE',
  }) {
    return remoteDataSource.createVariant(
      productId: productId,
      sku: sku,
      barcode: barcode,
      price: price,
      status: status,
    );
  }

  @override
  Future<Variant> updateVariant(
    String id, {
    required String sku,
    required String? barcode,
    required double price,
    String status = 'ACTIVE',
  }) {
    return remoteDataSource.updateVariant(
      id,
      sku: sku,
      barcode: barcode,
      price: price,
      status: status,
    );
  }
}
