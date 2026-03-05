import '../repositories/branch_repository.dart';
import '../entities/branch.dart';

class UpdateBranch {
  final BranchRepository repository;

  UpdateBranch(this.repository);

  Future<Branch> call(Branch branch) {
    return repository.updateBranch(branch);
  }
}
