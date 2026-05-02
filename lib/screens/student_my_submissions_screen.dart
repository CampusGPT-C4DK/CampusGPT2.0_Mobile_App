import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../config/app_colors.dart';
import '../providers/providers.dart';

class StudentMySubmissionsScreen extends ConsumerWidget {
  const StudentMySubmissionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncSubmissions = ref.watch(mySubmissionsProvider);

    return Scaffold(
      backgroundColor: AppColors.bgDark,
      appBar: AppBar(
        title: const Text('My Submissions'),
        backgroundColor: Colors.transparent,
      ),
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(mySubmissionsProvider),
        child: asyncSubmissions.when(
          data: (items) {
            if (items.isEmpty) {
              return const _EmptyState(
                title: 'No submissions yet',
                subtitle: 'Submit your first assignment and track it here.',
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.all(AppSpacing.xl),
              itemCount: items.length + 1,
              separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.lg),
              itemBuilder: (context, index) {
                if (index == 0) {
                  final total = items.length;
                  final passed = items.where((e) {
                    final m = (e is Map)
                        ? Map<String, dynamic>.from(e)
                        : <String, dynamic>{};
                    return '${m['status'] ?? ''}'.trim().toLowerCase() ==
                        'passed';
                  }).length;
                  return Container(
                    margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                    padding: const EdgeInsets.all(AppSpacing.xl),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: AppColors.lightGradient),
                      borderRadius: BorderRadius.circular(AppRadius.xl),
                      border: Border.all(color: const Color(0xFFBFDBFE)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(AppRadius.lg),
                          ),
                          child: const Icon(Icons.history_rounded,
                              color: AppColors.primary),
                        ),
                        const SizedBox(width: AppSpacing.lg),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Submission Timeline',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(fontWeight: FontWeight.w900),
                              ),
                              const SizedBox(height: AppSpacing.xs),
                              Text(
                                '$passed passed out of $total total submissions',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      color: AppColors.textMedium,
                                      fontWeight: FontWeight.w700,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }
                final m = (items[index - 1] is Map)
                    ? Map<String, dynamic>.from(items[index - 1] as Map)
                    : <String, dynamic>{};

                final id = '${m['id'] ?? ''}'.trim();
                final status = '${m['status'] ?? ''}'.trim();
                final isLate = m['is_late'] == true;
                final daysLate = '${m['days_late'] ?? ''}'.trim();
                final allowResubmission = m['allow_resubmission'] == true;
                final assignment = (m['assignments'] is Map)
                    ? Map<String, dynamic>.from(m['assignments'] as Map)
                    : <String, dynamic>{};
                final subject = '${assignment['subject'] ?? ''}'.trim();
                final assignmentNo = '${assignment['assignment_no'] ?? ''}'.trim();

                return _SubmissionCard(
                  submissionId: id.isEmpty ? '—' : id,
                  title: assignmentNo.isEmpty ? 'Submission' : assignmentNo,
                  subtitle: subject.isEmpty ? 'Subject' : subject,
                  status: status.isEmpty ? 'pending' : status,
                  lateLabel: isLate
                      ? (daysLate.isEmpty ? 'Late' : 'Late by $daysLate day(s)')
                      : 'On time',
                  allowResubmission: allowResubmission,
                  onTap: id.isEmpty
                      ? null
                      : () => context.push('/student/submission/$id'),
                );
              },
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
            onRetry: () => ref.invalidate(mySubmissionsProvider),
          ),
        ),
      ),
    );
  }
}

class _SubmissionCard extends StatelessWidget {
  final String submissionId;
  final String title;
  final String subtitle;
  final String status;
  final String lateLabel;
  final bool allowResubmission;
  final VoidCallback? onTap;

  const _SubmissionCard({
    required this.submissionId,
    required this.title,
    required this.subtitle,
    required this.status,
    required this.lateLabel,
    required this.allowResubmission,
    required this.onTap,
  });

  Color _statusColor() {
    switch (status.toLowerCase()) {
      case 'passed':
        return AppColors.success;
      case 'failed':
        return AppColors.error;
      case 'graded':
        return AppColors.success;
      case 'pending':
      default:
        return const Color(0xFF6366F1);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = _statusColor();
    final isPassed = status.toLowerCase() == 'passed';
    final isFailed = status.toLowerCase() == 'failed';
    return InkWell(
      borderRadius: BorderRadius.circular(AppRadius.xl),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.xl),
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
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: c.withOpacity(0.12),
                borderRadius: BorderRadius.circular(AppRadius.lg),
              ),
              child: Icon(
                status.toLowerCase() == 'graded'
                    || status.toLowerCase() == 'passed'
                    ? Icons.verified_rounded
                    : status.toLowerCase() == 'failed'
                        ? Icons.cancel_rounded
                    : Icons.schedule_rounded,
                color: c,
              ),
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
                        ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textMedium,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      _Pill(
                        color: c,
                        icon: Icons.bolt_rounded,
                        label: status.toUpperCase(),
                      ),
                      if (status.toLowerCase() == 'failed' && allowResubmission)
                        _Pill(
                          color: const Color(0xFF8B5CF6),
                          icon: Icons.refresh_rounded,
                          label: 'RESUBMIT ENABLED',
                        ),
                      _Pill(
                        color: lateLabel.toLowerCase().contains('late')
                            ? AppColors.warning
                            : AppColors.success,
                        icon: Icons.timer_rounded,
                        label: lateLabel,
                      ),
                      if (isPassed)
                        _Pill(
                          color: AppColors.success,
                          icon: Icons.emoji_events_rounded,
                          label: 'WELL DONE',
                        ),
                      if (isFailed)
                        _Pill(
                          color: AppColors.error,
                          icon: Icons.warning_amber_rounded,
                          label: 'TRY AGAIN',
                        ),
                    ],
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: AppColors.textLight),
          ],
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  final Color color;
  final IconData icon;
  final String label;

  const _Pill({required this.color, required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(AppRadius.full),
        border: Border.all(color: color.withOpacity(0.20)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 8),
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: color,
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
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.xl),
      children: [
        const SizedBox(height: 80),
        Container(
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
                  color: const Color(0xFF6366F1).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(AppRadius.xl),
                ),
                child: const Icon(Icons.history_rounded,
                    color: Color(0xFF6366F1), size: 28),
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
        ),
      ],
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
                'Couldn’t load submissions',
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

