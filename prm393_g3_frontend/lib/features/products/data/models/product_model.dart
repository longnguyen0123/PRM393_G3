import '../../domain/entities/product.dart';

class ProductModel extends Product {
  const ProductModel({
    required super.id,
    required super.name,
    required super.brandId,
    required super.categoryId,
    super.description,
    required super.status,
    super.brandName,
    super.categoryName,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: (json['_id'] ?? json['id']).toString(),
      name: json['name'] as String,
      brandId: json['brandId'] != null 
          ? (json['brandId'] is Map 
              ? json['brandId']['_id']?.toString() ?? json['brandId']['id']?.toString() ?? ''
              : json['brandId'].toString())
          : '',
      categoryId: json['categoryId'] != null
          ? (json['categoryId'] is Map
              ? json['categoryId']['_id']?.toString() ?? json['categoryId']['id']?.toString() ?? ''
              : json['categoryId'].toString())
          : '',
      description: json['description'] as String?,
      status: json['status'] as String? ?? 'ACTIVE',
      brandName: json['brandId'] is Map ? json['brandId']['name'] as String? : null,
      categoryName: json['categoryId'] is Map ? json['categoryId']['name'] as String? : null,
    );
  }
}
