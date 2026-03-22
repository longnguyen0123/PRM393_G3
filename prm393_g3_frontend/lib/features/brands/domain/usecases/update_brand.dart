import '../entities/brand.dart';
import '../repositories/brand_repository.dart';

class UpdateBrand {
  UpdateBrand(this._repository);

  final BrandRepository _repository;

  Future<Brand> call({required String id, String? name, String? status}) {
    return _repository.updateBrand(id: id, name: name, status: status);
  }
}
