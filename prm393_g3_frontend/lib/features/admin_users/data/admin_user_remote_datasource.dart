import 'package:dio/dio.dart';

import '../../../core/network/api_client.dart';

String _dioErrorMessage(DioException e) {
  final d = e.response?.data;
  if (d is Map && d['message'] is String) {
    return d['message'] as String;
  }
  return e.message ?? 'Lỗi mạng';
}

class AdminBranchRef {
  const AdminBranchRef({required this.id, required this.name});

  final String id;
  final String name;
}

class AdminBranchManagerRow {
  const AdminBranchManagerRow({
    required this.id,
    required this.username,
    required this.fullName,
    required this.status,
    required this.branches,
  });

  final String id;
  final String username;
  final String fullName;
  final String status;
  final List<AdminBranchRef> branches;
}

class AdminStaffBranch {
  const AdminStaffBranch({
    required this.id,
    required this.name,
    required this.address,
  });

  final String id;
  final String name;
  final String address;
}

class AdminInventoryStaffRow {
  const AdminInventoryStaffRow({
    required this.id,
    required this.username,
    required this.fullName,
    required this.status,
    this.branch,
  });

  final String id;
  final String username;
  final String fullName;
  final String status;
  final AdminStaffBranch? branch;
}

List<AdminBranchRef> _parseBranches(dynamic raw) {
  if (raw is! List) return [];
  final out = <AdminBranchRef>[];
  for (final e in raw) {
    if (e is! Map) continue;
    final m = Map<String, dynamic>.from(e);
    final id = m['id']?.toString() ?? '';
    if (id.isEmpty) continue;
    out.add(
      AdminBranchRef(
        id: id,
        name: m['name'] as String? ?? '',
      ),
    );
  }
  return out;
}

AdminStaffBranch? _parseStaffBranch(dynamic raw) {
  if (raw is! Map) return null;
  final m = Map<String, dynamic>.from(raw);
  final id = m['id']?.toString() ?? '';
  if (id.isEmpty) return null;
  return AdminStaffBranch(
    id: id,
    name: m['name'] as String? ?? '',
    address: m['address'] as String? ?? '',
  );
}

class AdminUserRemoteDataSource {
  AdminUserRemoteDataSource(this._apiClient);

  final ApiClient _apiClient;

  Future<List<AdminBranchManagerRow>> getBranchManagers() async {
    final response = await _apiClient.get('/admin/users/branch-managers');
    final List data = response.data['data'] as List? ?? [];
    return data.map((e) {
      final m = Map<String, dynamic>.from(e as Map);
      return AdminBranchManagerRow(
        id: m['id']?.toString() ?? '',
        username: m['username'] as String? ?? '',
        fullName: m['fullName'] as String? ?? '',
        status: m['status'] as String? ?? '',
        branches: _parseBranches(m['branches']),
      );
    }).toList();
  }

  Future<List<AdminInventoryStaffRow>> getInventoryStaff() async {
    final response = await _apiClient.get('/admin/users/inventory-staff');
    final List data = response.data['data'] as List? ?? [];
    return data.map((e) {
      final m = Map<String, dynamic>.from(e as Map);
      return AdminInventoryStaffRow(
        id: m['id']?.toString() ?? '',
        username: m['username'] as String? ?? '',
        fullName: m['fullName'] as String? ?? '',
        status: m['status'] as String? ?? '',
        branch: _parseStaffBranch(m['branch']),
      );
    }).toList();
  }

  Future<void> updateUserStatus(String userId, String status) async {
    try {
      await _apiClient.patch(
        '/admin/users/$userId/status',
        data: {'status': status},
      );
    } on DioException catch (e) {
      throw Exception(_dioErrorMessage(e));
    }
  }

  Future<void> createUser({
    required String username,
    required String password,
    required String fullName,
    required String role,
    String? branchId,
    List<String>? managedBranchIds,
  }) async {
    try {
      final body = <String, dynamic>{
        'username': username.trim(),
        'password': password,
        'fullName': fullName.trim(),
        'role': role,
      };
      if (branchId != null && branchId.isNotEmpty) {
        body['branchId'] = branchId;
      }
      if (managedBranchIds != null && managedBranchIds.isNotEmpty) {
        body['managedBranchIds'] = managedBranchIds;
      }
      await _apiClient.post('/admin/users', data: body);
    } on DioException catch (e) {
      throw Exception(_dioErrorMessage(e));
    }
  }
}
