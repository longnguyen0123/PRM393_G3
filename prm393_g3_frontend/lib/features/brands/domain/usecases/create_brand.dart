import '../entities/brand.dart';
import '../repositories/brand_repository.dart';

class CreateBrand {
  CreateBrand(this._repository);

  final BrandRepository _repository;

  Future<Brand> call({required String name, String? status}) {
    return _repository.createBrand(name: name, status: status);
  }
}
