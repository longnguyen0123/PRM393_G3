import '../entities/product.dart';

abstract class ProductRepository {
  Future<List<Product>> getProducts({
    String? brandId,
    String? categoryId,
    String? search,
  });
  Future<Product> getProductById(String id);
  Future<List<Product>> getProductsByBrand(String brandId);
  Future<List<Product>> getProductsByCategory(String categoryId);
  Future<List<Product>> searchProducts(String query);
  Future<Product> createProduct({
    required String name,
    required String brandId,
    required String categoryId,
    String? description,
    String status = 'ACTIVE',
  });
  Future<Product> updateProduct(
    String id, {
    String? name,
    String? brandId,
    String? categoryId,
    String? description,
    String? status,
  });
}
