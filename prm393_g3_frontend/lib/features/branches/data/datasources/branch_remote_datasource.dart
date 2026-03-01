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
}