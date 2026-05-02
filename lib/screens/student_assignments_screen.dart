import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../config/app_colors.dart';
import '../providers/providers.dart';

class StudentAssignmentsScreen extends ConsumerWidget {
  const StudentAssignmentsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncAssignments = ref.watch(studentAssignmentsProvider);

    return Scaffold(
      backgroundColor: AppColors.bgDark,
      appBar: AppBar(
        title: const Text('Assignments'),
        backgroundColor: Colors.transparent,
      ),
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(studentAssignmentsProvider),
        child: asyncAssignments.when(
          data: (items) {
            if (items.isEmpty) {
              return const _EmptyState(
                title: 'No active assignments',
                subtitle: 'When your faculty posts one, it will appear here.',
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(AppSpacing.xl),
              itemCount: items.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: AppSpacing.lg),
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
                          'Active Assignments',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.w900,
                                letterSpacing: -0.4,
                              ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          'Open assignment PDF in app and submit quickly.',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppColors.textMedium,
                                fontWeight: FontWeight.w700,
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
                final assignmentNo = '${m['assignment_no'] ?? ''}'.trim();
                final subject = '${m['subject'] ?? ''}'.trim();
                final givenDate = '${m['given_date'] ?? ''}'.trim();
                final submissionDate = '${m['submission_date'] ?? ''}'.trim();
                final difficulty = '${m['difficulty'] ?? ''}'.trim();
                final pdfUrl = '${m['pdf_url'] ?? ''}'.trim();

                return Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.lg),
                  child: _AssignmentCard(
                    assignmentNo: assignmentNo.isEmpty ? 'Assignment' : assignmentNo,
                    subject: subject.isEmpty ? 'Subject' : subject,
                    givenDate: givenDate.isEmpty ? '—' : givenDate,
                    submissionDate: submissionDate.isEmpty ? '—' : submissionDate,
                    difficulty: difficulty.isEmpty ? '—' : difficulty,
                    pdfUrl: pdfUrl,
                    assignmentId: id,
                  ),
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
            onRetry: () => ref.invalidate(studentAssignmentsProvider),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/student/submit-assignment'),
        label: const Text('Submit'),
        icon: const Icon(Icons.upload_file_rounded),
      ),
    );
  }
}

class _AssignmentCard extends StatelessWidget {
  final String assignmentNo;
  final String subject;
  final String givenDate;
  final String submissionDate;
  final String difficulty;
  final String pdfUrl;
  final String assignmentId;

  const _AssignmentCard({
    required this.assignmentNo,
    required this.subject,
    required this.givenDate,
    required this.submissionDate,
    required this.difficulty,
    required this.pdfUrl,
    required this.assignmentId,
  });

  void _openPdf(BuildContext context) {
    if (pdfUrl.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('PDF not available for this assignment'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    context.push('/student/pdf-view', extra: {
      'url': pdfUrl,
      'title': assignmentNo,
    });
  }

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
            blurRadius: 24,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                ),
                child: const Icon(Icons.assignment_rounded, color: AppColors.primary),
              ),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      assignmentNo,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.3,
                          ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      subject,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textMedium,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _Pill(
                icon: Icons.event_rounded,
                label: 'Given: $givenDate',
                color: const Color(0xFF22C55E),
              ),
              _Pill(
                icon: Icons.schedule_rounded,
                label: 'Submit by: $submissionDate',
                color: const Color(0xFF0EA5E9),
              ),
              _Pill(
                icon: Icons.auto_awesome_rounded,
                label: 'Difficulty: $difficulty',
                color: const Color(0xFF8B5CF6),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _openPdf(context),
                  icon: const Icon(Icons.picture_as_pdf_rounded),
                  label: const Text('View PDF'),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: assignmentId.isEmpty
                      ? null
                      : () => context.push(
                            '/student/submit-assignment',
                            extra: {'assignment_id': assignmentId},
                          ),
                  icon: const Icon(Icons.upload_file_rounded),
                  label: const Text('Submit'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _Pill({
    required this.icon,
    required this.label,
    required this.color,
  });

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
                  color: AppColors.primary.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(AppRadius.xl),
                ),
                child: const Icon(Icons.inbox_rounded,
                    color: AppColors.primary, size: 28),
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
                'Couldn’t load assignments',
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

