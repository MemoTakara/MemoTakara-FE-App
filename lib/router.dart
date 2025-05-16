import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// Import màn hình
import 'package:MemoTakara/screens/auth/login_screen.dart';
import 'package:MemoTakara/screens/auth/register_screen.dart';
import 'package:MemoTakara/screens/collection/collection_detail_screen.dart';
import 'package:MemoTakara/screens/home/home_screen.dart';

// Import dịch vụ
import 'package:MemoTakara/services/auth_service.dart';

// Cấu hình API
import 'config/api_config.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  redirect: (context, state) async {
    final loggedIn = await AuthService.isLoggedIn();
    final isGoingToAuth = state.fullPath == '/login' || state.fullPath == '/register';

    // Nếu chưa login và cố vào các trang khác => redirect về /login
    if (!loggedIn && !isGoingToAuth) return '/';

    // Nếu đã login mà vẫn vào login/register => redirect về Home
    if (loggedIn && isGoingToAuth) return '/';

    // Không cần redirect
    return null;
  },
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterScreen(),
    ),
    GoRoute(
      path: '/public-collections/:id',
      builder: (context, state) {
        final id = int.parse(state.pathParameters['id']!);
        return CollectionDetailScreen(id: id);
      },
    ),
    // Redirect tạm để truy cập link tĩnh nếu cần
    GoRoute(
      path: '/api-redirect',
      redirect: (context, state) => ApiConfig.apiBaseUrl,
    ),
    GoRoute(
      path: '/storage-redirect',
      redirect: (context, state) => ApiConfig.storageBaseUrl,
    ),
  ],
);
