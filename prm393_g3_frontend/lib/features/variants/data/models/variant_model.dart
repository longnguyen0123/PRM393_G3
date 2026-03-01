import '../../domain/entities/variant.dart';

class VariantModel extends Variant {
  const VariantModel({
    required super.id,
    required super.productId,
    required super.sku,
    super.barcode,
    required super.price,
    required super.status,
    super.variantName,
  });

  factory VariantModel.fromJson(Map<String, dynamic> json) {
    return VariantModel(
      id: (json['_id'] ?? json['id']).toString(),
      productId: json['productId'] != null
          ? (json['productId'] is Map
              ? json['productId']['_id']?.toString() ?? json['productId']['id']?.toString() ?? ''
              : json['productId'].toString())
          : '',
      sku: json['sku'] as String,
      barcode: json['barcode'] as String?,
      price: (json['price'] as num),
      status: json['status'] as String? ?? 'ACTIVE',
      variantName: json['name'] as String?,
    );
  }
}
