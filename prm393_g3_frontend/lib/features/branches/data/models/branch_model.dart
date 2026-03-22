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
    final rawId = json['_id'];
    final id = rawId is String
        ? rawId
        : (rawId is Map && rawId[r'$oid'] is String)
            ? rawId[r'$oid'] as String
            : rawId?.toString() ?? '';
    return BranchModel(
      id: id,
      name: json['name'] as String? ?? '',
      address: json['address'] as String? ?? '',
      status: json['status'] as String? ?? 'ACTIVE',
      totalItemsInStock: (json['totalItemsInStock'] as num?)?.toInt() ?? 0,
    );
  }
}