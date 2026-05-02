import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import '../config/app_colors.dart';

class StudentPdfViewerScreen extends StatefulWidget {
  final String url;
  final String title;

  const StudentPdfViewerScreen({
    super.key,
    required this.url,
    required this.title,
  });

  @override
  State<StudentPdfViewerScreen> createState() => _StudentPdfViewerScreenState();
}

class _StudentPdfViewerScreenState extends State<StudentPdfViewerScreen> {
  bool _isLoading = true;
  String? _loadError;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(
          widget.title,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      body: Container(
        margin: const EdgeInsets.all(AppSpacing.lg),
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
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.xl),
          child: Stack(
            children: [
              SfPdfViewer.network(
                widget.url,
                canShowPaginationDialog: true,
                canShowScrollHead: true,
                pageSpacing: 8,
                onDocumentLoaded: (_) {
                  if (mounted) setState(() => _isLoading = false);
                },
                onDocumentLoadFailed: (details) {
                  if (!mounted) return;
                  setState(() {
                    _isLoading = false;
                    _loadError = details.description;
                  });
                },
              ),
              if (_isLoading)
                const Center(
                  child: SizedBox(
                    width: 32,
                    height: 32,
                    child: CircularProgressIndicator(strokeWidth: 3),
                  ),
                ),
              if (_loadError != null)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.xl),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.error_outline_rounded,
                            color: AppColors.error, size: 28),
                        const SizedBox(height: AppSpacing.md),
                        Text(
                          'Could not load PDF in app',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w900,
                              ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          _loadError ?? '',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppColors.textLight,
                                fontWeight: FontWeight.w600,
                              ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
