import 'package:dio/dio.dart';
import '../config/api_config.dart';

class ApiService {
  static final Dio dio = Dio(BaseOptions(
    baseUrl: ApiConfig.apiBaseUrl,
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
    headers: {
      'Accept': 'application/json',
    },
  ));

  // Tạo một instance clone khi cần gắn token
  static Future<Dio> getAuthenticatedDio(String token) async {
    final options = BaseOptions(
      baseUrl: ApiConfig.apiBaseUrl,
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    );
    return Dio(options);
  }
}
