import 'package:flutter/foundation.dart';

import '../core/constants/app_strings.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/service_exception.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }

class AppProvider extends ChangeNotifier {
  AppProvider(this._authService);

  final AuthService _authService;

  AuthStatus _status = AuthStatus.unknown;
  UserModel? _user;
  bool _isLoading = false;
  String? _error;
  int _tabIndex = 0;

  AuthStatus get status => _status;
  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get tabIndex => _tabIndex;
  bool get isAuthenticated => _status == AuthStatus.authenticated;

  Future<void> bootstrap() async {
    if (_status != AuthStatus.unknown) return;
    try {
      _user = await _authService.restoreSession();
      _status = _user == null
          ? AuthStatus.unauthenticated
          : AuthStatus.authenticated;
    } catch (_) {
      _status = AuthStatus.unauthenticated;
    }
    notifyListeners();
  }

  Future<bool> login({
    required String email,
    required String password,
    required bool rememberMe,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _user = await _authService.login(
        email: email,
        password: password,
        rememberMe: rememberMe,
      );
      _status = AuthStatus.authenticated;
      _isLoading = false;
      notifyListeners();
      return true;
    } on ServiceException catch (error) {
      _error = error.message;
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (_) {
      _error = 'Tidak dapat terhubung ke server. Coba lagi.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    await _authService.logout();
    _user = null;
    _status = AuthStatus.unauthenticated;
    _tabIndex = 0;
    notifyListeners();
  }

  void setTab(int index) {
    if (_tabIndex == index) return;
    _tabIndex = index;
    notifyListeners();
  }

  void clearError() {
    if (_error == null) return;
    _error = null;
    notifyListeners();
  }

  void updateProfile({required String name, required String email}) {
    final current = _user;
    if (current == null) return;
    _user = current.copyWith(name: name, email: email);
    notifyListeners();
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
    if (currentPassword != AppStrings.demoPassword) {
      throw const AuthException('Password saat ini tidak sesuai.');
    }
    if (newPassword == currentPassword) {
      throw const AuthException('Password baru harus berbeda.');
    }
  }
}
