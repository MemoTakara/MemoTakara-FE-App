import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool isLoading = false;

  void _handleLogin() async {
    setState(() => isLoading = true);
    // check TOKEN
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    final success = await Provider.of<AuthProvider>(
      context,
      listen: false
    ).login(
      emailController.text.trim(),
      passwordController.text,
    );
    setState(() => isLoading = false);

    if (success) {
      // check TOKEN
      final token = authProvider.token;
      debugPrint('Login successful! Token: $token');

      context.go('/');
    } else {
      _showError("Đăng nhập thất bại. Vui lòng thử lại.");
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(40.0),
        child: AppBar(
          leading: Navigator.canPop(context)
              ? IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          )
              : null,
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Ảnh đầu trang
              Image.asset(
                'assets/img/MemoTakara.png',
                width: 320,
                height: screenHeight * 0.51,
                fit: BoxFit.contain,
              ),

              // Form trắng bo tròn
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(50),
                    topRight: Radius.circular(50),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 15,
                      offset: const Offset(0, 1),
                    )
                  ],
                ),
                child: Column(
                  children: [
                    const Text(
                      'Đăng nhập',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 24),
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

                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: isLoading ? null : _handleLogin,
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(48),
                      ),
                      child: isLoading
                          ? const CircularProgressIndicator()
                          : const Text('Đăng nhập'),
                    ),

                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: () => context.go('/auth/register'),
                      child: const Text(
                        'Chưa có tài khoản? Đăng ký',
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
