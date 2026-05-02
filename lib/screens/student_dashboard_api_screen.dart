import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../config/app_colors.dart';
import '../providers/providers.dart';

class StudentDashboardApiScreen extends ConsumerWidget {
  const StudentDashboardApiScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncData = ref.watch(studentDashboardProvider);

    return Scaffold(
      backgroundColor: AppColors.bgDark,
      appBar: AppBar(
        title: const Text('Student Dashboard'),
        backgroundColor: Colors.transparent,
      ),
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(studentDashboardProvider),
        child: asyncData.when(
          data: (data) {
            // Support both shapes:
            // - Older guide shape: submission_stats + grade_metrics
            // - Current TAE implementation: statistics (see tae_model/app/routes/dashboard.py)
            final stats = (data['submission_stats'] is Map)
                ? Map<String, dynamic>.from(data['submission_stats'] as Map)
                : (data['statistics'] is Map)
                    ? Map<String, dynamic>.from(data['statistics'] as Map)
                : <String, dynamic>{};
            final grade = (data['grade_metrics'] is Map)
                ? Map<String, dynamic>.from(data['grade_metrics'] as Map)
                : (data['statistics'] is Map)
                    ? Map<String, dynamic>.from(data['statistics'] as Map)
                : <String, dynamic>{};
            final recent = (data['recent_submissions'] is List)
                ? List<dynamic>.from(data['recent_submissions'] as List)
                : <dynamic>[];
            final total = int.tryParse('${stats['total'] ?? stats['total_submissions'] ?? '0'}') ?? 0;
            final graded = int.tryParse('${stats['graded'] ?? stats['graded_submissions'] ?? '0'}') ?? 0;
            final progress = total <= 0 ? 0.0 : (graded / total).clamp(0.0, 1.0);

            return ListView(
              padding: const EdgeInsets.all(AppSpacing.xl),
              children: [
                _Hero(
                  title: 'Your Progress',
                  subtitle: total == 0
                      ? 'Start by submitting your first assignment.'
                      : '$graded of $total submissions evaluated',
                ),
                const SizedBox(height: AppSpacing.md),
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppRadius.full),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 8,
                    backgroundColor: Colors.white,
                    valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                Row(
                  children: [
                    Expanded(
                      child: _MetricCard(
                        title: 'Total',
                        value: '$total',
                        color: AppColors.primary,
                        icon: Icons.all_inbox_rounded,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.lg),
                    Expanded(
                      child: _MetricCard(
                        title: 'Graded',
                        value: '$graded',
                        color: AppColors.success,
                        icon: Icons.verified_rounded,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
                Row(
                  children: [
                    Expanded(
                      child: _MetricCard(
                        title: 'Pending',
                        value: '${stats['pending'] ?? stats['pending_submissions'] ?? '—'}',
                        color: const Color(0xFF6366F1),
                        icon: Icons.schedule_rounded,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.lg),
                    Expanded(
                      child: _MetricCard(
                        title: 'Late',
                        value: '${stats['late'] ?? stats['late_submissions'] ?? '—'}',
                        color: AppColors.warning,
                        icon: Icons.timer_rounded,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
                _InfoCard(
                  title: 'Grade Metrics',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _kv('Average Marks', '${grade['average_marks'] ?? '—'}'),
                      const SizedBox(height: AppSpacing.sm),
                      _kv('Average %', '${grade['average_percentage'] ?? '—'}'),
                      const SizedBox(height: AppSpacing.sm),
                      _kv('Grades Received',
                          '${grade['total_grades_received'] ?? '—'}'),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                _InfoCard(
                  title: 'Recent Submissions',
                  child: recent.isEmpty
                      ? Text(
                          'No recent submissions.',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppColors.textLight,
                                    fontWeight: FontWeight.w600,
                                  ),
                        )
                      : Column(
                          children: recent.take(5).map((e) {
                            final m = (e is Map)
                                ? Map<String, dynamic>.from(e)
                                : <String, dynamic>{};
                            final id = '${m['id'] ?? ''}'.trim();
                            final status = '${m['status'] ?? ''}'.trim();
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: _recentRow(
                                context,
                                id.isEmpty ? '—' : id,
                                status.isEmpty ? 'pending' : status,
                              ),
                            );
                          }).toList(),
                        ),
                ),
              ],
            );
          },
          loading: () => const Center(
            child: SizedBox(
              width: 28,
              height: 28,
              child: CircularProgressIndicator(strokeWidth: 3),
            ),
          ),
          error: (e, _) => _ErrorState(
            message: e.toString(),
            onRetry: () => ref.invalidate(studentDashboardProvider),
          ),
        ),
      ),
    );
  }

  Widget _kv(String k, String v) {
    return Row(
      children: [
        Expanded(
          child: Text(
            k,
            style: const TextStyle(
              color: AppColors.textMedium,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        Text(
          v,
          style: const TextStyle(
            color: AppColors.textDark,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }

  Widget _recentRow(BuildContext context, String id, String status) {
    final graded = status.toLowerCase() == 'graded';
    final c = graded ? AppColors.success : const Color(0xFF6366F1);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.bgLight,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: c.withOpacity(0.12),
              borderRadius: BorderRadius.circular(AppRadius.lg),
            ),
            child: Icon(
              graded ? Icons.verified_rounded : Icons.schedule_rounded,
              color: c,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Submission #$id',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
          ),
          Text(
            status.toUpperCase(),
            style: TextStyle(
              color: c,
              fontWeight: FontWeight.w900,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _Hero extends StatelessWidget {
  final String title;
  final String subtitle;

  const _Hero({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: AppColors.lightGradient),
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: const Color(0xFFBFDBFE)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.6,
                ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textMedium,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final Color color;
  final IconData icon;

  const _MetricCard({
    required this.title,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: AppColors.border),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadowColor,
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(AppRadius.lg),
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textLight,
                  fontWeight: FontWeight.w700,
                ),
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _InfoCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
          ),
          const SizedBox(height: AppSpacing.lg),
          child,
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.xl),
      children: [
        const SizedBox(height: 60),
        Container(
          padding: const EdgeInsets.all(AppSpacing.xl),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppRadius.xl),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppColors.error.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(AppRadius.xl),
                ),
                child: const Icon(Icons.error_outline_rounded,
                    color: AppColors.error, size: 28),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                'Couldn’t load dashboard',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                message,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textLight,
                      height: 1.35,
                      fontWeight: FontWeight.w600,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.lg),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: onRetry,
                  child: const Text('Retry'),
                ),
              )
            ],
          ),
        ),
      ],
    );
  }
}

