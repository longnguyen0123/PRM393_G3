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
  Future<ProductModel> createProduct({
    required String name,
    required String brandId,
    required String categoryId,
    String? description,
    String status = 'ACTIVE',
  });
  Future<ProductModel> updateProduct(
    String id, {
    String? name,
    String? brandId,
    String? categoryId,
    String? description,
    String? status,
  });
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

  @override
  Future<ProductModel> createProduct({
    required String name,
    required String brandId,
    required String categoryId,
    String? description,
    String status = 'ACTIVE',
  }) async {
    final response = await apiClient.post(
      '/products',
      data: {
        'name': name,
        'brandId': brandId,
        'categoryId': categoryId,
        if (description != null && description.isNotEmpty) 'description': description,
        'status': status,
      },
    );
    return ProductModel.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<ProductModel> updateProduct(
    String id, {
    String? name,
    String? brandId,
    String? categoryId,
    String? description,
    String? status,
  }) async {
    final data = <String, dynamic>{};
    if (name != null) data['name'] = name;
    if (brandId != null) data['brandId'] = brandId;
    if (categoryId != null) data['categoryId'] = categoryId;
    if (description != null) data['description'] = description;
    if (status != null) data['status'] = status;
    final response = await apiClient.patch('/products/$id', data: data);
    return ProductModel.fromJson(response.data as Map<String, dynamic>);
  }
}
