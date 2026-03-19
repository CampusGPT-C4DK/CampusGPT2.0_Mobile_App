import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/forgot_password_screen.dart';
import 'screens/reset_password_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/career_path_screen.dart';
import 'screens/chat_screen.dart';
import 'screens/chat_history_screen.dart';
import 'screens/profile_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  navigatorKey: GlobalKey<NavigatorState>(),
  errorBuilder: (context, state) => Scaffold(
    appBar: AppBar(title: const Text('Navigation Error')),
    body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Error: ${state.error}'),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => context.canPop() ? context.pop() : context.go('/'),
            child: const Text('Go Back'),
          ),
        ],
      ),
    ),
  ),
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const SplashScreen(),
      redirect: _routeRedirect,
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
      path: '/forgot-password',
      builder: (context, state) => const ForgotPasswordScreen(),
    ),
    GoRoute(
      path: '/reset-password',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?;
        return ResetPasswordScreen(
          token: extra?['token'] as String?,
          type: extra?['type'] as String?,
        );
      },
    ),
    GoRoute(
      path: '/dashboard',
      builder: (context, state) => const DashboardScreen(),
    ),
    GoRoute(
      path: '/career-path',
      builder: (context, state) => const CareerPathScreen(),
    ),
    GoRoute(
      path: '/chat',
      builder: (context, state) => const ChatScreen(),
    ),
    GoRoute(
      path: '/history',
      builder: (context, state) => const ChatHistoryScreen(),
    ),
    GoRoute(
      path: '/chat-detail',
      builder: (context, state) => const ChatScreen(),
    ),
    GoRoute(
      path: '/profile',
      builder: (context, state) => const ProfileScreen(),
    ),
  ],
);

// Redirect logic for routes
String? _routeRedirect(BuildContext context, GoRouterState state) {
  // Only apply redirect on initial route
  if (state.matchedLocation != '/') return null;

  return null; // Let splash screen handle navigation
}
