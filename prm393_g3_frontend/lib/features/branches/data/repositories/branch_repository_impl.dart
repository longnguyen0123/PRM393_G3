import '../../domain/entities/branch.dart';
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
  Future<Branch> createBranch(Branch branch) async {
    final model = await remoteDataSource.createBranch(
      name: branch.name,
      address: branch.address,
      status: branch.status,
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
    );
    return model;
  }

  @override
  Future<void> deleteBranch(String id) async {
    await remoteDataSource.deleteBranch(id);
  }
}
