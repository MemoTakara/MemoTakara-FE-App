import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart';

class AuthService {
  static final Dio dio = ApiService.dio;

  // ==== Token ====
  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("token", token);
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("token");
  }

  static Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null;
  }

  static Future<void> logout() async {
    final token = await getToken();
    final prefs = await SharedPreferences.getInstance();

    if (token != null) {
      try {
        final authDio = await ApiService.getAuthenticatedDio(token);
        await authDio.post('/logout');
      } catch (e) {
        print('Lỗi khi gọi API logout: $e');
        // Không cần throw, tiếp tục xóa token
      }
    }

    await prefs.remove("token");
  }

  // ==== Login ====
  static Future<bool> login(String email, String password) async {
    try {
      final response = await dio.post('/login', data: {
        'email': email,
        'password': password,
      });

      if (response.statusCode == 200 && response.data['token'] != null) {
        await saveToken(response.data['token']);
        return true;
      }
    } catch (e, stackTrace) {
      print('Lỗi khi gọi API login: $e');
      print('Stacktrace: $stackTrace');
    }
    return false;
  }

  // ==== Register ====
  static Future<bool> register(String username, String email, String password) async {
    try {
      final response = await dio.post('/register', data: {
        'username': username,
        'email': email,
        'password': password,
        'password_confirmation': password,
      });
      print('Status code: ${response.statusCode}');
      print('Phản hồi từ API: ${response.data}');

      if (response.statusCode! >= 200 &&
          response.statusCode! < 300 &&
          response.data['token'] != null) {
        await saveToken(response.data['token']);
        return true;
      }
    } catch (e, stackTrace) {
      print('Lỗi khi gọi API register: $e');
      print('Stacktrace: $stackTrace');
    }
    return false;
  }

  // ==== Get User Info ====
  static Future<Response?> getUserInfo() async {
    final token = await getToken();
    if (token == null) return null;

    try {
      final authDio = await ApiService.getAuthenticatedDio(token);
      return await authDio.get('/users');
    } catch (e) {
      print('Lỗi khi lấy thông tin người dùng: $e');
      return null;
    }
  }
}
