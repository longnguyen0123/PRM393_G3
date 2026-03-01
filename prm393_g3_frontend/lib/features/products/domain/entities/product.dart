import 'package:equatable/equatable.dart';

class Product extends Equatable {
  const Product({
    required this.id,
    required this.name,
    required this.brandId,
    required this.categoryId,
    this.description,
    required this.status,
    this.brandName,
    this.categoryName,
  });

  final String id;
  final String name;
  final String brandId;
  final String categoryId;
  final String? description;
  final String status; // 'ACTIVE' or 'INACTIVE'
  final String? brandName;
  final String? categoryName;

  @override
  List<Object?> get props => [id, name, brandId, categoryId, description, status, brandName, categoryName];
}
