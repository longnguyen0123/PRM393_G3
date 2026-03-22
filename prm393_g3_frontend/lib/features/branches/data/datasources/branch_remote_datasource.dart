import '../../../../core/network/api_client.dart';
import '../../domain/entities/branch_detail.dart';
import '../models/branch_detail_model.dart';
import '../models/branch_model.dart';

String _parseMongoId(dynamic v) {
  if (v == null) return '';
  if (v is String) return v;
  if (v is Map) {
    final oid = v[r'$oid'];
    if (oid is String) return oid;
  }
  return v.toString();
}

List<String> _parseIdList(dynamic raw) {
  if (raw is! List) return [];
  return raw
      .map((x) => _parseMongoId(x))
      .where((s) => s.isNotEmpty)
      .toList();
}

class BranchRemoteDataSource {
  final ApiClient apiClient;

  BranchRemoteDataSource(this.apiClient);

  Future<List<BranchModel>> getBranches() async {
    final response = await apiClient.get('/branches');

    final List data = response.data['data'];

    return data.map((e) => BranchModel.fromJson(e)).toList();
  }

  Future<BranchDetailModel> getBranchDetail(String id) async {
    final response = await apiClient.get('/branches/$id/detail');
    final data = response.data['data'] as Map<String, dynamic>;
    return BranchDetailModel.fromJson(data);
  }

  Future<List<BranchManagerCandidate>> getBranchManagerCandidates(
    String branchId,
  ) async {
    final response =
        await apiClient.get('/branches/$branchId/manager-candidates');
    final List data = response.data['data'] as List? ?? [];
    return data.map((e) {
      final m = Map<String, dynamic>.from(e as Map);
      final ids = _parseIdList(m['managedBranchIds']);
      final legacy = m['branchId'];
      if (legacy != null) {
        final s = _parseMongoId(legacy);
        if (s.isNotEmpty && !ids.contains(s)) {
          ids.add(s);
        }
      }
      return BranchManagerCandidate(
        id: _parseMongoId(m['_id']),
        username: m['username'] as String? ?? '',
        fullName: m['fullName'] as String? ?? '',
        assignedBranchIds: ids,
      );
    }).toList();
  }

  Future<void> assignBranchManager(
    String branchId,
    String? userId, {
    bool detach = false,
  }) async {
    final Map<String, dynamic> body;
    if (detach && userId != null) {
      body = {'userId': userId, 'detach': true};
    } else if (userId != null) {
      body = {'userId': userId};
    } else {
      body = {'userId': null};
    }
    await apiClient.patch(
      '/branches/$branchId/branch-manager',
      data: body,
    );
  }

  Future<List<InventoryStaffMember>> getInventoryStaff(String branchId) async {
    final response = await apiClient.get('/branches/$branchId/inventory-staff');
    final List data = response.data['data'] as List? ?? [];
    return data.map((e) {
      final m = Map<String, dynamic>.from(e as Map);
      return InventoryStaffMember(
        id: _parseMongoId(m['_id']),
        username: m['username'] as String? ?? '',
        fullName: m['fullName'] as String? ?? '',
        role: m['role'] as String? ?? '',
        status: m['status'] as String? ?? '',
      );
    }).toList();
  }

  Future<InventoryStaffMember> createInventoryStaff(
    String branchId, {
    required String username,
    required String password,
    required String fullName,
  }) async {
    final response = await apiClient.post(
      '/branches/$branchId/inventory-staff',
      data: {
        'username': username.trim(),
        'password': password,
        'fullName': fullName.trim(),
      },
    );
    final m = Map<String, dynamic>.from(response.data['data'] as Map);
    return InventoryStaffMember(
      id: _parseMongoId(m['_id']),
      username: m['username'] as String? ?? '',
      fullName: m['fullName'] as String? ?? '',
      role: m['role'] as String? ?? '',
      status: m['status'] as String? ?? '',
    );
  }

  Future<void> deactivateInventoryStaff(String branchId, String userId) async {
    await apiClient.delete('/branches/$branchId/inventory-staff/$userId');
  }

  Future<BranchModel> createBranch({
    required String name,
    required String address,
    required String status,
    bool inventoryDelegatedToManager = false,
  }) async {
    final response = await apiClient.post(
      '/branches',
      data: {
        'name': name,
        'address': address,
        'status': status,
        'inventoryDelegatedToManager': inventoryDelegatedToManager,
      },
    );

    return BranchModel.fromJson(response.data['data']);
  }

  Future<BranchModel> updateBranch({
    required String id,
    required String name,
    required String address,
    required String status,
    required bool inventoryDelegatedToManager,
  }) async {
    final response = await apiClient.put(
      '/branches/$id',
      data: {
        'name': name,
        'address': address,
        'status': status,
        'inventoryDelegatedToManager': inventoryDelegatedToManager,
      },
    );

    return BranchModel.fromJson(response.data['data']);
  }

  Future<void> deleteBranch(String id) async {
    await apiClient.delete('/branches/$id');
  }
}
