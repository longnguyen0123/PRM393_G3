import '../../domain/entities/category.dart';
import '../../domain/repositories/category_repository.dart';
import '../datasources/category_remote_data_source.dart';

class CategoryRepositoryImpl implements CategoryRepository {
  CategoryRepositoryImpl({required this.remoteDataSource});

  final CategoryRemoteDataSource remoteDataSource;

  @override
  Future<List<Category>> getCategories() async {
    return remoteDataSource.fetchCategories();
  }

  @override
  Future<Category> createCategory({required String name, String? status}) {
    return remoteDataSource.createCategory(name: name, status: status);
  }

  @override
  Future<Category> updateCategory({required String id, String? name, String? status}) {
    return remoteDataSource.updateCategory(id: id, name: name, status: status);
  }
}
