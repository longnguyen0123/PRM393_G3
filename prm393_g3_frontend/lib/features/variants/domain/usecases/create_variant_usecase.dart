import '../entities/variant.dart';
import '../repositories/variant_repository.dart';

class CreateVariantUseCase {
  CreateVariantUseCase({required this.repository});

  final VariantRepository repository;

  Future<Variant> call({
    required String productId,
    required String sku,
    String? barcode,
    required double price,
    String status = 'ACTIVE',
  }) {
    return repository.createVariant(
      productId: productId,
      sku: sku,
      barcode: barcode,
      price: price,
      status: status,
    );
  }
}
