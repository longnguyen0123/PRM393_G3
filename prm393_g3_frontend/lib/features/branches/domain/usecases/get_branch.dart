import '../entities/branch.dart';
import '../repositories/branch_repository.dart';

class GetBranches {
  final BranchRepository repository;

  GetBranches(this.repository);

  Future<List<Branch>> call() async {
    return await repository.getBranches();
  }
}