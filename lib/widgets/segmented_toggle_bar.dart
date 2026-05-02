import 'package:flutter/material.dart';
import '../config/app_colors.dart';

class SegmentedToggleBar extends StatelessWidget {
  final int value;
  final List<String> items;
  final ValueChanged<int> onChanged;

  const SegmentedToggleBar({
    super.key,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.full),
        border: Border.all(color: AppColors.border),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadowColor,
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: List.generate(items.length, (index) {
          final selected = index == value;
          return Expanded(
            child: InkWell(
              borderRadius: BorderRadius.circular(AppRadius.full),
              onTap: () => onChanged(index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeOutCubic,
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppRadius.full),
                  gradient: selected
                      ? const LinearGradient(colors: AppColors.gradient)
                      : null,
                  color: selected ? null : Colors.transparent,
                ),
                child: Center(
                  child: AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 180),
                    curve: Curves.easeOutCubic,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: selected
                                  ? Colors.white
                                  : AppColors.textMedium,
                            ) ??
                        TextStyle(
                          fontWeight: FontWeight.w800,
                          color: selected ? Colors.white : AppColors.textMedium,
                        ),
                    child: Text(items[index]),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

