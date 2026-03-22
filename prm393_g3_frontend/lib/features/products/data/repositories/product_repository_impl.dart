import '../../domain/entities/product.dart';
import '../../domain/repositories/product_repository.dart';
import '../datasources/product_remote_data_source.dart';

class ProductRepositoryImpl implements ProductRepository {
  ProductRepositoryImpl({required this.remoteDataSource});

  final ProductRemoteDataSource remoteDataSource;

  @override
  Future<List<Product>> getProducts({
    String? brandId,
    String? categoryId,
    String? search,
  }) async {
    return remoteDataSource.fetchProducts(
      brandId: brandId,
      categoryId: categoryId,
      search: search,
    );
  }

  @override
  Future<Product> getProductById(String id) async {
    return remoteDataSource.fetchProductById(id);
  }

  @override
  Future<List<Product>> getProductsByBrand(String brandId) async {
    return remoteDataSource.fetchProductsByBrand(brandId);
  }

  @override
  Future<List<Product>> getProductsByCategory(String categoryId) async {
    return remoteDataSource.fetchProductsByCategory(categoryId);
  }

  @override
  Future<List<Product>> searchProducts(String query) async {
    return remoteDataSource.searchProducts(query);
  }

  @override
  Future<Product> createProduct({
    required String name,
    required String brandId,
    required String categoryId,
    String? description,
    String status = 'ACTIVE',
  }) {
    return remoteDataSource.createProduct(
      name: name,
      brandId: brandId,
      categoryId: categoryId,
      description: description,
      status: status,
    );
  }

  @override
  Future<Product> updateProduct(
    String id, {
    String? name,
    String? brandId,
    String? categoryId,
    String? description,
    String? status,
  }) {
    return remoteDataSource.updateProduct(
      id,
      name: name,
      brandId: brandId,
      categoryId: categoryId,
      description: description,
      status: status,
    );
  }
}
