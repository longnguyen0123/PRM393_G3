import '../entities/category.dart';
import '../repositories/category_repository.dart';

class GetCategoriesUseCase {
  GetCategoriesUseCase({required this.repository});

  final CategoryRepository repository;

  Future<List<Category>> call() {
    return repository.getCategories();
  }
}
