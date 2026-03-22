import '../../domain/entities/user_entity.dart';

class UserModel {
  const UserModel({
    required this.id,
    required this.username,
    required this.fullName,
    required this.role,
    this.branchId,
    this.managedBranchIds,
  });

  final String id;
  final String username;
  final String fullName;
  final String role;
  final String? branchId;
  final List<String>? managedBranchIds;

  factory UserModel.fromJson(Map<String, dynamic> json) {
    List<String>? managed;
    final raw = json['managedBranchIds'];
    if (raw is List) {
      managed = raw.map((e) => e.toString()).toList();
    }
    return UserModel(
      id: json['id'] as String? ?? json['_id']?.toString() ?? '',
      username: json['username'] as String? ?? '',
      fullName: json['fullName'] as String? ?? '',
      role: json['role'] as String? ?? '',
      branchId: json['branchId'] as String?,
      managedBranchIds: managed,
    );
  }

  UserEntity toEntity() => UserEntity(
        id: id,
        username: username,
        fullName: fullName,
        role: role,
        branchId: branchId,
        managedBranchIds: managedBranchIds,
      );
}
