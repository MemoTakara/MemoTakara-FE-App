import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';

class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        // Auto redirect if logged in
        if (authProvider.isLoggedIn) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            context.go('/home');
          });
        }

        return Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Header Section
                    Column(
                      children: [
                        // Logo
                        Container(
                          width: 360,
                          height: 330,
                          child: Image.asset(
                            'assets/img/MemoTakara.png',
                            fit: BoxFit.contain,
                          ),
                        ),
                        const SizedBox(height: 12),
                        // App Name
                        const Text(
                          'MemoTakara',
                          style: TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.w700,
                            color: Color(0xff166dba),
                            letterSpacing: 1.2,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 48),
                    // Description and Features
                    Column(
                      children: [
                        Text(
                          'Ứng dụng học tập thông minh giúp bạn ghi nhớ kiến thức hiệu quả với phương pháp lặp lại ngắt quãng.',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[800],
                            height: 1.6,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 32),
                        // Features
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildFeatureItem(
                              icon: Icons.school,
                              title: 'Học tập',
                              subtitle: 'Hiệu quả',
                            ),
                            _buildFeatureItem(
                              icon: Icons.bar_chart,
                              title: 'Thống kê',
                              subtitle: 'Chi tiết',
                            ),
                            _buildFeatureItem(
                              icon: Icons.notifications,
                              title: 'Nhắc nhở',
                              subtitle: 'Thông minh',
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 48),
                    // Buttons
                    Column(
                      children: [
                        // Login Button
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: () => context.go('/auth/login'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xff166dba),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 3,
                            ),
                            child: const Text(
                              'Đăng nhập',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Register Button
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: OutlinedButton(
                            onPressed: () => context.go('/auth/register'),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Color(0xff166dba)),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              'Tạo tài khoản mới',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Color(0xff166dba),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildFeatureItem({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Column(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: const Color(0xff166dba).withOpacity(0.15),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.grey[300]!,
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(
            icon,
            color: const Color(0xff166dba),
            size: 28,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xff166dba),
          ),
        ),
        Text(
          subtitle,
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}Widget _buildFeatureItem({
  required IconData icon,
  required String title,
  required String subtitle,
}) {
  return Column(
    children: [
      Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: const Color(0xff166dba).withOpacity(0.15),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.grey[300]!,
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(
          icon,
          color: const Color(0xff166dba),
          size: 28,
        ),
      ),
      const SizedBox(height: 12),
      Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Color(0xff166dba),
        ),
      ),
      Text(
        subtitle,
        style: TextStyle(
          fontSize: 13,
          color: Colors.grey[600],
          fontWeight: FontWeight.w500,
        ),
      ),
    ],
  );
}