import 'branch.dart';

/// Ứng viên quản lý (role BRANCH_MANAGER) để gán vào chi nhánh.
class BranchManagerCandidate {
  final String id;
  final String username;
  final String fullName;
  /// Các chi nhánh user này đang quản lý (managedBranchIds + legacy branchId).
  final List<String> assignedBranchIds;

  const BranchManagerCandidate({
    required this.id,
    required this.username,
    required this.fullName,
    this.assignedBranchIds = const [],
  });
}

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

class InventoryStaffMember {
  final String id;
  final String username;
  final String fullName;
  final String role;
  final String status;

  const InventoryStaffMember({
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
  final List<BranchManagerInfo> branchManagers;
  final List<BranchProductLine> products;

  const BranchDetail({
    required this.branch,
    this.branchManagers = const [],
    required this.products,
  });
}
