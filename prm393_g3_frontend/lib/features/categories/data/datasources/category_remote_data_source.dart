import '../../../../core/network/api_client.dart';
import '../models/category_model.dart';

abstract class CategoryRemoteDataSource {
  Future<List<CategoryModel>> fetchCategories();
  Future<CategoryModel> createCategory({required String name, String? status});
  Future<CategoryModel> updateCategory({required String id, String? name, String? status});
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

  @override
  Future<CategoryModel> createCategory({required String name, String? status}) async {
    final response = await apiClient.post(
      '/categories',
      data: {
        'name': name,
        if (status != null) 'status': status,
      },
    );
    return CategoryModel.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<CategoryModel> updateCategory({required String id, String? name, String? status}) async {
    final data = <String, dynamic>{};
    if (name != null) data['name'] = name;
    if (status != null) data['status'] = status;
    final response = await apiClient.patch('/categories/$id', data: data);
    return CategoryModel.fromJson(response.data as Map<String, dynamic>);
  }
}
