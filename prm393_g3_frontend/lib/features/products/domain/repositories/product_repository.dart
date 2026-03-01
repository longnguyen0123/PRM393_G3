import '../entities/product.dart';

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
}
