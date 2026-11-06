import '../models/user_model.dart';

abstract class AuthService {
  Future<UserModel> login({
    required String email,
    required String password,
    required bool rememberMe,
  });

  Future<UserModel?> restoreSession();

  Future<void> logout();
}
