import '../../../../core/network/api_client.dart';
import '../models/variant_model.dart';

abstract class VariantRemoteDataSource {
  Future<List<VariantModel>> fetchVariantsByProductId(String productId);
}

class VariantRemoteDataSourceImpl implements VariantRemoteDataSource {
  VariantRemoteDataSourceImpl({required this.apiClient});

  final ApiClient apiClient;

  @override
  Future<List<VariantModel>> fetchVariantsByProductId(String productId) async {
    final response = await apiClient.get('/variants?productId=$productId');
    final data = response.data as List<dynamic>;
    return data.map((item) => VariantModel.fromJson(item as Map<String, dynamic>)).toList();
  }
}
