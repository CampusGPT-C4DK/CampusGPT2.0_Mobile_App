import 'dart:ui';
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
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;
  
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  bool _backendAvailable = true;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
       duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.5, curve: Curves.easeIn)),
    );

    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
       CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );

    _controller.forward();

    // Check backend and navigate after 3.5 seconds
    Future.delayed(const Duration(milliseconds: 3500), _checkBackendAndNavigate);
  }

  Future<void> _checkBackendAndNavigate() async {
    if (!mounted) return;

    try {
      final healthService = BackendHealthService();
      final isHealthy = await healthService
          .isBackendHealthy()
          .timeout(const Duration(seconds: 3), onTimeout: () => false)
          .catchError((_) => false);

      if (mounted) {
        setState(() {
          _backendAvailable = isHealthy;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _backendAvailable = false);
    }

    if (!mounted) return;

    try {
      final authService = ref.read(authServiceProvider);
      final isLoggedIn = authService.isLoggedIn();

      if (mounted) {
        ref.read(authStateProvider.notifier).setAuthState(isLoggedIn);

        if (isLoggedIn && _backendAvailable) {
           context.go('/dashboard');
        } else if (isLoggedIn && !_backendAvailable) {
          _showBackendWarningDialog();
        } else {
           context.go('/login');
        }
      }
    } catch (e) {
       if (mounted) context.go('/login');
    }
  }

  void _showBackendWarningDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('⚠️ Backend Offline', style: TextStyle(color: AppColors.textDark, fontWeight: FontWeight.bold)),
        content: Text('Cannot connect to backend server.\n\nBackend URL: ${APIConfig.baseURL}', style: const TextStyle(color: AppColors.textMedium)),
        actions: [
          TextButton(
            onPressed: () {
               Navigator.pop(context);
               if (mounted) context.go('/dashboard');
            },
            child: const Text('Continue Anyway', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
          ),
          TextButton(
            onPressed: () {
               Navigator.pop(context);
               if (mounted) context.go('/login');
            },
            child: const Text('Login', style: TextStyle(color: AppColors.primaryDark, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Elegant animated soft light background
          Positioned(
             top: -100,
             right: -50,
             child: Container(
               width: 400,
               height: 400,
               decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary.withOpacity(0.08),
                  boxShadow: [
                     BoxShadow(color: AppColors.primaryLight.withOpacity(0.2), blurRadius: 100, spreadRadius: 50)
                  ]
               ),
             ),
          ),
          Positioned(
             bottom: -150,
             left: -100,
             child: Container(
               width: 500,
               height: 500,
               decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primaryDark.withOpacity(0.05),
                  boxShadow: [
                     BoxShadow(color: AppColors.primary.withOpacity(0.1), blurRadius: 120, spreadRadius: 60)
                  ]
               ),
             ),
          ),
          
          BackdropFilter(
             filter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
             child: Container(color: Colors.transparent),
          ),
          
          Center(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ScaleTransition(
                        scale: _pulseAnimation,
                        child: Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(color: AppColors.shadowColor, blurRadius: 40, spreadRadius: 10, offset: const Offset(0, 10)),
                              BoxShadow(color: AppColors.primary.withOpacity(0.1), blurRadius: 20, spreadRadius: 5),
                            ],
                          ),
                          child: const Center(
                            child: Icon(Icons.school_rounded, size: 60, color: AppColors.primaryDark),
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                      
                      Text(
                        'CampusGPT',
                        style: Theme.of(context).textTheme.displaySmall?.copyWith(
                              color: AppColors.primaryDark,
                              fontWeight: FontWeight.w900,
                              fontSize: 42,
                              letterSpacing: -1.0,
                            ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                        decoration: BoxDecoration(
                           color: AppColors.primary.withOpacity(0.1),
                           borderRadius: BorderRadius.circular(30),
                        ),
                        child: Text(
                          'Your Academic Assistant',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                color: AppColors.primaryDark,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.5,
                              ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
