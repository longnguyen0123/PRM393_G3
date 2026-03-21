import '../repositories/branch_repository.dart';

class DeleteBranch {
  final BranchRepository repository;

  DeleteBranch(this.repository);

  Future<void> call(String id) {
    return repository.deleteBranch(id);
  }
}
