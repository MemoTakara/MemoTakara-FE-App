import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../services/auth_service.dart';

class AppBarWithAuth extends StatelessWidget implements PreferredSizeWidget {
  final bool isLoggedIn;
  final VoidCallback? onLogin;
  final VoidCallback? onRegister;

  const AppBarWithAuth({
    super.key,
    required this.isLoggedIn,
    this.onLogin,
    this.onRegister,
  });

  Future<void> _handleLogout(BuildContext context) async {
    await AuthService.logout();
    context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: const Text('Memo Takara'),
      actions: [
        if (!isLoggedIn) ...[
          TextButton(
            onPressed: onLogin,
            child: const Text('Đăng nhập', style: TextStyle(color: Colors.white)),
          ),
          TextButton(
            onPressed: onRegister,
            child: const Text('Đăng ký', style: TextStyle(color: Colors.white)),
          ),
        ] else ...[
          IconButton(
            onPressed: () => _handleLogout(context),
            icon: const Icon(Icons.logout),
            tooltip: 'Đăng xuất',
          )
        ]
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
