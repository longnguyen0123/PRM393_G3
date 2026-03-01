import '../../domain/entities/brand.dart';

class BrandModel extends Brand {
  const BrandModel({
    required super.id,
    required super.name,
    super.status,
  });

  factory BrandModel.fromJson(Map<String, dynamic> json) {
    return BrandModel(
      id: (json['_id'] ?? json['id']).toString(),
      name: json['name'] as String,
      status: json['status'] as String?,
    );
  }
}
