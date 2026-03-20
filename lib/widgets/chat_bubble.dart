import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../config/app_colors.dart';
import '../config/animations.dart';

class ChatBubble extends StatefulWidget {
  final String message;
  final bool isUser;
  final DateTime timestamp;
  final List<String>? sources;
  final double? confidence;

  const ChatBubble({
    Key? key,
    required this.message,
    required this.isUser,
    required this.timestamp,
    this.sources,
    this.confidence,
  }) : super(key: key);

  @override
  State<ChatBubble> createState() => _ChatBubbleState();
}

class _ChatBubbleState extends State<ChatBubble>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: AnimationDuration.normal,
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));

    _slideAnimation = Tween<Offset>(
      begin: widget.isUser ? const Offset(0.3, 0) : const Offset(-0.3, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Column(
          crossAxisAlignment:
              widget.isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.only(
                left: widget.isUser ? 0 : AppSpacing.lg,
                right: widget.isUser ? AppSpacing.lg : 0,
                bottom: AppSpacing.sm,
              ),
              child: Text(
                DateFormat('h:mm a').format(widget.timestamp),
                style: Theme.of(
                  context,
                ).textTheme.labelSmall?.copyWith(color: AppColors.textLight),
              ),
            ),
            Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.75,
              ),
              decoration: BoxDecoration(
                gradient: widget.isUser
                    ? const LinearGradient(colors: AppColors.gradient)
                    : null,
                color: widget.isUser ? null : AppColors.bgDark,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(AppRadius.lg),
                  topRight: const Radius.circular(AppRadius.lg),
                  bottomLeft: Radius.circular(
                    widget.isUser ? AppRadius.lg : AppRadius.xs,
                  ),
                  bottomRight: Radius.circular(
                    widget.isUser ? AppRadius.xs : AppRadius.lg,
                  ),
                ),
                boxShadow: const [
                  BoxShadow(
                    color: AppColors.shadowColor,
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Main message with better text rendering
                  _buildFormattedText(context),
                  if (!widget.isUser && widget.confidence != null)
                    Padding(
                      padding: const EdgeInsets.only(top: AppSpacing.md),
                      child: _buildConfidenceBadge(context),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormattedText(BuildContext context) {
    // Split text into paragraphs to handle multi-line content better
    final paragraphs = widget.message.split('\n\n').where((p) => p.isNotEmpty);

    if (paragraphs.isEmpty) {
      return Text(
        widget.message,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: widget.isUser ? Colors.white : AppColors.textDark,
              height: 1.6,
            ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: paragraphs.map((para) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: para == paragraphs.last ? 0 : AppSpacing.md,
          ),
          child: Text(
            para.trim(),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: widget.isUser ? Colors.white : AppColors.textDark,
                  height: 1.6,
                ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildConfidenceBadge(BuildContext context) {
    final confidence = widget.confidence ?? 0;
    final color = confidence > 80
        ? AppColors.success
        : confidence > 50
            ? AppColors.warning
            : AppColors.error;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(AppRadius.full),
        border: Border.all(color: color),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.trending_up, size: 14, color: color),
          const SizedBox(width: AppSpacing.sm),
          Text(
            'Confidence: ${confidence.toStringAsFixed(1)}%',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }
}
