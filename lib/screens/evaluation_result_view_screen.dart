import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../config/app_colors.dart';
import '../providers/providers.dart';

class EvaluationResultViewScreen extends ConsumerWidget {
  final String submissionId;

  const EvaluationResultViewScreen({super.key, required this.submissionId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      appBar: AppBar(
        title: const Text('Result'),
        backgroundColor: Colors.transparent,
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: ref.read(studentServiceProvider).getEvaluationResult(submissionId),
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
            return _ErrorState(message: snap.error.toString());
          }

          final data = snap.data ?? {};
          final status = '${data['status'] ?? ''}'.trim();
          final evaluation = (data['evaluation'] is Map)
              ? Map<String, dynamic>.from(data['evaluation'] as Map)
              : null;

          if (status == 'not_evaluated' || evaluation == null) {
            return const _EmptyState(
              title: 'Not graded yet',
              subtitle: 'Your submission is not evaluated. Check again later.',
            );
          }

          final marksObtained = evaluation['marks_obtained'];
          final totalMarks = evaluation['total_marks'];
          final grade = '${evaluation['grade'] ?? '—'}';
          final percentage = evaluation['percentage'];
          final feedback = '${evaluation['feedback'] ?? ''}'.trim();
          final allowResubmission = data['allow_resubmission'] == true;
          final resultStatus = (evaluation['result_status']?.toString().trim().toLowerCase() ??
              ((marksObtained is num && totalMarks is num && totalMarks > 0 && (marksObtained / totalMarks) * 100 < 40)
                  ? 'failed'
                  : 'passed'));

          return ListView(
            padding: const EdgeInsets.all(AppSpacing.xl),
            children: [
              _HeroCard(
                grade: grade,
                subtitle:
                    'Submission #$submissionId • ${percentage == null ? '—' : '$percentage%'} • ${resultStatus.toUpperCase()}',
                marks: '${marksObtained ?? '—'} / ${totalMarks ?? '—'}',
              ),
              const SizedBox(height: AppSpacing.lg),
              if (resultStatus == 'failed')
                _InfoCard(
                  title: 'Result Status',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        allowResubmission
                            ? 'You did not pass this submission. Resubmission is enabled by faculty.'
                            : 'You did not pass this submission. Resubmission is currently disabled.',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.textMedium,
                              fontWeight: FontWeight.w600,
                              height: 1.4,
                            ),
                      ),
                      if (allowResubmission) ...[
                        const SizedBox(height: AppSpacing.md),
                        OutlinedButton.icon(
                          onPressed: () => context.push('/student/my-submissions'),
                          icon: const Icon(Icons.refresh_rounded),
                          label: const Text('Go to My Submissions'),
                        ),
                      ],
                    ],
                  ),
                ),
              if (resultStatus == 'failed') const SizedBox(height: AppSpacing.lg),
              if (feedback.isNotEmpty)
                _InfoCard(
                  title: 'Feedback',
                  child: Text(
                    feedback,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          height: 1.45,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textDark,
                        ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _HeroCard extends StatelessWidget {
  final String grade;
  final String subtitle;
  final String marks;

  const _HeroCard({
    required this.grade,
    required this.subtitle,
    required this.marks,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [
          Color(0xFF2563EB),
          Color(0xFF60A5FA),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.18),
              borderRadius: BorderRadius.circular(AppRadius.xl),
              border: Border.all(color: Colors.white.withOpacity(0.18)),
            ),
            child: const Icon(Icons.verified_rounded, color: Colors.white),
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  grade,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: -0.6,
                      ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.white.withOpacity(0.9),
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: AppSpacing.lg),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.18),
                    borderRadius: BorderRadius.circular(AppRadius.full),
                  ),
                  child: Text(
                    marks,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.2,
                    ),
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
                  color: const Color(0xFF8B5CF6).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(AppRadius.xl),
                ),
                child: const Icon(Icons.hourglass_top_rounded,
                    color: Color(0xFF8B5CF6), size: 28),
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
  const _ErrorState({required this.message});

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
                'Couldn’t load result',
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
            ],
          ),
        ),
      ],
    );
  }
}

