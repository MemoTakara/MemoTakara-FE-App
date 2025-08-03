import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'dart:convert';

import '../../providers/auth_provider.dart';
import '../../services/auth_service.dart';
import '../../services/user_service.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({super.key});

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();

  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _loadingUpdate = false;
  bool _loadingPassword = false;
  bool _loadingInitial = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final token = authProvider.token;
    if (token == null) {
      setState(() => _loadingInitial = false);
      return;
    };

    final userData = await AuthService.getUserInfo();
    if (userData != null) {
      final user = userData['data'];
      if (user == null || user is! Map<String, dynamic>) {
        setState(() => _loadingInitial = false);
        return;
      }

      setState(() {
        _nameController.text = user['name'] ?? '';
        _usernameController.text = user['username'] ?? '';
        _emailController.text = user['email'] ?? '';
        _loadingInitial = false;
      });
    } else {
      setState(() => _loadingInitial = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cài đặt'),
        automaticallyImplyLeading: false,
        actions: [
          if (authProvider.isLoggedIn)
            IconButton(
              icon: const Icon(Icons.logout, color: Colors.white),
              onPressed: () async {
                try {
                  await authProvider.logout();
                  context.go('/auth/login');
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Đăng xuất thất bại: $e')),
                  );
                }
              },
              tooltip: 'Đăng xuất',
            ),
        ],
      ),
      body: _loadingInitial
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Cập nhật thông tin cá nhân', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Tên'),
              ),

              const SizedBox(height: 12),
              TextFormField(
                controller: _usernameController,
                decoration: const InputDecoration(labelText: 'Tên đăng nhập'),
              ),

              const SizedBox(height: 12),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
              ),

              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: _loadingUpdate ? null : () async {
                  final token = authProvider.token;
                  if (token == null) return;
                  setState(() => _loadingUpdate = true);
                  try {
                    await UserService().updateAccount(
                      token: token,
                      name: _nameController.text.trim().isEmpty ? null : _nameController.text.trim(),
                      username: _usernameController.text.trim().isEmpty ? null : _usernameController.text.trim(),
                      email: _emailController.text.trim().isEmpty ? null : _emailController.text.trim(),
                    );
                    await _loadUserData();
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Cập nhật thành công')));
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi cập nhật: $e')));
                  } finally {
                    setState(() => _loadingUpdate = false);
                  }
                },
                child: _loadingUpdate ? const CircularProgressIndicator() : const Text('Lưu thông tin'),
              ),

              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 16),

              const Text('Đổi mật khẩu', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              TextFormField(
                controller: _oldPasswordController,
                decoration: const InputDecoration(labelText: 'Mật khẩu hiện tại'),
                obscureText: true,
              ),

              const SizedBox(height: 12),
              TextFormField(
                controller: _newPasswordController,
                decoration: const InputDecoration(labelText: 'Mật khẩu mới'),
                obscureText: true,
              ),

              const SizedBox(height: 12),
              TextFormField(
                controller: _confirmPasswordController,
                decoration: const InputDecoration(labelText: 'Xác nhận mật khẩu mới'),
                obscureText: true,
              ),

              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: _loadingPassword ? null : () async {
                  final token = authProvider.token;
                  if (token == null) return;

                  if (_newPasswordController.text != _confirmPasswordController.text) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Mật khẩu xác nhận không khớp')));
                    return;
                  }

                  setState(() => _loadingPassword = true);
                  try {
                    await UserService().changePassword(
                      oldPassword: _oldPasswordController.text.trim(),
                      newPassword: _newPasswordController.text.trim(),
                      confirmPassword: _confirmPasswordController.text.trim(),
                      token: token,
                    );
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đổi mật khẩu thành công')));
                    _oldPasswordController.clear();
                    _newPasswordController.clear();
                    _confirmPasswordController.clear();
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi đổi mật khẩu: $e')));
                  } finally {
                    setState(() => _loadingPassword = false);
                  }
                },
                child: _loadingPassword ? const CircularProgressIndicator() : const Text('Đổi mật khẩu'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}
