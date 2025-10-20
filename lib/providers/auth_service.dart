// lib/providers/auth_service.dart
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService extends ChangeNotifier {
  static const _userKey = 'auth_user_name';
  static const _emailKey = 'auth_user_email';

  bool _isLoggedIn = false;
  String? _userName;
  String? _userEmail;
  bool _isLoading = true;

  bool get isLoggedIn => _isLoggedIn;
  String? get userName => _userName;
  String? get userEmail => _userEmail;
  bool get isLoading => _isLoading;

  AuthService() {
    _loadUser();
  }

  Future<void> _loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey(_userKey)) {
      _userName = prefs.getString(_userKey);
      _userEmail = prefs.getString(_emailKey);
      _isLoggedIn = true;
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    await Future.delayed(const Duration(seconds: 1));
    if (email.isNotEmpty && password.isNotEmpty) {
      _userName = email.split('@').first;
      _userEmail = email;
      _isLoggedIn = true;

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_userKey, _userName!);
      await prefs.setString(_emailKey, _userEmail!);

      notifyListeners();
      return true;
    }
    return false;
  }

  Future<bool> register(String name, String email, String password) async {
    await Future.delayed(const Duration(seconds: 1));
    if (name.isNotEmpty && email.isNotEmpty && password.isNotEmpty) {
      _userName = name;
      _userEmail = email;
      _isLoggedIn = true;

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_userKey, _userName!);
      await prefs.setString(_emailKey, _userEmail!);

      notifyListeners();
      return true;
    }
    return false;
  }

  Future<void> logout() async {
    _isLoggedIn = false;
    _userName = null;
    _userEmail = null;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userKey);
    await prefs.remove(_emailKey);

    notifyListeners();
  }

  // ===== Thêm mới: cập nhật hồ sơ =====
  Future<void> updateProfile(String newName, String newEmail) async {
    await Future.delayed(const Duration(milliseconds: 500));
    _userName = newName;
    _userEmail = newEmail;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, _userName!);
    await prefs.setString(_emailKey, _userEmail!);

    notifyListeners();
  }

  // ===== Thêm mới: đổi mật khẩu (demo) =====
  Future<bool> resetPassword(String oldPassword, String newPassword) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return oldPassword.isNotEmpty && newPassword.isNotEmpty;
  }
}
