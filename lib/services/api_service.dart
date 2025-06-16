import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';

class ApiService {
  static const Duration timeout = Duration(seconds: 10);

  static Map<String, String> get defaultHeaders => {
    'Accept': 'application/json',
    'Content-Type': 'application/json',
  };

  // GET request
  static Future<http.Response> get(String endpoint, {Map<String, String>? headers}) async {
    final uri = Uri.parse('${ApiConfig.apiBaseUrl}$endpoint');
    final finalHeaders = {...defaultHeaders, ...?headers};

    return await http.get(uri, headers: finalHeaders).timeout(timeout);
  }

  // POST request
  static Future<http.Response> post(String endpoint, {
    Map<String, dynamic>? data,
    Map<String, String>? headers,
  }) async {
    final uri = Uri.parse('${ApiConfig.apiBaseUrl}$endpoint');
    final finalHeaders = {...defaultHeaders, ...?headers};

    return await http.post(
      uri,
      headers: finalHeaders,
      body: data != null ? jsonEncode(data) : null,
    ).timeout(timeout);
  }

  // PUT request
  static Future<http.Response> put(String endpoint, {
    Map<String, dynamic>? data,
    Map<String, String>? headers,
  }) async {
    final uri = Uri.parse('${ApiConfig.apiBaseUrl}$endpoint');
    final finalHeaders = {...defaultHeaders, ...?headers};

    return await http.put(
      uri,
      headers: finalHeaders,
      body: data != null ? jsonEncode(data) : null,
    ).timeout(timeout);
  }

  // DELETE request
  static Future<http.Response> delete(String endpoint, {Map<String, String>? headers}) async {
    final uri = Uri.parse('${ApiConfig.apiBaseUrl}$endpoint');
    final finalHeaders = {...defaultHeaders, ...?headers};

    return await http.delete(uri, headers: finalHeaders).timeout(timeout);
  }

  // Helper method để tạo headers có Authorization
  static Map<String, String> getAuthHeaders(String token) {
    return {
      ...defaultHeaders,
      'Authorization': 'Bearer $token',
    };
  }
}