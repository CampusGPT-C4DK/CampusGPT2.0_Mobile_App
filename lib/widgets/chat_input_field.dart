import 'package:flutter/material.dart';
import '../config/app_colors.dart';
import '../config/animations.dart';

class ChatInputField extends StatefulWidget {
  final TextEditingController controller;
  final VoidCallback onSendPressed;
  final ValueChanged<String>? onChanged;
  final bool isLoading;

  const ChatInputField({
    Key? key,
    required this.controller,
    required this.onSendPressed,
    this.onChanged,
    this.isLoading = false,
  }) : super(key: key);

  @override
  State<ChatInputField> createState() => _ChatInputFieldState();
}

class _ChatInputFieldState extends State<ChatInputField>
    with SingleTickerProviderStateMixin {
  late FocusNode _focusNode;
  late AnimationController _animationController;
  late Animation<double> _iconAnimation;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _focusNode.addListener(_onFocusChange);

    _animationController = AnimationController(
      duration: AnimationDuration.normal,
      vsync: this,
    );

    _iconAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(_animationController);
  }

  void _onFocusChange() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });

    if (_isFocused) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final canSend = widget.controller.text.isNotEmpty && !widget.isLoading;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.bgLight,
        border: Border(
          top: BorderSide(
            color: AppColors.borderColor.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
      ),
      padding: const EdgeInsets.all(AppSpacing.md),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: AnimatedBuilder(
                animation: _iconAnimation,
                builder: (context, child) {
                  return Container(
                    decoration: BoxDecoration(
                      color: AppColors.bgWhite,
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                      border: Border.all(
                        color: Color.lerp(
                          AppColors.borderColor,
                          AppColors.primary,
                          _iconAnimation.value,
                        )!,
                        width: 1.5,
                      ),
                      boxShadow: [
                        if (_isFocused)
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.15),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: AppSpacing.md),
                          child: ScaleTransition(
                            scale: Tween<double>(begin: 0.8, end: 1.0).animate(
                              CurvedAnimation(
                                parent: _animationController,
                                curve: Curves.elasticOut,
                              ),
                            ),
                            child: Icon(
                              Icons.attach_file,
                              color: Color.lerp(
                                AppColors.textLight,
                                AppColors.primary,
                                _iconAnimation.value,
                              ),
                              size: 20,
                            ),
                          ),
                        ),
                        Expanded(
                          child: TextField(
                            controller: widget.controller,
                            focusNode: _focusNode,
                            onChanged: widget.onChanged,
                            maxLength: 1000,
                            maxLines: null,
                            textInputAction: TextInputAction.send,
                            onSubmitted: (_) {
                              if (canSend) {
                                widget.onSendPressed();
                              }
                            },
                            decoration: InputDecoration(
                              hintText: 'Ask CampusGPT...',
                              hintStyle: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(color: AppColors.textLight),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.md,
                                vertical: AppSpacing.md,
                              ),
                              counterText: '',
                            ),
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(color: AppColors.textDark),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            _buildSendButton(canSend),
          ],
        ),
      ),
    );
  }

  Widget _buildSendButton(bool canSend) {
    return GestureDetector(
      onTap: canSend ? widget.onSendPressed : null,
      child: ScaleTransition(
        scale: Tween<double>(begin: 1.0, end: 0.9).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeOutCubic,
          ),
        ),
        child: AnimatedContainer(
          duration: AnimationDuration.fast,
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            gradient: canSend
                ? const LinearGradient(
                    colors: AppColors.gradient,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
            color: canSend ? null : AppColors.bgDark,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            boxShadow: canSend
                ? [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : [],
          ),
          child: Center(
            child: widget.isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Colors.white,
                      ),
                    ),
                  )
                : Icon(
                    Icons.send_rounded,
                    color: canSend ? Colors.white : AppColors.textLight,
                    size: 20,
                  ),
          ),
        ),
      ),
    );
  }
}
