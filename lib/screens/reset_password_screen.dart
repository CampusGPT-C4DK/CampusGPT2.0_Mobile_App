import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../config/app_colors.dart';
import '../config/animations.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/gradient_button.dart';
import '../providers/providers.dart';

class ResetPasswordScreen extends ConsumerStatefulWidget {
  final String? token;
  final String? type;

  const ResetPasswordScreen({
    Key? key,
    this.token,
    this.type,
  }) : super(key: key);

  @override
  ConsumerState<ResetPasswordScreen> createState() =>
      _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends ConsumerState<ResetPasswordScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  String? _passwordError;
  String? _confirmPasswordError;
  bool _isLoading = false;
  bool _passwordUpdated = false;
  bool _showPassword = false;
  bool _showConfirmPassword = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: AnimationDuration.normal,
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    _controller.forward();

    // Validate token
    if (widget.token == null) {
      print('❌ No reset token provided');
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          _showErrorDialog();
        }
      });
    } else {
      print('✅ Reset token received: ${widget.token}');
      print('✅ Token type: ${widget.type}');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _showErrorDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Invalid Reset Link'),
        content: const Text(
          'This password reset link is invalid or has expired. Please request a new one.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.go('/forgot-password');
            },
            child: const Text('Try Again'),
          ),
        ],
      ),
    );
  }

  bool _validateInputs() {
    bool isValid = true;
    setState(() {
      _passwordError = null;
      _confirmPasswordError = null;
    });

    if (_newPasswordController.text.isEmpty) {
      setState(() => _passwordError = 'Password is required');
      isValid = false;
    } else if (_newPasswordController.text.length < 8) {
      setState(() => _passwordError = 'Password must be at least 8 characters');
      isValid = false;
    } else if (!_containsComplexity(_newPasswordController.text)) {
      setState(() => _passwordError =
          'Password must contain uppercase, lowercase, numbers and special characters');
      isValid = false;
    }

    if (_confirmPasswordController.text != _newPasswordController.text) {
      setState(() => _confirmPasswordError = 'Passwords do not match');
      isValid = false;
    }

    return isValid;
  }

  bool _containsComplexity(String password) {
    final hasUppercase = password.contains(RegExp(r'[A-Z]'));
    final hasLowercase = password.contains(RegExp(r'[a-z]'));
    final hasNumbers = password.contains(RegExp(r'[0-9]'));
    final hasSpecialChars =
        password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));

    return hasUppercase && hasLowercase && hasNumbers && hasSpecialChars;
  }

  Future<void> _handleResetPassword() async {
    if (widget.token == null) {
      _showErrorDialog();
      return;
    }

    if (!_validateInputs()) return;

    setState(() => _isLoading = true);

    final authService = ref.read(authServiceProvider);
    final result = await authService.updatePasswordWithRecoveryToken(
      newPassword: _newPasswordController.text,
      token: widget.token!,
    );

    if (mounted) {
      setState(() => _isLoading = false);

      if (result['success'] == true) {
        setState(() => _passwordUpdated = true);
        print('✅ Password reset successful');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] as String),
            backgroundColor: AppColors.error,
          ),
        );
        print('❌ Password reset failed: ${result['message']}');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: widget.token != null
            ? null
            : IconButton(
                icon: Icon(
                  Icons.arrow_back_ios,
                  color: AppColors.primary,
                  size: 20,
                ),
                onPressed: () => Navigator.of(context).pop(),
              ),
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: _passwordUpdated ? _buildSuccessUI() : _buildResetForm(),
        ),
      ),
    );
  }

  Widget _buildResetForm() {
    return SlideTransition(
      position: _slideAnimation,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 40),

          // Animated Icon
          Container(
            height: 100,
            width: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  AppColors.primary.withOpacity(0.1),
                  AppColors.primary.withOpacity(0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Icon(
              Icons.lock_outline_rounded,
              size: 50,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 32),

          // Title
          Text(
            'Create New Password',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),

          // Description
          Text(
            'Choose a strong password to secure your account. You cannot use your old password.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                  height: 1.5,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),

          // Password Requirements
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.05),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Colors.blue.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Password Requirements:',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Colors.blue,
                      ),
                ),
                const SizedBox(height: 8),
                _buildRequirement('At least 8 characters'),
                _buildRequirement('1 uppercase letter (A-Z)'),
                _buildRequirement('1 lowercase letter (a-z)'),
                _buildRequirement('1 number (0-9)'),
                _buildRequirement('1 special character (!@#\$%^&*)'),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // New Password Field
          CustomTextField(
            controller: _newPasswordController,
            label: 'New Password',
            hintText: 'Enter strong password',
            prefixIcon: Icons.lock_outline,
            obscureText: !_showPassword,
            suffixIcon: _showPassword ? Icons.visibility : Icons.visibility_off,
            onSuffixTap: () {
              setState(() => _showPassword = !_showPassword);
            },
            errorText: _passwordError,
            onChanged: (_) {
              if (_passwordError != null) {
                setState(() => _passwordError = null);
              }
            },
          ),
          const SizedBox(height: 20),

          // Confirm Password Field
          CustomTextField(
            controller: _confirmPasswordController,
            label: 'Confirm Password',
            hintText: 'Re-enter password',
            prefixIcon: Icons.lock_outline,
            obscureText: !_showConfirmPassword,
            suffixIcon:
                _showConfirmPassword ? Icons.visibility : Icons.visibility_off,
            onSuffixTap: () {
              setState(() => _showConfirmPassword = !_showConfirmPassword);
            },
            errorText: _confirmPasswordError,
            onChanged: (_) {
              if (_confirmPasswordError != null) {
                setState(() => _confirmPasswordError = null);
              }
            },
          ),
          const SizedBox(height: 32),

          // Reset Button
          GradientButton(
            label: _isLoading ? 'Resetting...' : 'Reset Password',
            onPressed: _isLoading ? () {} : _handleResetPassword,
            isLoading: _isLoading,
          ),
          const SizedBox(height: 16),

          // Back to Login
          TextButton(
            onPressed: () {
              context.go('/login');
            },
            child: Text(
              'Back to Login',
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRequirement(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Text(
            '•',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.blue,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[700],
                  ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessUI() {
    return SlideTransition(
      position: _slideAnimation,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 40),

          // Success Icon
          Container(
            height: 100,
            width: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  Colors.green.withOpacity(0.1),
                  Colors.green.withOpacity(0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: const Icon(
              Icons.check_circle_rounded,
              size: 50,
              color: Colors.green,
            ),
          ),
          const SizedBox(height: 32),

          // Title
          Text(
            'Password Reset Successful',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),

          // Description
          Text(
            'Your password has been successfully updated. You can now login with your new password.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                  height: 1.5,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),

          // Info Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.green.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Column(
              children: [
                _buildInfoRow(
                  '✅',
                  'Password updated successfully',
                ),
                const SizedBox(height: 12),
                _buildInfoRow(
                  '🔒',
                  'Your account is now secure',
                ),
                const SizedBox(height: 12),
                _buildInfoRow(
                  '📱',
                  'You can login on any device',
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),

          // Login Button
          GradientButton(
            label: 'Go to Login',
            onPressed: () {
              context.go('/login');
            },
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          icon,
          style: const TextStyle(fontSize: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[700],
                  height: 1.4,
                ),
          ),
        ),
      ],
    );
  }
}
