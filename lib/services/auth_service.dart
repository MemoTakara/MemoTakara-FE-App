import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart';

class AuthService {
  static SharedPreferences? _prefs;

  // ==== Token ====
  static Future<SharedPreferences> _getPrefs() async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  static Future<void> saveToken(String token) async {
    final prefs = await _getPrefs();
    await prefs.setString("token", token);
  }

  static Future<String?> getToken() async {
    final prefs = await _getPrefs();
    return prefs.getString("token");
  }

  static Future<bool> isLoggedIn() async {
    return (await getToken()) != null;
  }

  static Future<void> logout() async {
    final token = await getToken();
    final prefs = await _getPrefs();

    if (token != null) {
      try {
        await ApiService.post(
          '/logout',
          headers: ApiService.getAuthHeaders(token),
        );
      } catch (e) {
        print('[Logout] Lỗi gọi API: $e');
      }
    }

    await prefs.remove("token");
  }

  // ==== Login ====
  static Future<bool> login(String email, String password) async {
    try {
      final response = await ApiService.post('/login', data: {
        'email': email,
        'password': password,
      });

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final responseData = jsonDecode(response.body);
        final token = responseData['token'];

        if (token != null) {
          await saveToken(token);
          return true;
        }
      }
    } catch (e, stackTrace) {
      print('[Login] Lỗi gọi API: $e');
      print(stackTrace);
    }
    return false;
  }

  // ==== Register ====
  static Future<bool> register(String username, String email, String password) async {
    try {
      final response = await ApiService.post('/register', data: {
        'username': username,
        'email': email,
        'password': password,
        'password_confirmation': password,
      });

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final responseData = jsonDecode(response.body);
        final token = responseData['token'];

        if (token != null) {
          await saveToken(token);
          return true;
        }
      }
    } catch (e, stackTrace) {
      print('[Register] Lỗi gọi API: $e');
      print(stackTrace);
    }
    return false;
  }

  // ==== Get User Info ====
  static Future<Map<String, dynamic>?> getUserInfo() async {
    final token = await getToken();
    if (token == null) return null;

    try {
      final response = await ApiService.get(
        '/users',
        headers: ApiService.getAuthHeaders(token),
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return jsonDecode(response.body);
      }
    } catch (e) {
      print('[User Info] Lỗi: $e');
    }
    return null;
  }
}