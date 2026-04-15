import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../cubit/today_state.dart';

class TaskRow extends StatelessWidget {
  final TodayItem item;
  final VoidCallback onTap;

  const TaskRow({super.key, required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final done = item.isDone;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: done ? AppColors.accent.withValues(alpha: 0.3) : Colors.transparent,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: done ? AppColors.accent : Colors.transparent,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: done ? AppColors.accent : AppColors.textSecondary,
                  width: 1.5,
                ),
              ),
              child: done
                  ? const Icon(Icons.check, size: 14, color: AppColors.background)
                  : null,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                item.task.name,
                style: TextStyle(
                  color: done ? AppColors.textSecondary : AppColors.textPrimary,
                  fontSize: 15,
                  decoration: done ? TextDecoration.lineThrough : null,
                  decorationColor: AppColors.textSecondary,
                ),
              ),
            ),
            if (item.task.duration != null)
              Text(
                item.task.duration!,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                ),
              ),
          ],
        ),
      ),
    );
  }
}