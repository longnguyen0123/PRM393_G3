class Branch {
  final String id;
  final String name;
  final String address;
  final String status;
  final int totalItemsInStock;
  /// Admin bật: Branch Manager được quản lý kho / nhân viên kho tại chi nhánh.
  final bool inventoryDelegatedToManager;

  const Branch({
    required this.id,
    required this.name,
    required this.address,
    required this.status,
    required this.totalItemsInStock,
    this.inventoryDelegatedToManager = false,
  });
}