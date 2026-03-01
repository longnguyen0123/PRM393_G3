import '../../../../core/network/api_client.dart';
import '../models/product_model.dart';

abstract class ProductRemoteDataSource {
  Future<List<ProductModel>> fetchProducts({
    String? brandId,
    String? categoryId,
    String? search,
  });
  Future<ProductModel> fetchProductById(String id);
  Future<List<ProductModel>> fetchProductsByBrand(String brandId);
  Future<List<ProductModel>> fetchProductsByCategory(String categoryId);
  Future<List<ProductModel>> searchProducts(String query);
}

class ProductRemoteDataSourceImpl implements ProductRemoteDataSource {
  ProductRemoteDataSourceImpl({required this.apiClient});

  final ApiClient apiClient;

  @override
  Future<List<ProductModel>> fetchProducts({
    String? brandId,
    String? categoryId,
    String? search,
  }) async {
    final queryParams = <String, String>{};
    if (brandId != null && brandId.isNotEmpty) {
      queryParams['brandId'] = brandId;
    }
    if (categoryId != null && categoryId.isNotEmpty) {
      queryParams['categoryId'] = categoryId;
    }
    if (search != null && search.isNotEmpty) {
      queryParams['search'] = search;
    }

    final queryString = queryParams.isEmpty
        ? ''
        : '?${queryParams.entries.map((e) => '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}').join('&')}';

    final response = await apiClient.get('/products$queryString');
    final data = response.data as List<dynamic>;
    return data.map((item) => ProductModel.fromJson(item as Map<String, dynamic>)).toList();
  }

  @override
  Future<ProductModel> fetchProductById(String id) async {
    final response = await apiClient.get('/products/$id');
    return ProductModel.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<List<ProductModel>> fetchProductsByBrand(String brandId) async {
    final response = await apiClient.get('/products?brandId=$brandId');
    final data = response.data as List<dynamic>;
    return data.map((item) => ProductModel.fromJson(item as Map<String, dynamic>)).toList();
  }

  @override
  Future<List<ProductModel>> fetchProductsByCategory(String categoryId) async {
    final response = await apiClient.get('/products?categoryId=$categoryId');
    final data = response.data as List<dynamic>;
    return data.map((item) => ProductModel.fromJson(item as Map<String, dynamic>)).toList();
  }

  @override
  Future<List<ProductModel>> searchProducts(String query) async {
    final response = await apiClient.get('/products?search=$query');
    final data = response.data as List<dynamic>;
    return data.map((item) => ProductModel.fromJson(item as Map<String, dynamic>)).toList();
  }
}
