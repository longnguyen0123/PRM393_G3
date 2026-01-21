import '../../domain/entities/product.dart';

class ProductModel extends Product {
  const ProductModel({
    required super.id,
    required super.name,
    required super.price,
    required super.stock,
    required super.storeId,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: (json['_id'] ?? json['id']).toString(),
      name: json['name'] as String,
      price: (json['price'] as num),
      stock: json['stock'] as int,
      storeId: json['storeId'].toString(),
    );
  }
}
