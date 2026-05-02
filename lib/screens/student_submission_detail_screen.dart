import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../config/app_colors.dart';
import '../providers/providers.dart';

class StudentSubmissionDetailScreen extends ConsumerWidget {
  final String submissionId;

  const StudentSubmissionDetailScreen({super.key, required this.submissionId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      appBar: AppBar(
        title: const Text('Submission Details'),
        backgroundColor: Colors.transparent,
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: ref.read(studentServiceProvider).getSubmission(submissionId),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(
              child: SizedBox(
                width: 28,
                height: 28,
                child: CircularProgressIndicator(strokeWidth: 3),
              ),
            );
          }
          if (snap.hasError) {
            return _ErrorState(
              message: snap.error.toString(),
              onRetry: () => (context as Element).markNeedsBuild(),
            );
          }

          final data = snap.data ?? {};
          final submission = (data['submission'] is Map)
              ? Map<String, dynamic>.from(data['submission'] as Map)
              : <String, dynamic>{};
          final evaluation = (data['evaluation'] is Map)
              ? Map<String, dynamic>.from(data['evaluation'] as Map)
              : null;

          final status = '${submission['status'] ?? ''}'.trim();
          final assignmentId = '${submission['assignment_id'] ?? ''}'.trim();
          final isLate = submission['is_late'] == true;
          final daysLate = '${submission['days_late'] ?? ''}'.trim();
          final allowResubmission = data['allow_resubmission'] == true;
          final isFailed = status.toLowerCase() == 'failed';

          return ListView(
            padding: const EdgeInsets.all(AppSpacing.xl),
            children: [
              _InfoCard(
                title: 'Submission #$submissionId',
                subtitle: status.isEmpty ? '—' : status,
                chips: [
                  _chip(
                    label: status.isEmpty ? 'PENDING' : status.toUpperCase(),
                    color: status.toLowerCase() == 'failed'
                        ? AppColors.error
                        : (status.toLowerCase() == 'graded' ||
                                status.toLowerCase() == 'passed')
                            ? AppColors.success
                            : const Color(0xFF6366F1),
                  ),
                  _chip(
                    label: isLate
                        ? (daysLate.isEmpty
                            ? 'LATE'
                            : 'LATE ($daysLate day(s))')
                        : 'ON TIME',
                    color: isLate ? AppColors.warning : AppColors.success,
                  ),
                ],
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: AppSpacing.lg),
                    Text(
                      isFailed
                          ? 'Your submission is marked failed. Check feedback and resubmit if enabled.'
                          : 'Submission status and faculty evaluation are shown below.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textLight,
                            height: 1.4,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    if (isFailed && allowResubmission && assignmentId.isNotEmpty) ...[
                      const SizedBox(height: AppSpacing.lg),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () => context.push(
                            '/student/submit-assignment',
                            extra: {'assignment_id': assignmentId},
                          ),
                          icon: const Icon(Icons.refresh_rounded),
                          label: const Text('Resubmit Assignment'),
                        ),
                      ),
                    ],
                    // (Optional) submitted_file_url can be wired to open file in browser.
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              _InfoCard(
                title: 'Evaluation',
                subtitle: evaluation == null ? 'Not graded yet' : 'Available',
                child: evaluation == null
                    ? Text(
                        'Your faculty has not graded this submission yet.',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.textLight,
                              height: 1.4,
                              fontWeight: FontWeight.w600,
                            ),
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Marks: ${evaluation['marks_obtained'] ?? '—'} / ${evaluation['total_marks'] ?? '—'}\nGrade: ${evaluation['grade'] ?? '—'}',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  height: 1.4,
                                ),
                          ),
                          if ('${evaluation['feedback'] ?? ''}'.trim().isNotEmpty) ...[
                            const SizedBox(height: AppSpacing.lg),
                            Text(
                              'Feedback',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall
                                  ?.copyWith(fontWeight: FontWeight.w900),
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            Text(
                              '${evaluation['feedback'] ?? ''}'.trim(),
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: AppColors.textMedium,
                                    height: 1.45,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                          ],
                        ],
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _chip({required String label, required Color color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(AppRadius.full),
        border: Border.all(color: color.withOpacity(0.20)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontWeight: FontWeight.w900,
          color: color,
          fontSize: 12,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final List<Widget> chips;
  final Widget child;

  const _InfoCard({
    required this.title,
    required this.subtitle,
    this.chips = const [],
    required this.child,
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
            blurRadius: 22,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                  ],
                ),
              ),
              if (chips.isNotEmpty) ...[
                const SizedBox(width: AppSpacing.md),
                Wrap(spacing: 10, runSpacing: 10, children: chips),
              ],
            ],
          ),
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
                'Couldn’t load details',
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

