import '../../../../core/network/api_client.dart';
import '../models/category_model.dart';

abstract class CategoryRemoteDataSource {
  Future<List<CategoryModel>> fetchCategories();
}

class CategoryRemoteDataSourceImpl implements CategoryRemoteDataSource {
  CategoryRemoteDataSourceImpl({required this.apiClient});

  final ApiClient apiClient;

  @override
  Future<List<CategoryModel>> fetchCategories() async {
    final response = await apiClient.get('/categories');
    final data = response.data as List<dynamic>;
    return data.map((item) => CategoryModel.fromJson(item as Map<String, dynamic>)).toList();
  }
}
