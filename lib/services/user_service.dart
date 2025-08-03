import 'dart:convert';

import 'package:flutter/cupertino.dart';

import 'api_service.dart';

class UserService {
  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
    required String confirmPassword,
    required String token,
  }) async {
    final response = await ApiService.post(
      '/reset-password',
      headers: ApiService.getAuthHeaders(token),
      data: {
        'old_password': oldPassword,
        'new_password': newPassword,
        'new_password_confirmation': confirmPassword,
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      debugPrint('Đổi mật khẩu thành công: ${data['message']}');
    } else {
      final error = jsonDecode(response.body);
      debugPrint('Lỗi đổi mật khẩu: ${error['message']}');
      throw Exception(error['message']);
    }
  }

  Future<void> updateAccount({
    required String token,
    String? name,
    String? username,
    String? email,
  }) async {
    final Map<String, dynamic> body = {};

    if (name != null) body['name'] = name;
    if (username != null) body['username'] = username;
    if (email != null) body['email'] = email;

    final response = await ApiService.post(
      '/users/updateAccount',
      headers: ApiService.getAuthHeaders(token),
      data: body,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      debugPrint('Cập nhật tài khoản thành công: ${data['message']}');
    } else {
      final error = jsonDecode(response.body);
      debugPrint('Lỗi cập nhật tài khoản: ${error['message']}');
      throw Exception(error['message']);
    }
  }
}
