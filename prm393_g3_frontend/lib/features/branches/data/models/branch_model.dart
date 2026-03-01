import '../../domain/entities/branch.dart';

class BranchModel extends Branch {
  const BranchModel({
    required super.id,
    required super.name,
    required super.address,
    required super.status,
    required super.totalItemsInStock,
  });

  factory BranchModel.fromJson(Map<String, dynamic> json) {
    return BranchModel(
      id: json['_id'],
      name: json['name'],
      address: json['address'],
      status: json['status'],
      totalItemsInStock: json['totalItemsInStock'] ?? 0,
    );
  }
}