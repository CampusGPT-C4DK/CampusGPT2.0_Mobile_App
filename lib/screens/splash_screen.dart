import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../config/app_colors.dart';
import '../config/api_config.dart';
import '../providers/providers.dart';
import '../services/backend_health_service.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;
  bool _backendAvailable = true;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    _controller.forward();

    // Check backend and navigate after 3 seconds
    Future.delayed(const Duration(seconds: 3), _checkBackendAndNavigate);
  }

  Future<void> _checkBackendAndNavigate() async {
    if (!mounted) return;

    try {
      // Check backend availability
      print('🔍 Checking backend availability...');
      final healthService = BackendHealthService();
      final isHealthy = await healthService
          .isBackendHealthy()
          .timeout(
            const Duration(seconds: 3),
            onTimeout: () => false,
          )
          .catchError((_) => false);

      if (mounted) {
        setState(() {
          _backendAvailable = isHealthy;
        });

        if (!isHealthy) {
          print('⚠️ Backend not available, but continuing to login');
        }
      }
    } catch (e) {
      print('❌ Error checking backend: $e');
      if (mounted) {
        setState(() {
          _backendAvailable = false;
        });
      }
    }

    // Navigate based on persistent login check
    if (!mounted) return;

    try {
      final authService = ref.read(authServiceProvider);
      final isLoggedIn = authService.isLoggedIn();

      print(
          '🔐 SPLASH: Persistent login check = ${isLoggedIn ? 'LOGGED IN ✅' : 'LOGGED OUT ❌'}');

      if (mounted) {
        // Update auth state provider
        ref.read(authStateProvider.notifier).setAuthState(isLoggedIn);

        if (isLoggedIn && _backendAvailable) {
          // User is logged in and backend is available - go to dashboard
          print('✅ SPLASH: Going to dashboard (user logged in + backend ok)');
          context.go('/dashboard');
        } else if (isLoggedIn && !_backendAvailable) {
          // User is logged in but backend not available - show warning
          print('⚠️ SPLASH: Backend unavailable but user logged in');
          if (mounted) {
            _showBackendWarningDialog();
          }
        } else {
          // User not logged in - go to login screen
          print('🔐 SPLASH: Going to login screen (user not logged in)');
          context.go('/login');
        }
      }
    } catch (e) {
      print('❌ SPLASH: Error during navigation: $e');
      if (mounted) {
        context.go('/login');
      }
    }
  }

  void _showBackendWarningDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('⚠️ Backend Server Warning'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Cannot connect to backend server',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Text(
                'Backend URL: ${APIConfig.baseURL}',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.1),
                  border: Border.all(color: Colors.orange),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '💡 Please make sure:',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '1. Backend server is running',
                      style: TextStyle(fontSize: 12),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '2. Check backend logs for errors',
                      style: TextStyle(fontSize: 12),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '3. Verify network connectivity',
                      style: TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              if (mounted) {
                context.go('/dashboard');
              }
            },
            child: const Text('Continue Anyway'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              if (mounted) {
                context.go('/login');
              }
            },
            child: const Text('Go to Login'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: AppColors.gradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Animated Logo
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.4),
                            blurRadius: 30,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.school_rounded,
                          size: 70,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    // App Name
                    ShaderMask(
                      shaderCallback: (bounds) => const LinearGradient(
                        colors: [Colors.white, Color(0xFFE0E7FF)],
                      ).createShader(bounds),
                      child: Text(
                        'CampusGPT',
                        style:
                            Theme.of(context).textTheme.displaySmall?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 48,
                                ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Tagline
                    Text(
                      'Your AI Campus Guide',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 16,
                          ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
