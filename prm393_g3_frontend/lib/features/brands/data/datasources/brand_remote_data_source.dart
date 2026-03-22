import '../../../../core/network/api_client.dart';
import '../models/brand_model.dart';

abstract class BrandRemoteDataSource {
  Future<List<BrandModel>> fetchBrands();
  Future<BrandModel> createBrand({required String name, String? status});
  Future<BrandModel> updateBrand({required String id, String? name, String? status});
}

class BrandRemoteDataSourceImpl implements BrandRemoteDataSource {
  BrandRemoteDataSourceImpl({required this.apiClient});

  final ApiClient apiClient;

  @override
  Future<List<BrandModel>> fetchBrands() async {
    final response = await apiClient.get('/brands');
    final data = response.data as List<dynamic>;
    return data.map((item) => BrandModel.fromJson(item as Map<String, dynamic>)).toList();
  }

  @override
  Future<BrandModel> createBrand({required String name, String? status}) async {
    final response = await apiClient.post(
      '/brands',
      data: {
        'name': name,
        if (status != null) 'status': status,
      },
    );
    return BrandModel.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<BrandModel> updateBrand({required String id, String? name, String? status}) async {
    final data = <String, dynamic>{};
    if (name != null) data['name'] = name;
    if (status != null) data['status'] = status;
    final response = await apiClient.patch('/brands/$id', data: data);
    return BrandModel.fromJson(response.data as Map<String, dynamic>);
  }
}
