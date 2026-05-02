import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../config/app_colors.dart';
import '../providers/providers.dart';

class EvaluationResultEntryScreen extends ConsumerStatefulWidget {
  const EvaluationResultEntryScreen({super.key});

  @override
  ConsumerState<EvaluationResultEntryScreen> createState() =>
      _EvaluationResultEntryScreenState();
}

class _EvaluationResultEntryScreenState
    extends ConsumerState<EvaluationResultEntryScreen> {
  final _idCtrl = TextEditingController();
  bool _opening = false;

  @override
  void dispose() {
    _idCtrl.dispose();
    super.dispose();
  }

  Future<void> _open() async {
    final id = _idCtrl.text.trim();
    if (id.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter submission id'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    final uuidLike = RegExp(
      r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[1-5][0-9a-fA-F]{3}-[89abAB][0-9a-fA-F]{3}-[0-9a-fA-F]{12}$',
    );
    if (!uuidLike.hasMatch(id)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Enter a valid submission ID (UUID format)'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    setState(() => _opening = true);
    try {
      final res = await ref.read(studentServiceProvider).getEvaluationResult(id);
      if (!mounted) return;
      final status = '${res['status'] ?? ''}'.trim().toLowerCase();
      if (status == 'success' || status == 'not_evaluated') {
        await context.push('/evaluation/results/view/$id');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Result unavailable for this submission ID'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invalid or unknown submission ID'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _opening = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      appBar: AppBar(
        title: const Text('Evaluation Result'),
        backgroundColor: Colors.transparent,
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.xl),
        children: [
          Container(
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
                Text(
                  'Open by Submission ID',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Paste your submission id to view results (if graded).',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textLight,
                        height: 1.4,
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: AppSpacing.lg),
                TextField(
                  controller: _idCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Submission ID',
                    hintText: 'Paste submission UUID',
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _opening ? null : _open,
                    icon: _opening
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.4,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.verified_rounded),
                    label: Text(_opening ? 'Opening...' : 'Open Result'),
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

