import '../../../../core/network/api_client.dart';
import '../models/product_model.dart';

abstract class ProductRemoteDataSource {
  Future<List<ProductModel>> fetchProducts();
}

class ProductRemoteDataSourceImpl implements ProductRemoteDataSource {
  ProductRemoteDataSourceImpl({required this.apiClient});

  final ApiClient apiClient;

  @override
  Future<List<ProductModel>> fetchProducts() async {
    final response = await apiClient.get('/products');
    final data = response.data as List<dynamic>;
    return data.map((item) => ProductModel.fromJson(item as Map<String, dynamic>)).toList();
  }
}
