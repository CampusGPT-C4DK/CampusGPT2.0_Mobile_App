import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../config/app_colors.dart';
import '../config/animations.dart';
import '../config/api_config.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/gradient_button.dart';
import '../providers/providers.dart';
import 'forgot_password_screen.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String? _emailError;
  String? _passwordError;
  String? _loginErrorMessage;
  bool _passwordVisible = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(
            CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  bool _validateInputs() {
    bool isValid = true;
    setState(() {
      _emailError = null;
      _passwordError = null;
    });

    if (_emailController.text.isEmpty) {
      setState(() => _emailError = 'Email is required');
      isValid = false;
    } else if (!_isValidEmail(_emailController.text)) {
      setState(() => _emailError = 'Please enter a valid email');
      isValid = false;
    }

    if (_passwordController.text.isEmpty) {
      setState(() => _passwordError = 'Password is required');
      isValid = false;
    } else if (_passwordController.text.length < 6) {
      setState(() => _passwordError = 'Password must be at least 6 characters');
      isValid = false;
    }

    return isValid;
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
        .hasMatch(email);
  }

  Future<void> _handleLogin() async {
    if (!_validateInputs()) return;

    final authStateNotifier = ref.read(authStateProvider.notifier);
    final authService = ref.read(authServiceProvider);

    try {
      ref.read(loginLoadingProvider.notifier).state = true;
      final result = await authService.login(
        email: _emailController.text,
        password: _passwordController.text,
      );

      if (result['success'] == true && mounted) {
        ref.invalidate(currentUserProvider);
        ref.invalidate(chatHistoryProvider);
        authStateNotifier.state = true;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('✅ Login successful!',
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold)),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
        await Future.delayed(const Duration(milliseconds: 100));
        if (mounted) context.go('/dashboard');
      } else if (mounted) {
        setState(
            () => _loginErrorMessage = result['message'] ?? 'Login failed');
        _showErrorDialog('Login Failed');
      }
    } catch (e) {
      if (mounted) {
        setState(() => _loginErrorMessage = e.toString());
        _showErrorDialog('Unexpected Error');
      }
    } finally {
      ref.read(loginLoadingProvider.notifier).state = false;
    }
  }

  void _showErrorDialog(String title) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(title,
            style: const TextStyle(
                color: AppColors.textDark, fontWeight: FontWeight.bold)),
        content: Text(_loginErrorMessage ?? 'Unable to login',
            style: const TextStyle(color: AppColors.textDark, fontSize: 14)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK',
                style: TextStyle(
                    color: AppColors.primary, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(loginLoadingProvider);

    return Scaffold(
        backgroundColor: AppColors.bgDark,
        body: Stack(fit: StackFit.expand, children: [
          // Abstract Background Shapes (Light Theme)
          Positioned(
            top: -80,
            left: -100,
            child: _buildGlowBlob(AppColors.primaryLight, 300),
          ),
          Positioned(
            bottom: -100,
            right: -50,
            child: _buildGlowBlob(AppColors.primary, 350),
          ),
          Positioned(
            top: 250,
            right: -150,
            child: _buildGlowBlob(AppColors.accent, 250),
          ),
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
            child: Container(color: Colors.transparent),
          ),

          FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.xxl, vertical: AppSpacing.xl),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: AppSpacing.xxxl),
                      // Logo
                      Center(
                        child: Container(
                          padding: const EdgeInsets.all(AppSpacing.md),
                          decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                    color: AppColors.shadowColor,
                                    blurRadius: 20,
                                    spreadRadius: 2,
                                    offset: const Offset(0, 10))
                              ]),
                          child: const Icon(Icons.school_rounded,
                              size: 50, color: AppColors.primary),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      Text(
                        'Welcome Back',
                        textAlign: TextAlign.center,
                        style: Theme.of(context)
                            .textTheme
                            .headlineMedium
                            ?.copyWith(
                              fontWeight: FontWeight.w900,
                              color: AppColors.textDark,
                              letterSpacing: -0.5,
                            ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        'Sign in to continue learning brilliantly.',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: AppColors.textMedium,
                            ),
                      ),
                      const SizedBox(height: AppSpacing.xxxl),

                      // Main Login Card (White & Clean)
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.xl),
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(AppRadius.xl),
                            border: Border.all(color: AppColors.border),
                            boxShadow: const [
                              BoxShadow(
                                color: AppColors.shadowColor,
                                blurRadius: 30,
                                spreadRadius: 0,
                                offset: Offset(0, 15),
                              )
                            ]),
                        child: Column(
                          children: [
                            _buildModernInputField(
                              controller: _emailController,
                              label: 'Email Address',
                              hint: 'name@example.com',
                              icon: Icons.email_outlined,
                              error: _emailError,
                              isObscure: false,
                            ),
                            const SizedBox(height: AppSpacing.lg),
                            _buildModernInputField(
                              controller: _passwordController,
                              label: 'Password',
                              hint: 'Enter your password',
                              icon: Icons.lock_outline_rounded,
                              error: _passwordError,
                              isObscure: true,
                              isPassword: true,
                            ),
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                style: TextButton.styleFrom(
                                  foregroundColor: AppColors.primary,
                                  padding: EdgeInsets.zero,
                                ),
                                onPressed: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const ForgotPasswordScreen()),
                                  );
                                },
                                child: const Text('Forgot Password?',
                                    style:
                                        TextStyle(fontWeight: FontWeight.w700)),
                              ),
                            ),
                            const SizedBox(height: AppSpacing.lg),
                            Container(
                              width: double.infinity,
                              height: 55,
                              decoration: BoxDecoration(
                                  borderRadius:
                                      BorderRadius.circular(AppRadius.lg),
                                  color: AppColors.primary,
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.primary.withOpacity(0.3),
                                      blurRadius: 15,
                                      spreadRadius: 0,
                                      offset: const Offset(0, 5),
                                    )
                                  ]),
                              child: ElevatedButton(
                                onPressed: isLoading ? null : _handleLogin,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                  shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(AppRadius.lg)),
                                ),
                                child: isLoading
                                    ? const CircularProgressIndicator(
                                        color: Colors.white)
                                    : const Text('Sign In',
                                        style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white)),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: AppSpacing.xl),

                      // Sign Up Link
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text("Don't have an account? ",
                              style: TextStyle(
                                  color: AppColors.textMedium,
                                  fontWeight: FontWeight.w500)),
                          GestureDetector(
                            onTap: () => context.go('/register'),
                            child: const Text('Sign Up',
                                style: TextStyle(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16)),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
        ]));
  }

  Widget _buildGlowBlob(Color color, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withOpacity(0.12), // Subtle light mode opacity
      ),
    );
  }

  Widget _buildModernInputField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    String? error,
    required bool isObscure,
    bool isPassword = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4.0),
          child: Text(label,
              style: const TextStyle(
                  color: AppColors.textDark,
                  fontWeight: FontWeight.w700,
                  fontSize: 13)),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: const BoxDecoration(
            boxShadow: [
              BoxShadow(
                  color: AppColors.shadowColor,
                  blurRadius: 8,
                  offset: Offset(0, 2))
            ],
          ),
          child: TextFormField(
            controller: controller,
            obscureText: isPassword ? !_passwordVisible : isObscure,
            style: const TextStyle(
                color: AppColors.textDark, fontWeight: FontWeight.w500),
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              prefixIcon: Padding(
                padding: const EdgeInsets.only(left: 6.0, right: 6.0),
                child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                        color: AppColors.bgDark,
                        borderRadius: BorderRadius.circular(8)),
                    child: Icon(icon, color: AppColors.primary, size: 18)),
              ),
              prefixIconConstraints:
                  const BoxConstraints(minWidth: 46, minHeight: 46),
              suffixIcon: isPassword
                  ? GestureDetector(
                      onTap: () {
                        setState(() {
                          _passwordVisible = !_passwordVisible;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.only(right: 12),
                        child: Icon(
                          _passwordVisible
                              ? Icons.visibility_rounded
                              : Icons.visibility_off_rounded,
                          color: AppColors.primary,
                          size: 20,
                        ),
                      ),
                    )
                  : null,
              hintText: hint,
              hintStyle: const TextStyle(color: AppColors.textLight),
              errorText: error,
              errorStyle: const TextStyle(color: AppColors.error),
              contentPadding: const EdgeInsets.symmetric(vertical: 16),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.lg),
                borderSide:
                    const BorderSide(color: AppColors.border, width: 1.0),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.lg),
                borderSide:
                    const BorderSide(color: AppColors.primary, width: 2),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.lg),
                borderSide:
                    const BorderSide(color: AppColors.error, width: 1.0),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.lg),
                borderSide: const BorderSide(color: AppColors.error, width: 2),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
