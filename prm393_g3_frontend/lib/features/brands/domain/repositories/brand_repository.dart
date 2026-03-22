import '../entities/brand.dart';

abstract class BrandRepository {
  Future<List<Brand>> getBrands();
  Future<Brand> createBrand({required String name, String? status});
  Future<Brand> updateBrand({required String id, String? name, String? status});
}
