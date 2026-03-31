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
      backgroundColor: AppColors.bgDark, // Light gray/blue base
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.textDark,
        title: Text(
          'CampusGPT',
          style: TextStyle(
            color: AppColors.primaryDark,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: Row(
              children: [
                IconButton(
                  onPressed: () => _showUserMenu(context, ref),
                  icon: const Icon(Icons.menu_rounded),
                  tooltip: 'Menu',
                ),
              ],
            ),
          )
        ],
      ),
      body: SingleChildScrollView(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.xl, vertical: AppSpacing.md),
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
                  delay: const Duration(milliseconds: 100),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Explore',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.textDark,
                              letterSpacing: -0.5,
                            ),
                      ),
                      const SizedBox(height: AppSpacing.lg),

                      // Two-Column Layout for Career Path and Chat
                      Row(
                        children: [
                          Expanded(
                            child: _buildMainOption(
                              context: context,
                              title: 'AI Chat',
                              description: 'Ask questions & learn',
                              icon: Icons.forum_rounded,
                              iconBg: AppColors.primary,
                              onTap: () => context.push('/chat'),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.lg),
                          Expanded(
                            child: _buildMainOption(
                              context: context,
                              title: 'Career Path',
                              description: 'Discover your future',
                              icon: Icons.rocket_launch_rounded,
                              iconBg: const Color(0xFF6366F1), // Indigo
                              onTap: () => _navigateToCareerPath(context),
                              hasBadge: true,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppSpacing.xxxl),

                // Quick Actions Section
                // AnimatedAppear(
                //   delay: const Duration(milliseconds: 200),
                //   child: _buildQuickActionsSection(context),
                // ),

                const SizedBox(height: AppSpacing.xxxl),

                // Recent Activity or Tips
                AnimatedAppear(
                  delay: const Duration(milliseconds: 300),
                  child: _buildTipsSection(context),
                ),

                const SizedBox(height: AppSpacing.xxxl),
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
        currentUser.when(
          data: (user) => Text(
            'Hello, ${user?.fullName?.split(' ')[0] ?? 'Student'} 👋',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: AppColors.textDark,
                  letterSpacing: -0.5,
                ),
          ),
          loading: () => const SizedBox(
            width: 150,
            height: 32,
            child: LinearProgressIndicator(
                color: AppColors.border, backgroundColor: Colors.white),
          ),
          error: (err, _) => Text(
            'Hello! 👋',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: AppColors.textDark,
                ),
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          'What would you like to learn today?',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppColors.textMedium,
                fontWeight: FontWeight.w500,
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
    required Color iconBg,
    required VoidCallback onTap,
    bool hasBadge = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppRadius.xl),
          boxShadow: const [
            BoxShadow(
              color: AppColors.shadowColor,
              blurRadius: 24,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icon Container
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: iconBg.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                  ),
                  child: Icon(
                    icon,
                    color: iconBg,
                    size: 24,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),

                // Title
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: AppColors.textDark,
                        letterSpacing: -0.5,
                      ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppSpacing.xs),

                // Description
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textLight,
                        height: 1.3,
                        fontWeight: FontWeight.w500,
                      ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
            if (hasBadge)
              Positioned(
                top: -8,
                right: -8,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                      color: AppColors.success,
                      borderRadius: BorderRadius.circular(AppRadius.full),
                      boxShadow: [
                        BoxShadow(
                            color: AppColors.success.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4)),
                      ]),
                  child: const Text(
                    'NEW',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // Widget _buildQuickActionsSection(BuildContext context) {
  //   return Column(
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: [
  //       Text(
  //         'Quick Resources',
  //         style: Theme.of(context).textTheme.titleLarge?.copyWith(
  //               fontWeight: FontWeight.bold,
  //               color: AppColors.textDark,
  //               letterSpacing: -0.5,
  //             ),
  //       ),
  //       const SizedBox(height: AppSpacing.lg),
  //       Container(
  //         padding: const EdgeInsets.symmetric(vertical: 8),
  //         decoration: BoxDecoration(
  //            color: Colors.white,
  //            borderRadius: BorderRadius.circular(AppRadius.xl),
  //            boxShadow: const [
  //              BoxShadow(color: AppColors.shadowColor, blurRadius: 20, offset: Offset(0, 4))
  //            ]
  //         ),
  //         child: Column(
  //            children: [
  //               _buildListAction(context, '📚', 'Resume Builder', 'Create a professional profile', () => _navigateToCareerPath(context)),
  //               Divider(height: 1, color: AppColors.border.withOpacity(0.5), indent: 56),
  //               _buildListAction(context, '💼', 'Job Search', 'Explore top opportunities', () => _navigateToCareerPath(context)),
  //               Divider(height: 1, color: AppColors.border.withOpacity(0.5), indent: 56),
  //               _buildListAction(context, '🎯', 'Interview Prep', 'Practice makes perfect', () => _navigateToCareerPath(context)),
  //            ]
  //         ),
  //       )
  //     ],
  //   );
  // }

  Widget _buildListAction(BuildContext context, String emoji, String title,
      String subtitle, VoidCallback onTap) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.bgDark,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(emoji, style: const TextStyle(fontSize: 20)),
      ),
      title: Text(title,
          style: const TextStyle(
              fontWeight: FontWeight.w700, color: AppColors.textDark)),
      subtitle: Text(subtitle,
          style: const TextStyle(
              color: AppColors.textLight,
              fontSize: 13,
              fontWeight: FontWeight.w500)),
      trailing:
          const Icon(Icons.chevron_right_rounded, color: AppColors.textLight),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    );
  }

  Widget _buildTipsSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: const Color(0xFFEEF2FF), // Very soft Indigo
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(
          color: const Color(0xFFC7D2FE), // Light Indigo border
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
                color: const Color(0xFF6366F1), // Indigo
                borderRadius: BorderRadius.circular(AppRadius.md),
                boxShadow: [
                  BoxShadow(
                      color: const Color(0xFF6366F1).withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4)),
                ]),
            child: const Icon(
              Icons.wb_incandescent_rounded,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Pro Tip: Deep Dive',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF312E81),
                      ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Upload your resume in the Career Path tool to get a highly customized roadmap for your future!',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: const Color(0xFF4338CA),
                        height: 1.5,
                        fontWeight: FontWeight.w500,
                      ),
                ),
              ],
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
      backgroundColor: Colors.white,
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
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                    color: AppColors.bgDark,
                    borderRadius: BorderRadius.circular(8)),
                child: const Icon(Icons.person_rounded,
                    color: AppColors.primaryDark),
              ),
              title: const Text('Profile',
                  style: TextStyle(fontWeight: FontWeight.w600)),
              onTap: () {
                Navigator.pop(sheetContext);
                Future.microtask(() {
                  if (outerContext.mounted) {
                    outerContext.push('/profile');
                  }
                });
              },
            ),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                    color: AppColors.bgDark,
                    borderRadius: BorderRadius.circular(8)),
                child: const Icon(Icons.history_rounded,
                    color: AppColors.primaryDark),
              ),
              title: const Text('Chat History',
                  style: TextStyle(fontWeight: FontWeight.w600)),
              onTap: () {
                Navigator.pop(sheetContext);
                Future.microtask(() {
                  if (outerContext.mounted) {
                    outerContext.push('/history');
                  }
                });
              },
            ),
            const Divider(height: 32),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                    color: AppColors.error.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8)),
                child: const Icon(Icons.logout_rounded, color: AppColors.error),
              ),
              title: const Text('Logout',
                  style: TextStyle(
                      color: AppColors.error, fontWeight: FontWeight.w600)),
              onTap: () async {
                Navigator.pop(sheetContext);

                if (outerContext.mounted) {
                  try {
                    await ref.read(authStateProvider.notifier).logout();
                    await Future.delayed(const Duration(milliseconds: 300));
                    if (outerContext.mounted) {
                      outerContext.go('/login');
                    }
                  } catch (e) {
                    print('❌ Logout error: $e');
                  }
                }
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
