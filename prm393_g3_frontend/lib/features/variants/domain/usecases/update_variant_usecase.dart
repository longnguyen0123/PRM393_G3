import '../entities/variant.dart';
import '../repositories/variant_repository.dart';

class UpdateVariantUseCase {
  UpdateVariantUseCase({required this.repository});

  final VariantRepository repository;

  Future<Variant> call(
    String id, {
    required String sku,
    required String? barcode,
    required double price,
    String status = 'ACTIVE',
  }) {
    return repository.updateVariant(
      id,
      sku: sku,
      barcode: barcode,
      price: price,
      status: status,
    );
  }
}
