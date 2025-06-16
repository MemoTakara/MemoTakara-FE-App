import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../components/appbar_with_auth.dart';
import '../../providers/auth_provider.dart';

class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final screenHeight = MediaQuery.of(context).size.height;

    if (!authProvider.initialized) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBarWithAuth(
        isLoggedIn: authProvider.isLoggedIn,
        onLogin: () => context.go('/login'),
        onRegister: () => context.go('/register'),
      ),
      body: authProvider.isLoggedIn
          ? const Center(child: Text('Chào mừng bạn đến với Memo Takara!'))
          : Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Ảnh đầu trang
          Image.asset(
            'assets/img/MemoTakara.png',
            fit: BoxFit.contain,
          ),

          Padding(
            padding: const EdgeInsets.all(30.0),
            child: Column(
              children: [
                const Text(
                  'Enhance memory, cognition',
                  style: TextStyle(fontSize: 50, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 16),
                const Text(
                  'Join the MemoTakara community today and explore the power of your mind!',
                  style: TextStyle(fontSize: 18),
                ),
              ],
            ),
          ),

          /*
          const SizedBox(height: 16),
          const Text('Vui lòng đăng nhập hoặc đăng ký để tiếp tục.'),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => context.go('/login'),
            child: const Text('Đăng nhập'),
          ),
          TextButton(
            onPressed: () => context.go('/register'),
            child: const Text('Chưa có tài khoản? Đăng ký'),
          ),
          */
        ],
      ),
    );
  }
}
