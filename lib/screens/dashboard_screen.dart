import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../config/app_colors.dart';
import '../providers/providers.dart';
import '../widgets/animated_appear.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserProvider);

    return Scaffold(
      backgroundColor: AppColors.bgWhite,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textDark,
        actions: [
          IconButton(
            onPressed: () => _showUserMenu(context, ref),
            icon: const Icon(Icons.person_rounded),
            tooltip: 'Profile Menu',
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Section
                AnimatedAppear(
                  child: _buildHeader(context, currentUser),
                ),
                const SizedBox(height: AppSpacing.xxxl),

                // Main Options - Grid Layout
                AnimatedAppear(
                  delay: const Duration(milliseconds: 200),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'What would you like to do?',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: AppSpacing.lg),

                      // Two-Column Layout for Career Path and Chat
                      Row(
                        children: [
                          Expanded(
                            child: _buildMainOption(
                              context: context,
                              title: 'Career Path',
                              description:
                                  'Explore career guidance\nand development',
                              icon: Icons.trending_up_rounded,
                              iconBg: const LinearGradient(
                                colors: [
                                  Color(0xFF667eea),
                                  Color(0xFF764ba2),
                                ],
                              ),
                              onTap: () => _navigateToCareerPath(context),
                              hasBadge: true,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.lg),
                          Expanded(
                            child: _buildMainOption(
                              context: context,
                              title: 'Chat',
                              description: 'Ask questions\nabout courses',
                              icon: Icons.chat_rounded,
                              iconBg: const LinearGradient(
                                colors: [
                                  Color(0xFF2563EB),
                                  Color(0xFF1E40AF),
                                ],
                              ),
                              onTap: () => context.push('/chat'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppSpacing.xxxl),

                // Quick Actions Section
                AnimatedAppear(
                  delay: const Duration(milliseconds: 400),
                  child: _buildQuickActionsSection(context),
                ),

                const SizedBox(height: AppSpacing.xxl),

                // Recent Activity or Tips
                AnimatedAppear(
                  delay: const Duration(milliseconds: 600),
                  child: _buildTipsSection(context),
                ),

                const SizedBox(height: AppSpacing.lg),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, AsyncValue<dynamic> currentUser) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Welcome Back! 👋',
          style: Theme.of(context).textTheme.displayLarge,
        ),
        const SizedBox(height: AppSpacing.md),
        currentUser.when(
          data: (user) => Text(
            user?.fullName ?? 'Student',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: AppColors.textMedium,
                ),
          ),
          loading: () => const SizedBox(
            width: 100,
            height: 20,
            child: LinearProgressIndicator(),
          ),
          error: (err, _) => Text(
            'Welcome!',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: AppColors.textMedium,
                ),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          '${DateTime.now().hour < 12 ? 'Good Morning' : DateTime.now().hour < 18 ? 'Good Afternoon' : 'Good Evening'} 🌟',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textLight,
              ),
        ),
      ],
    );
  }

  Widget _buildMainOption({
    required BuildContext context,
    required String title,
    required String description,
    required IconData icon,
    required LinearGradient iconBg,
    required VoidCallback onTap,
    bool hasBadge = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFFAFAFA), Color(0xFFF3F4F6)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(
            color: AppColors.border,
            width: 1.5,
          ),
        ),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icon Container
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: iconBg,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: Icon(
                    icon,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),

                // Title
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                ),
                const SizedBox(height: AppSpacing.sm),

                // Description
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textMedium,
                        height: 1.4,
                      ),
                ),
                const SizedBox(height: AppSpacing.md),

                // Arrow Icon
                Container(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: const Icon(
                    Icons.arrow_forward_rounded,
                    size: 18,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            if (hasBadge)
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.success,
                    borderRadius: BorderRadius.circular(AppRadius.full),
                  ),
                  child: const Text(
                    'NEW',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: AppSpacing.lg),
        Wrap(
          spacing: AppSpacing.md,
          runSpacing: AppSpacing.md,
          children: [
            _buildQuickActionButton(
              context,
              '📚 Resume Builder',
              Colors.blue,
              () => _navigateToCareerPath(context),
            ),
            _buildQuickActionButton(
              context,
              '💼 Job Search',
              Colors.purple,
              () => _navigateToCareerPath(context),
            ),
            _buildQuickActionButton(
              context,
              '🎯 Interview Prep',
              Colors.orange,
              () => _navigateToCareerPath(context),
            ),
            _buildQuickActionButton(
              context,
              '💬 Ask Questions',
              Colors.green,
              () => _navigateToChat(context),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickActionButton(
    BuildContext context,
    String label,
    Color color,
    VoidCallback onTap,
  ) {
    return MaterialButton(
      onPressed: onTap,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        side: const BorderSide(color: AppColors.border),
      ),
      elevation: 0,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.textDark,
              fontWeight: FontWeight.w500,
            ),
      ),
    );
  }

  Widget _buildTipsSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFFFEF3C7),
            Color(0xFFFCD34D),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: const Color(0xFFFBBF24),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: const Icon(
                  Icons.lightbulb_rounded,
                  color: Color(0xFFD97706),
                  size: 20,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Text(
                'Pro Tips',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF92400E),
                    ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            '✓ Ask CampusGPT specific questions about your courses\n'
            '✓ Build your career profile to track progress\n'
            '✓ Check interview preparation resources',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: const Color(0xFF92400E),
                  height: 1.6,
                ),
          ),
        ],
      ),
    );
  }

  void _navigateToCareerPath(BuildContext context) {
    try {
      if (context.mounted) {
        Future.microtask(() {
          if (context.mounted) {
            context.push('/career-path');
          }
        });
      }
    } catch (e) {
      print('❌ Navigation error to career-path: $e');
    }
  }

  void _navigateToChat(BuildContext context) {
    try {
      if (context.mounted) {
        Future.microtask(() {
          if (context.mounted) {
            context.push('/chat');
          }
        });
      }
    } catch (e) {
      print('❌ Navigation error to chat: $e');
    }
  }

  void _showUserMenu(BuildContext outerContext, WidgetRef ref) {
    showModalBottomSheet(
      context: outerContext,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppRadius.xl),
        ),
      ),
      builder: (BuildContext sheetContext) => Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(AppRadius.full),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            ListTile(
              leading:
                  const Icon(Icons.person_outline, color: AppColors.primary),
              title: const Text('Profile'),
              onTap: () {
                Navigator.pop(sheetContext);
                // Use outerContext for navigation, not sheetContext
                Future.microtask(() {
                  if (outerContext.mounted) {
                    outerContext.push('/profile');
                  }
                });
              },
            ),
            ListTile(
              leading: const Icon(Icons.history, color: AppColors.primary),
              title: const Text('Chat History'),
              onTap: () {
                Navigator.pop(sheetContext);
                // Use outerContext for navigation, not sheetContext
                Future.microtask(() {
                  if (outerContext.mounted) {
                    outerContext.push('/history');
                  }
                });
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: AppColors.error),
              title: const Text('Logout',
                  style: TextStyle(color: AppColors.error)),
              onTap: () async {
                Navigator.pop(sheetContext);

                // Use outerContext for all operations
                if (outerContext.mounted) {
                  try {
                    print('🔐 Starting logout process...');
                    ScaffoldMessenger.of(outerContext).showSnackBar(
                      const SnackBar(
                        content: Text('Logging out...'),
                        duration: Duration(seconds: 1),
                      ),
                    );

                    // Perform logout
                    await ref.read(authStateProvider.notifier).logout();
                    print('🔐 Logout complete, navigating to login...');

                    // Wait before navigation
                    await Future.delayed(const Duration(milliseconds: 300));

                    // Navigate using outerContext
                    if (outerContext.mounted) {
                      outerContext.go('/login');
                    }
                  } catch (e) {
                    print('❌ Logout error: $e');
                    if (outerContext.mounted) {
                      ScaffoldMessenger.of(outerContext).showSnackBar(
                        SnackBar(
                          content: Text('Logout error: ${e.toString()}'),
                          backgroundColor: AppColors.error,
                        ),
                      );
                    }
                  }
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
