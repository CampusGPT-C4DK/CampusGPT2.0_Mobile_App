import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:app_links/app_links.dart';
import 'dart:async';
import 'config/app_theme.dart';
import 'app_router.dart';
import 'providers/providers.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize SharedPreferences
  final prefs = await SharedPreferences.getInstance();
  print('✅ SharedPreferences initialized');
  
  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
      ],
      child: const CampusGPTApp(),
    ),
  );
}

class CampusGPTApp extends ConsumerWidget {
  const CampusGPTApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: 'CampusGPT',
      theme: AppTheme.lightTheme,
      routerConfig: appRouter,
      debugShowCheckedModeBanner: false,
      builder: (context, child) {
        return _DeepLinkHandler(child: child ?? const SizedBox.shrink());
      },
    );
  }
}

class _DeepLinkHandler extends ConsumerStatefulWidget {
  final Widget child;

  const _DeepLinkHandler({required this.child});

  @override
  ConsumerState<_DeepLinkHandler> createState() => _DeepLinkHandlerState();
}

class _DeepLinkHandlerState extends ConsumerState<_DeepLinkHandler> {
  final appLinks = AppLinks();
  late final StreamSubscription<Uri> _deepLinkSubscription;

  @override
  void initState() {
    super.initState();
    _initDeepLinkListener();
  }

  void _initDeepLinkListener() {
    _deepLinkSubscription = appLinks.uriLinkStream.listen(
      (uri) {
        print('🔗 Deep link received: $uri');
        _handleDeepLink(uri);
      },
      onError: (err) {
        print('❌ Deep link error: $err');
      },
    );
  }

  void _handleDeepLink(Uri uri) {
    print('🔗 Handling deep link: ${uri.path}');

    // Handle password reset link: campusgpt://reset-password?token=xxx
    if (uri.host == 'reset-password' || uri.path.contains('reset-password')) {
      final token = uri.queryParameters['token'];
      final type = uri.queryParameters['type'];

      if (token != null) {
        print('🔐 Password reset token detected: $token');
        // Navigate to reset password screen
        appRouter.go('/reset-password', extra: {'token': token, 'type': type});
      }
    }
  }

  @override
  void dispose() {
    _deepLinkSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
