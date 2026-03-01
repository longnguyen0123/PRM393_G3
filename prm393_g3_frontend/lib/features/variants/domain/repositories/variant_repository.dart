import '../entities/variant.dart';

abstract class VariantRepository {
  Future<List<Variant>> getVariantsByProductId(String productId);
}
