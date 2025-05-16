import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../components/appbar_with_auth.dart';
import '../../providers/auth_provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBarWithAuth(
        isLoggedIn: authProvider.isLoggedIn,
        onLogin: () => context.go('/login'),
        onRegister: () => context.go('/register'),
      ),
      body: const Center(child: Text('Nội dung chính')),
    );
  }
}
