import '../entities/user_entity.dart';

abstract class AuthRepository {
  Future<({String token, UserEntity user})> login({
    required String username,
    required String password,
  });
  Future<void> logout();
  Future<bool> hasStoredSession();
  UserEntity? getStoredUser();
}
