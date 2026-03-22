import '../entities/branch.dart';
import '../entities/branch_detail.dart';

abstract class BranchRepository {
  Future<List<Branch>> getBranches();
  Future<BranchDetail> getBranchDetail(String id);
  Future<List<BranchManagerCandidate>> getBranchManagerCandidates(String branchId);
  /// [userId] null: gỡ mọi quản lý khỏi chi nhánh. [detach]: gỡ một user khỏi chi nhánh.
  Future<void> assignBranchManager(
    String branchId,
    String? userId, {
    bool detach = false,
  });
  Future<List<InventoryStaffMember>> getInventoryStaff(String branchId);
  Future<InventoryStaffMember> createInventoryStaff(
    String branchId, {
    required String username,
    required String password,
    required String fullName,
  });
  Future<void> deactivateInventoryStaff(String branchId, String userId);
  Future<Branch> createBranch(Branch branch);
  Future<Branch> updateBranch(Branch branch);
  Future<void> deleteBranch(String id);
}
