import '../entities/category.dart';
import '../repositories/category_repository.dart';

class UpdateCategory {
  UpdateCategory(this._repository);

  final CategoryRepository _repository;

  Future<Category> call({required String id, String? name, String? status}) {
    return _repository.updateCategory(id: id, name: name, status: status);
  }
}
