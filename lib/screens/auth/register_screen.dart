import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../services/auth_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final usernameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmController = TextEditingController();
  bool isLoading = false;

  void _handleRegister() async {
    final username = usernameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text;
    final confirmPassword = confirmController.text;

    if (username.isEmpty || email.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      _showError("Vui lòng điền đầy đủ thông tin.");
      return;
    }

    if (password != confirmPassword) {
      _showError("Mật khẩu không khớp.");
      return;
    }

    setState(() => isLoading = true);
    final success = await AuthService.register(username, email, password);
    setState(() => isLoading = false);

    if (success) {
      context.go('/');
    } else {
      _showError("Đăng ký thất bại. Vui lòng thử lại.");
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Đăng ký')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(controller: usernameController, decoration: const InputDecoration(labelText: 'Username')),
            TextField(controller: emailController, decoration: const InputDecoration(labelText: 'Email')),
            TextField(controller: passwordController, decoration: const InputDecoration(labelText: 'Password'), obscureText: true),
            TextField(controller: confirmController, decoration: const InputDecoration(labelText: 'Confirm Password'), obscureText: true),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: isLoading ? null : _handleRegister,
              child: isLoading ? const CircularProgressIndicator() : const Text('Đăng ký'),
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: null, // sau này tích hợp Google sign-in
              icon: const Icon(Icons.login),
              label: const Text('Đăng ký bằng Google'),
            ),
            const SizedBox(height: 20),
            TextButton(
              onPressed: () => context.go('/login'),
              child: const Text('Đã có tài khoản? Đăng nhập'),
            ),
          ],
        ),
      ),
    );
  }
}
