import '../../../../core/network/api_client.dart';
import '../models/branch_model.dart';

class BranchRemoteDataSource {
  final ApiClient apiClient;

  BranchRemoteDataSource(this.apiClient);

  Future<List<BranchModel>> getBranches() async {
    final response = await apiClient.get('/branches');

    final List data = response.data['data'];

    return data.map((e) => BranchModel.fromJson(e)).toList();
  }

  Future<BranchModel> createBranch({
    required String name,
    required String address,
    required String status,
  }) async {
    final response = await apiClient.post(
      '/branches',
      data: {'name': name, 'address': address, 'status': status},
    );

    return BranchModel.fromJson(response.data['data']);
  }
}
