import '../entities/variant.dart';

abstract class VariantRepository {
  Future<List<Variant>> getVariantsByProductId(String productId);
  Future<Variant> createVariant({
    required String productId,
    required String sku,
    String? barcode,
    required double price,
    String status = 'ACTIVE',
  });
  Future<Variant> updateVariant(
    String id, {
    required String sku,
    required String? barcode,
    required double price,
    String status = 'ACTIVE',
  });
}
