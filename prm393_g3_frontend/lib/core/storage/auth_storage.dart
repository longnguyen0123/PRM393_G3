import 'package:shared_preferences/shared_preferences.dart';

const _keyToken = 'auth_token';
const _keyUserId = 'auth_user_id';
const _keyUsername = 'auth_username';
const _keyFullName = 'auth_full_name';
const _keyRole = 'auth_role';

class AuthStorage {
  AuthStorage(this._prefs);

  final SharedPreferences _prefs;
  String? _token;

  String? get token => _token ?? _prefs.getString(_keyToken);

  Future<void> loadFromPrefs() async {
    _token = _prefs.getString(_keyToken);
  }

  Future<void> saveSession({
    required String token,
    required String userId,
    required String username,
    required String fullName,
    required String role,
  }) async {
    _token = token;
    await _prefs.setString(_keyToken, token);
    await _prefs.setString(_keyUserId, userId);
    await _prefs.setString(_keyUsername, username);
    await _prefs.setString(_keyFullName, fullName);
    await _prefs.setString(_keyRole, role);
  }

  Future<void> clearSession() async {
    _token = null;
    await _prefs.remove(_keyToken);
    await _prefs.remove(_keyUserId);
    await _prefs.remove(_keyUsername);
    await _prefs.remove(_keyFullName);
    await _prefs.remove(_keyRole);
  }

  bool get isLoggedIn => token != null && token!.isNotEmpty;

  String? get savedUserId => _prefs.getString(_keyUserId);
  String? get savedUsername => _prefs.getString(_keyUsername);
  String? get savedFullName => _prefs.getString(_keyFullName);
  String? get savedRole => _prefs.getString(_keyRole);
}
