import '../../domain/entities/user_entity.dart';

class UserModel {
  const UserModel({
    required this.id,
    required this.username,
    required this.fullName,
    required this.role,
    this.branchId,
  });

  final String id;
  final String username;
  final String fullName;
  final String role;
  final String? branchId;

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String? ?? json['_id']?.toString() ?? '',
      username: json['username'] as String? ?? '',
      fullName: json['fullName'] as String? ?? '',
      role: json['role'] as String? ?? '',
      branchId: json['branchId'] as String?,
    );
  }

  UserEntity toEntity() => UserEntity(
        id: id,
        username: username,
        fullName: fullName,
        role: role,
        branchId: branchId,
      );
}
