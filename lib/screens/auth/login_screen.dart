import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:MemoTakara/services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool isLoading = false;

  void _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    final success = await AuthService.login(email, password);

    setState(() => isLoading = false);

    if (success) {
      if (!mounted) return;
      context.go('/'); // Điều hướng về trang chủ
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đăng nhập thất bại. Vui lòng kiểm tra lại email và mật khẩu.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Đăng nhập')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (value) => value == null || value.isEmpty
                    ? 'Vui lòng nhập email'
                    : null,
              ),
              TextFormField(
                controller: passwordController,
                decoration: const InputDecoration(labelText: 'Mật khẩu'),
                obscureText: true,
                validator: (value) => value == null || value.isEmpty
                    ? 'Vui lòng nhập mật khẩu'
                    : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: isLoading ? null : _handleLogin,
                child: isLoading
                    ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
                    : const Text('Đăng nhập'),
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () {
                  context.go('/register');
                },
                child: const Text('Chưa có tài khoản? Đăng ký'),
              )
            ],
          ),
        ),
      ),
    );
  }
}
