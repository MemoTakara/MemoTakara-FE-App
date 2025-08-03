import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'providers/auth_provider.dart';
import 'components/main_scaffold.dart';

// Import màn hình
import 'screens/account/setting_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/collection/collection_detail_screen.dart';
import 'screens/home/landing_screen.dart';
import 'screens/home/home_screen.dart';

import '/screens/collection/collection_list.dart';
import 'screens/collection/my_collection.dart';
import 'screens/notification/notification_screen.dart';
import 'screens/stats/statistics_screen.dart';

import 'screens/study/flashcard.dart';
import 'screens/study/matching.dart';
import 'screens/study/quiz.dart';
import 'screens/study/typing.dart';

// Cấu hình API
import 'config/api_config.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  redirect: (context, state) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final isLoggedIn = authProvider.isLoggedIn;
    final isAuthRoute = state.uri.toString().startsWith('/auth');
    final isLandingPage = state.uri.toString() == '/';

    // Nếu ở landing page, không redirect
    if (isLandingPage) {
      return null;
    }

    // Nếu chưa đăng nhập và không phải trang auth hoặc landing, chuyển về landing
    if (!isLoggedIn && !isAuthRoute) {
      return '/';
    }

    // Nếu đã đăng nhập và đang ở trang auth, chuyển về home
    if (isLoggedIn && isAuthRoute) {
      return '/home';
    }

    return null; // Không redirect
  },
  routes: [
    // Landing page (không có bottom navigation)
    GoRoute(
      path: '/',
      builder: (context, state) => const LandingScreen(),
    ),

    // Auth routes (không có bottom navigation)
    GoRoute(
      path: '/auth/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/auth/register',
      builder: (context, state) => const RegisterScreen(),
    ),

    // Main routes (có bottom navigation)
    ShellRoute(
      builder: (context, state, child) {
        return MainScaffold(
          location: state.uri.toString(),
          child: child,
        );
      },
      routes: [
        GoRoute(
          path: '/home',
          builder: (context, state) => const HomeScreen(),
        ),
        GoRoute(
          path: '/my-collection',
          builder: (context, state) => const MyCollectionScreen(),
        ),
        GoRoute(
          path: '/collection-list',
          builder: (context, state) {
            final type = state.uri.queryParameters['type'];
            if (type == null || (type != 'recent' && type != 'public')) {
              return const Scaffold(
                body: Center(child: Text('Tham số "type" không hợp lệ hoặc bị thiếu')),
              );
            }
            return CollectionListScreen(type: type);
          },
        ),
        GoRoute(
          path: '/collection-detail/:id',
          builder: (context, state) {
            final id = int.tryParse(state.pathParameters['id'] ?? '') ?? 1;
            return CollectionDetailScreen(id: id);
          },
        ),
        GoRoute(
          path: '/study/fc/:id',
          builder: (context, state) {
            final id = int.tryParse(state.pathParameters['id'] ?? '') ?? 1;
            return FlashcardScreen(collectionId: id);
          },
        ),
        GoRoute(
          path: '/study/matching/:id',
          builder: (context, state) {
            final id = int.tryParse(state.pathParameters['id'] ?? '') ?? 1;
            return MatchingScreen(collectionId: id);
          },
        ),
        GoRoute(
          path: '/study/quiz/:id',
          builder: (context, state) {
            final id = int.tryParse(state.pathParameters['id'] ?? '') ?? 1;
            return QuizScreen(collectionId: id);
          },
        ),
        GoRoute(
          path: '/study/typing/:id',
          builder: (context, state) {
            final id = int.tryParse(state.pathParameters['id'] ?? '') ?? 1;
            return TypingScreen(collectionId: id);
          },
        ),
        GoRoute(
          path: '/statistics',
          builder: (context, state) => const StatisticScreen(),
        ),
        GoRoute(
          path: '/notifications',
          builder: (context, state) => const NotificationScreen(),
        ),
        GoRoute(
          path: '/settings',
          builder: (context, state) => const SettingScreen(),
        ),
      ],
    ),
  ],
);
