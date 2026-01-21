import '../../domain/entities/product.dart';
import '../../domain/repositories/product_repository.dart';
import '../datasources/product_remote_data_source.dart';

class ProductRepositoryImpl implements ProductRepository {
  ProductRepositoryImpl({required this.remoteDataSource});

  final ProductRemoteDataSource remoteDataSource;

  @override
  Future<List<Product>> getProducts() async {
    return remoteDataSource.fetchProducts();
  }
}
