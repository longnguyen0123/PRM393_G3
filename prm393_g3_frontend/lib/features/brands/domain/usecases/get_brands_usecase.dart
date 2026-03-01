import '../entities/brand.dart';
import '../repositories/brand_repository.dart';

class GetBrandsUseCase {
  GetBrandsUseCase({required this.repository});

  final BrandRepository repository;

  Future<List<Brand>> call() {
    return repository.getBrands();
  }
}
