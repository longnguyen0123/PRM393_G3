import 'package:dio/dio.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';
import '../../../../core/storage/auth_storage.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.authStorage,
  });

  final AuthRemoteDataSource remoteDataSource;
  final AuthStorage authStorage;

  @override
  Future<({String token, UserEntity user})> login({
    required String username,
    required String password,
  }) async {
    try {
      final result = await remoteDataSource.login(
        username: username,
        password: password,
      );
      await authStorage.saveSession(
        token: result.token,
        userId: result.user.id,
        username: result.user.username,
        fullName: result.user.fullName,
        role: result.user.role,
      );
      return (token: result.token, user: result.user.toEntity());
    } on DioException catch (e) {
      final message = e.response?.data is Map
          ? (e.response!.data as Map)['message'] as String?
          : null;
      throw Exception(message ?? e.message ?? 'Đăng nhập thất bại');
    }
  }

  @override
  Future<void> logout() async {
    await authStorage.clearSession();
  }

  @override
  Future<bool> hasStoredSession() async {
    await authStorage.loadFromPrefs();
    return authStorage.isLoggedIn;
  }

  @override
  UserEntity? getStoredUser() {
    if (!authStorage.isLoggedIn) return null;
    final id = authStorage.savedUserId ?? '';
    final username = authStorage.savedUsername ?? '';
    final fullName = authStorage.savedFullName ?? '';
    final role = authStorage.savedRole ?? '';
    return UserEntity(id: id, username: username, fullName: fullName, role: role);
  }
}
