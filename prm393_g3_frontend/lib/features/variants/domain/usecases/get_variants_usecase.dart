import '../entities/variant.dart';
import '../repositories/variant_repository.dart';

class GetVariantsUseCase {
  GetVariantsUseCase({required this.repository});

  final VariantRepository repository;

  Future<List<Variant>> call(String productId) {
    return repository.getVariantsByProductId(productId);
  }
}
