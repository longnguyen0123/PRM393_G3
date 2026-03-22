import '../../domain/entities/branch.dart';
import '../../domain/entities/branch_detail.dart';
import '../../domain/repositories/branch_repository.dart';
import '../datasources/branch_remote_datasource.dart';

class BranchRepositoryImpl implements BranchRepository {
  final BranchRemoteDataSource remoteDataSource;

  BranchRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<Branch>> getBranches() async {
    return await remoteDataSource.getBranches();
  }

  @override
  Future<BranchDetail> getBranchDetail(String id) async {
    return await remoteDataSource.getBranchDetail(id);
  }

  @override
  Future<List<BranchManagerCandidate>> getBranchManagerCandidates(
    String branchId,
  ) async {
    return remoteDataSource.getBranchManagerCandidates(branchId);
  }

  @override
  Future<void> assignBranchManager(
    String branchId,
    String? userId, {
    bool detach = false,
  }) async {
    await remoteDataSource.assignBranchManager(
      branchId,
      userId,
      detach: detach,
    );
  }

  @override
  Future<List<InventoryStaffMember>> getInventoryStaff(String branchId) {
    return remoteDataSource.getInventoryStaff(branchId);
  }

  @override
  Future<InventoryStaffMember> createInventoryStaff(
    String branchId, {
    required String username,
    required String password,
    required String fullName,
  }) {
    return remoteDataSource.createInventoryStaff(
      branchId,
      username: username,
      password: password,
      fullName: fullName,
    );
  }

  @override
  Future<void> deactivateInventoryStaff(String branchId, String userId) {
    return remoteDataSource.deactivateInventoryStaff(branchId, userId);
  }

  @override
  Future<Branch> createBranch(Branch branch) async {
    final model = await remoteDataSource.createBranch(
      name: branch.name,
      address: branch.address,
      status: branch.status,
      inventoryDelegatedToManager: branch.inventoryDelegatedToManager,
    );
    return model;
  }

  @override
  Future<Branch> updateBranch(Branch branch) async {
    final model = await remoteDataSource.updateBranch(
      id: branch.id,
      name: branch.name,
      address: branch.address,
      status: branch.status,
      inventoryDelegatedToManager: branch.inventoryDelegatedToManager,
    );
    return model;
  }
}
