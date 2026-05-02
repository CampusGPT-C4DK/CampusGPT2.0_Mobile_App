import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../config/app_colors.dart';
import '../providers/providers.dart';

class StudentSubmitAssignmentScreen extends ConsumerStatefulWidget {
  final String? initialAssignmentId;

  const StudentSubmitAssignmentScreen({super.key, this.initialAssignmentId});

  @override
  ConsumerState<StudentSubmitAssignmentScreen> createState() =>
      _StudentSubmitAssignmentScreenState();
}

class _StudentSubmitAssignmentScreenState
    extends ConsumerState<StudentSubmitAssignmentScreen> {
  final _assignmentIdCtrl = TextEditingController();
  File? _pickedPdf;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialAssignmentId != null) {
      _assignmentIdCtrl.text = widget.initialAssignmentId!;
    }
  }

  @override
  void dispose() {
    _assignmentIdCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickPdf() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['pdf'],
      withData: false,
    );
    if (!mounted) return;
    if (result == null || result.files.isEmpty) return;
    final path = result.files.single.path;
    if (path == null) return;
    setState(() => _pickedPdf = File(path));
  }

  Future<void> _submit() async {
    final assignmentId = _assignmentIdCtrl.text.trim();
    if (assignmentId.isEmpty) {
      _toast('Please enter assignment id');
      return;
    }
    if (_pickedPdf == null) {
      _toast('Please pick a PDF file');
      return;
    }

    setState(() => _loading = true);
    try {
      final service = ref.read(studentServiceProvider);
      final res = await service.submitAssignment(
        assignmentId: assignmentId,
        pdfFile: _pickedPdf!,
      );

      if (!mounted) return;
      ref.invalidate(mySubmissionsProvider);
      _showSuccessSheet(context, res);
    } catch (e) {
      if (!mounted) return;
      _toast(e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _toast(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }

  void _showSuccessSheet(BuildContext context, Map<String, dynamic> res) {
    final submissionId = '${res['submission_id'] ?? ''}'.trim();
    final message = '${res['message'] ?? ''}'.trim();
    final isResubmission = res['is_resubmission'] == true;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
      ),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(AppRadius.full),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(AppRadius.xl),
                ),
                child: const Icon(Icons.check_circle_rounded,
                    color: AppColors.success, size: 30),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                isResubmission ? 'Resubmitted successfully' : 'Submitted successfully',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                submissionId.isEmpty
                    ? (message.isEmpty ? 'Your submission is uploaded.' : message)
                    : 'Submission ID: $submissionId',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textMedium,
                      fontWeight: FontWeight.w600,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.lg),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.textDark,
                        side: const BorderSide(color: AppColors.border),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadius.lg),
                        ),
                      ),
                      child: const Text('Close'),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.lg),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        if (submissionId.isNotEmpty) {
                          Navigator.of(this.context).pop();
                        }
                      },
                      child: const Text('Done'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      appBar: AppBar(
        title: const Text('Submit Assignment'),
        backgroundColor: Colors.transparent,
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.xl),
        children: [
          Container(
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
                  widget.initialAssignmentId == null
                      ? 'Quick Assignment Upload'
                      : 'Resubmit Assignment',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.4,
                      ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Upload PDF directly and track status in My Submissions.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textMedium,
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ],
            ),
          ),
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
                  'Upload PDF',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  widget.initialAssignmentId == null
                      ? 'Enter assignment id and upload a PDF file only.'
                      : 'Assignment preselected. Upload a new PDF to submit or resubmit.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textLight,
                        height: 1.4,
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: AppSpacing.md),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEEF2FF),
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                    border: Border.all(color: const Color(0xFFC7D2FE)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.info_outline_rounded,
                          color: Color(0xFF4F46E5), size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Only PDF is accepted. Make sure your file is clear and complete before submitting.',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: const Color(0xFF4338CA),
                                fontWeight: FontWeight.w700,
                                height: 1.35,
                              ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                TextField(
                  controller: _assignmentIdCtrl,
                  keyboardType: TextInputType.text,
                  decoration: const InputDecoration(
                    labelText: 'Assignment ID',
                    hintText: 'Paste assignment UUID',
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                InkWell(
                  onTap: _pickPdf,
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  child: Container(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    decoration: BoxDecoration(
                      color: AppColors.bgLight,
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(AppRadius.lg),
                          ),
                          child: const Icon(Icons.picture_as_pdf_rounded,
                              color: AppColors.primary),
                        ),
                        const SizedBox(width: AppSpacing.lg),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _pickedPdf == null
                                    ? 'Choose PDF'
                                    : _pickedPdf!.uri.pathSegments.last,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleSmall
                                    ?.copyWith(fontWeight: FontWeight.w900),
                              ),
                              const SizedBox(height: AppSpacing.xs),
                              Text(
                                _pickedPdf == null
                                    ? 'Tap to pick a file'
                                    : 'Ready to upload',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      color: AppColors.textLight,
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                            ],
                          ),
                        ),
                        if (_pickedPdf != null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 5),
                            decoration: BoxDecoration(
                              color: AppColors.success.withValues(alpha: 0.12),
                              borderRadius:
                                  BorderRadius.circular(AppRadius.full),
                              border: Border.all(
                                color: AppColors.success.withValues(alpha: 0.2),
                              ),
                            ),
                            child: const Text(
                              'SELECTED',
                              style: TextStyle(
                                color: AppColors.success,
                                fontWeight: FontWeight.w900,
                                fontSize: 10,
                              ),
                            ),
                          ),
                        const Icon(Icons.upload_rounded,
                            color: AppColors.textLight),
                      ],
                    ),
                  ),
                ),
                if (_pickedPdf != null) ...[
                  const SizedBox(height: AppSpacing.md),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: AppColors.success.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                      border: Border.all(
                        color: AppColors.success.withValues(alpha: 0.20),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.check_circle_rounded,
                            color: AppColors.success, size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'PDF selected and ready to submit',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: AppColors.success,
                                  fontWeight: FontWeight.w800,
                                ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: AppSpacing.xl),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _loading ? null : _submit,
                    icon: _loading
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.cloud_upload_rounded),
                    label: Text(_loading ? 'Submitting...' : 'Submit'),
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

