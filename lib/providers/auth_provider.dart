import 'package:flutter/material.dart';

import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  bool _isLoggedIn = false;
  String? _token;
  bool _initialized = false;

  bool get isLoggedIn => _isLoggedIn;
  String? get token => _token;
  bool get initialized => _initialized;

  Future<void> init() async {
    _token = await AuthService.getToken();
    _isLoggedIn = _token != null;
    _initialized = true;
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    final success = await AuthService.login(email, password);
    if (success) {
      _token = await AuthService.getToken();
      _isLoggedIn = true;
      _initialized = true;
      notifyListeners();
    }
    return success;
  }

  Future<bool> register(String username, String email, String password) async {
    final success = await AuthService.register(username, email, password);
    if (success) {
      _token = await AuthService.getToken();
      _isLoggedIn = true;
      _initialized = true;
      notifyListeners();
    }
    return success;
  }

  Future<void> logout() async {
    await AuthService.logout();
    _token = null;
    _isLoggedIn = false;
    _initialized = true;
    notifyListeners();
  }
}
