import '../../domain/entities/branch_detail.dart';
import 'branch_model.dart';

String _parseId(dynamic v) {
  if (v == null) return '';
  if (v is String) return v;
  if (v is Map) {
    final oid = v[r'$oid'];
    if (oid is String) return oid;
  }
  return v.toString();
}

class BranchDetailModel extends BranchDetail {
  const BranchDetailModel({
    required super.branch,
    super.branchManager,
    required super.products,
  });

  factory BranchDetailModel.fromJson(Map<String, dynamic> json) {
    final branchMap = Map<String, dynamic>.from(json['branch'] as Map);
    final branch = BranchModel.fromJson(branchMap);

    BranchManagerInfo? manager;
    final rawMgr = json['branchManager'];
    if (rawMgr is Map<String, dynamic>) {
      manager = BranchManagerInfo(
        id: _parseId(rawMgr['_id']),
        username: rawMgr['username'] as String? ?? '',
        fullName: rawMgr['fullName'] as String? ?? '',
        role: rawMgr['role'] as String? ?? '',
        status: rawMgr['status'] as String? ?? '',
      );
    }

    final lines = json['inventoryLines'] as List<dynamic>? ?? [];
    final products = lines.map((e) {
      final row = Map<String, dynamic>.from(e as Map);
      final v = row['variant'];
      final p = row['product'];
      Map<String, dynamic>? vm;
      Map<String, dynamic>? pm;
      if (v is Map) vm = Map<String, dynamic>.from(v);
      if (p is Map) pm = Map<String, dynamic>.from(p);

      return BranchProductLine(
        quantity: (row['quantity'] as num?)?.toInt() ?? 0,
        reorderLevel: (row['reorderLevel'] as num?)?.toInt() ?? 0,
        variantId: vm != null ? _parseId(vm['_id']) : null,
        sku: vm?['sku'] as String?,
        barcode: vm?['barcode'] as String?,
        price: (vm?['price'] as num?)?.toInt(),
        variantStatus: vm?['status'] as String?,
        productId: pm != null ? _parseId(pm['_id']) : null,
        productName: pm?['name'] as String?,
        productDescription: pm?['description'] as String?,
        productStatus: pm?['status'] as String?,
      );
    }).toList();

    return BranchDetailModel(
      branch: branch,
      branchManager: manager,
      products: products,
    );
  }
}
