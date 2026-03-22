import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  const UserEntity({
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

  @override
  List<Object?> get props =>
      [id, username, fullName, role, branchId, managedBranchIds];
}
