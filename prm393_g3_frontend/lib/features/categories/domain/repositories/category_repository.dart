import '../entities/category.dart';

abstract class CategoryRepository {
  Future<List<Category>> getCategories();
  Future<Category> createCategory({required String name, String? status});
  Future<Category> updateCategory({required String id, String? name, String? status});
}
