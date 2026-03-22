import '../entities/branch.dart';
import '../entities/branch_detail.dart';

abstract class BranchRepository {
  Future<List<Branch>> getBranches();
  Future<BranchDetail> getBranchDetail(String id);
  Future<Branch> createBranch(Branch branch);
  Future<Branch> updateBranch(Branch branch);
  Future<void> deleteBranch(String id);
}

