import '../repositories/branch_repository.dart';
import '../entities/branch.dart';

class CreateBranch {
  final BranchRepository repository;

  CreateBranch(this.repository);

  Future<Branch> call(Branch branch) {
    return repository.createBranch(branch);
  }
}