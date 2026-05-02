import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../config/app_colors.dart';

class StudentRoutesHub extends StatelessWidget {
  const StudentRoutesHub({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      key: const ValueKey('student_routes_hub'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _RouteCard(
          title: 'Assignments',
          subtitle: 'View active assignments from your faculty',
          icon: Icons.assignment_rounded,
          iconBg: const Color(0xFF0EA5E9),
          onTap: () => context.push('/student/assignments'),
        ),
        const SizedBox(height: AppSpacing.lg),
        Row(
          children: [
            Expanded(
              child: _RouteCard(
                title: 'Submit PDF',
                subtitle: 'Upload your assignment submission',
                icon: Icons.upload_file_rounded,
                iconBg: const Color(0xFF10B981),
                compact: true,
                onTap: () => context.push('/student/submit-assignment'),
              ),
            ),
            const SizedBox(width: AppSpacing.lg),
            Expanded(
              child: _RouteCard(
                title: 'My Submissions',
                subtitle: 'Track status, late days & results',
                icon: Icons.history_rounded,
                iconBg: const Color(0xFF6366F1),
                compact: true,
                onTap: () => context.push('/student/my-submissions'),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        Row(
          children: [
            Expanded(
              child: _RouteCard(
                title: 'Student Dashboard',
                subtitle: 'Stats & recent submissions',
                icon: Icons.dashboard_rounded,
                iconBg: AppColors.primary,
                compact: true,
                onTap: () => context.push('/dashboard/student-dashboard'),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        _RouteCard(
          title: 'Evaluation Result (by Submission ID)',
          subtitle: 'Open result screen for a specific submission',
          icon: Icons.verified_rounded,
          iconBg: const Color(0xFF8B5CF6),
          onTap: () => context.push('/evaluation/results'),
        ),
      ],
    );
  }
}

class _RouteCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconBg;
  final VoidCallback onTap;
  final bool compact;

  const _RouteCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconBg,
    required this.onTap,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(AppRadius.xl),
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(compact ? AppSpacing.lg : AppSpacing.xl),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppRadius.xl),
          border: Border.all(color: AppColors.border),
          boxShadow: const [
            BoxShadow(
              color: AppColors.shadowColor,
              blurRadius: 22,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: iconBg.withOpacity(0.12),
                borderRadius: BorderRadius.circular(AppRadius.lg),
              ),
              child: Icon(icon, color: iconBg, size: 24),
            ),
            const SizedBox(width: AppSpacing.lg),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.3,
                        ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textLight,
                          height: 1.35,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            const Icon(Icons.chevron_right_rounded, color: AppColors.textLight),
          ],
        ),
      ),
    );
  }
}

