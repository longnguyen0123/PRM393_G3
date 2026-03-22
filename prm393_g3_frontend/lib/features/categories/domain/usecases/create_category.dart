import '../entities/category.dart';
import '../repositories/category_repository.dart';

class CreateCategory {
  CreateCategory(this._repository);

  final CategoryRepository _repository;

  Future<Category> call({required String name, String? status}) {
    return _repository.createCategory(name: name, status: status);
  }
}
