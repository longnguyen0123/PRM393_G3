import '../entities/branch.dart';

abstract class BranchRepository {
  Future<List<Branch>> getBranches();
  Future<Branch> createBranch(Branch branch);
}

