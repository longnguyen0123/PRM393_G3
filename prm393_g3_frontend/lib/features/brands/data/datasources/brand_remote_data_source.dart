import '../../../../core/network/api_client.dart';
import '../models/brand_model.dart';

abstract class BrandRemoteDataSource {
  Future<List<BrandModel>> fetchBrands();
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
}
