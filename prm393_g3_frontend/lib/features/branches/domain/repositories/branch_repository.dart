import '../entities/branch.dart';

abstract class BranchRepository {
  Future<List<Branch>> getBranches();
}