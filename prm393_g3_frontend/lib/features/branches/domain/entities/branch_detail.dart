import 'branch.dart';

class BranchManagerInfo {
  final String id;
  final String username;
  final String fullName;
  final String role;
  final String status;

  const BranchManagerInfo({
    required this.id,
    required this.username,
    required this.fullName,
    required this.role,
    required this.status,
  });
}

class BranchProductLine {
  final int quantity;
  final int reorderLevel;
  final String? variantId;
  final String? sku;
  final String? barcode;
  final int? price;
  final String? variantStatus;
  final String? productId;
  final String? productName;
  final String? productDescription;
  final String? productStatus;

  const BranchProductLine({
    required this.quantity,
    required this.reorderLevel,
    this.variantId,
    this.sku,
    this.barcode,
    this.price,
    this.variantStatus,
    this.productId,
    this.productName,
    this.productDescription,
    this.productStatus,
  });
}

class BranchDetail {
  final Branch branch;
  final BranchManagerInfo? branchManager;
  final List<BranchProductLine> products;

  const BranchDetail({
    required this.branch,
    this.branchManager,
    required this.products,
  });
}
