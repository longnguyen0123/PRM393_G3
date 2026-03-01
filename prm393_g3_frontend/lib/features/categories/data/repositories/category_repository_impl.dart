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
}
