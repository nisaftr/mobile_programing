import 'package:shared_preferences/shared_preferences.dart';

import '../../core/config/app_config.dart';
import '../../core/constants/app_strings.dart';
import '../../models/user_model.dart';
import '../auth_service.dart';
import '../service_exception.dart';
import 'mock_data.dart';

class MockAuthService implements AuthService {
  static const _tokenKey = 'session_token';
  static const _nameKey = 'session_name';
  static const _emailKey = 'session_email';
  static const _roleKey = 'session_role';

  @override
  Future<UserModel> login({
    required String email,
    required String password,
    required bool rememberMe,
  }) async {
    await Future<void>.delayed(AppConfig.mockDelay);
    final normalized = email.trim().toLowerCase();
    if (normalized != AppStrings.demoEmail ||
        password != AppStrings.demoPassword) {
      throw const AuthException(
        'Email atau password salah. Gunakan akun demo yang tersedia.',
      );
    }

    final user = MockData.user;
    if (rememberMe) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_tokenKey, user.token ?? '');
      await prefs.setString(_nameKey, user.name);
      await prefs.setString(_emailKey, user.email);
      await prefs.setString(_roleKey, user.role);
    }
    return user;
  }

  @override
  Future<UserModel?> restoreSession() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_tokenKey);
    if (token == null || token.isEmpty) return null;
    return UserModel(
      id: MockData.user.id,
      name: prefs.getString(_nameKey) ?? MockData.user.name,
      email: prefs.getString(_emailKey) ?? MockData.user.email,
      role: prefs.getString(_roleKey) ?? MockData.user.role,
      token: token,
    );
  }

  @override
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_nameKey);
    await prefs.remove(_emailKey);
    await prefs.remove(_roleKey);
  }
}
