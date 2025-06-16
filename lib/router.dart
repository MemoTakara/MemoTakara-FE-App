import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

// Import màn hình
import 'package:MemoTakara/screens/auth/login_screen.dart';
import 'package:MemoTakara/screens/auth/register_screen.dart';
import 'package:MemoTakara/screens/collection/collection_detail_screen.dart';
import 'package:MemoTakara/screens/home/landing_screen.dart';

// Import provider
import 'package:MemoTakara/providers/auth_provider.dart';

// Cấu hình API
import 'config/api_config.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const LandingScreen(),
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
    GoRoute(
      path: '/api-redirect',
      redirect: (context, state) => ApiConfig.apiBaseUrl,
    ),
    GoRoute(
      path: '/storage-redirect',
      redirect: (context, state) => ApiConfig.storageBaseUrl,
    ),
  ],
    redirect: (context, state) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final loggedIn = authProvider.isLoggedIn;
      final initialized = authProvider.initialized;

      final goingToLogin = state.uri.path == '/login';
      final goingToRegister = state.uri.path == '/register';

      if (!initialized) return null; // Đợi init xong

      // Nếu đã đăng nhập mà cố vào /login hoặc /register thì redirect về /
      if (loggedIn && (goingToLogin || goingToRegister)) return '/';

      // Cho phép người chưa đăng nhập vào bất cứ đâu (gồm cả Landing, Login, Register)
      return null;
    }

);
