import '../../../../core/network/api_client.dart';
import '../models/user_model.dart';

class LoginResult {
  const LoginResult({
    required this.token,
    required this.user,
  });
  final String token;
  final UserModel user;
}

abstract class AuthRemoteDataSource {
  Future<LoginResult> login({required String username, required String password});
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  AuthRemoteDataSourceImpl({required this.apiClient});
  final ApiClient apiClient;

  @override
  Future<LoginResult> login({
    required String username,
    required String password,
  }) async {
    final response = await apiClient.post(
      '/auth/login',
      data: {'username': username.trim(), 'password': password},
    );
    final data = response.data as Map<String, dynamic>;
    final success = data['success'] as bool? ?? false;
    if (!success) {
      final message = data['message'] as String? ?? 'Đăng nhập thất bại';
      throw Exception(message);
    }
    final payload = data['data'] as Map<String, dynamic>;
    final token = payload['token'] as String? ?? '';
    final userJson = payload['user'] as Map<String, dynamic>? ?? {};
    final user = UserModel.fromJson(userJson);
    return LoginResult(token: token, user: user);
  }
}
