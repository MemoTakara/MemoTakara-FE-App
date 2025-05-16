import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
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
      Provider.of<AuthProvider>(context, listen: false).setLoggedIn(true);
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
    // screen height
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Ảnh đầu trang
              Image.asset(
                'assets/img/MemoTakara.png',
                // width: double.infinity,
                height: screenHeight * 0.41,
                fit: BoxFit.contain,
              ),

              // Form trắng bo tròn
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    )
                  ],
                ),
                child: Column(
                  children: [
                    const Text(
                      'Đăng ký',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),

                    const SizedBox(height: 24),
                    TextField(
                      controller: usernameController,
                      decoration: const InputDecoration(
                        labelText: 'Username',
                        border: OutlineInputBorder(),
                      ),
                    ),

                    const SizedBox(height: 16),
                    TextField(
                      controller: emailController,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        border: OutlineInputBorder(),
                      ),
                    ),

                    const SizedBox(height: 16),
                    TextField(
                      controller: passwordController,
                      decoration: const InputDecoration(
                        labelText: 'Mật khẩu',
                        border: OutlineInputBorder(),
                      ),
                      obscureText: true,
                    ),

                    const SizedBox(height: 16),
                    TextField(
                      controller: confirmController,
                      decoration: const InputDecoration(
                        labelText: 'Xác nhận mật khẩu',
                        border: OutlineInputBorder(),
                      ),
                      obscureText: true,
                    ),

                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: isLoading ? null : _handleRegister,
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(48),
                      ),
                      child: isLoading
                          ? const CircularProgressIndicator()
                          : const Text('Đăng ký'),
                    ),

                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: () => context.push('/login'),
                      child: const Text(
                        'Đã có tài khoản? Đăng nhập',
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
