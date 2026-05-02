import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../config/app_colors.dart';
import '../providers/providers.dart';

class StudentPerformanceApiScreen extends ConsumerWidget {
  const StudentPerformanceApiScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncData = ref.watch(studentPerformanceProvider);

    return Scaffold(
      backgroundColor: AppColors.bgDark,
      appBar: AppBar(
        title: const Text('Performance'),
        backgroundColor: Colors.transparent,
      ),
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(studentPerformanceProvider),
        child: asyncData.when(
          data: (data) {
            // TAE returns a map keyed by subject; older clients used list.
            final raw = data['performance_by_subject'];
            final list = (raw is List)
                ? List<dynamic>.from(raw)
                : (raw is Map)
                    ? raw.entries
                        .map((e) => {
                              'subject': e.key,
                              'average_marks': (e.value is Map)
                                  ? (e.value as Map)['average_marks']
                                  : null,
                              'average_percentage': (e.value is Map)
                                  ? (e.value as Map)['average_percentage']
                                  : null,
                              'count': (e.value is Map)
                                  ? ((e.value as Map)['total'] ??
                                      (e.value as Map)['count'])
                                  : null,
                            })
                        .toList()
                    : <dynamic>[];
            final total = data['total_evaluations'];

            return ListView(
              padding: const EdgeInsets.all(AppSpacing.xl),
              children: [
                _Hero(total: '${total ?? '—'}'),
                const SizedBox(height: AppSpacing.lg),
                if (list.isEmpty)
                  const _EmptyState(
                    title: 'No performance data yet',
                    subtitle:
                        'Once you have graded submissions, insights appear here.',
                  )
                else
                  ...list.map((e) {
                    final m = (e is Map)
                        ? Map<String, dynamic>.from(e as Map)
                        : <String, dynamic>{};
                    final subject = '${m['subject'] ?? 'Subject'}';
                    final avgMarks = '${m['average_marks'] ?? '—'}';
                    final avgPct = '${m['average_percentage'] ?? '—'}';
                    final count = '${m['count'] ?? '—'}';
                    return Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
                      child: _SubjectCard(
                        subject: subject,
                        avgMarks: avgMarks,
                        avgPct: avgPct,
                        count: count,
                      ),
                    );
                  }),
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
            onRetry: () => ref.invalidate(studentPerformanceProvider),
          ),
        ),
      ),
    );
  }
}

class _Hero extends StatelessWidget {
  final String total;
  const _Hero({required this.total});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [
          Color(0xFF111827),
          Color(0xFF1E293B),
        ]),
        borderRadius: BorderRadius.circular(AppRadius.xl),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadowColor,
            blurRadius: 28,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.10),
              borderRadius: BorderRadius.circular(AppRadius.xl),
            ),
            child: const Icon(Icons.query_stats_rounded, color: Colors.white),
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Total evaluations',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.white.withOpacity(0.85),
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  total,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.4,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SubjectCard extends StatelessWidget {
  final String subject;
  final String avgMarks;
  final String avgPct;
  final String count;

  const _SubjectCard({
    required this.subject,
    required this.avgMarks,
    required this.avgPct,
    required this.count,
  });

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
            subject,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Expanded(
                child: _mini(
                  icon: Icons.score_rounded,
                  label: 'Avg Marks',
                  value: avgMarks,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                child: _mini(
                  icon: Icons.percent_rounded,
                  label: 'Avg %',
                  value: avgPct,
                  color: AppColors.success,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          _mini(
            icon: Icons.numbers_rounded,
            label: 'Count',
            value: count,
            color: const Color(0xFF6366F1),
          ),
        ],
      ),
    );
  }

  Widget _mini({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: color.withOpacity(0.16)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: AppColors.textMedium,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String title;
  final String subtitle;

  const _EmptyState({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
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
              color: AppColors.warning.withOpacity(0.10),
              borderRadius: BorderRadius.circular(AppRadius.xl),
            ),
            child: const Icon(Icons.insights_rounded,
                color: AppColors.warning, size: 28),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textLight,
                  height: 1.4,
                  fontWeight: FontWeight.w600,
                ),
            textAlign: TextAlign.center,
          ),
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
                'Couldn’t load performance',
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

