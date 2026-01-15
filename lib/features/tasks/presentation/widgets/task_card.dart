import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/task_entity.dart';

class TaskCard extends StatelessWidget {
  final TaskEntity task;
  final VoidCallback onToggle;
  final VoidCallback onDelete;
  final VoidCallback onTap;
  
  const TaskCard({
    super.key,
    required this.task,
    required this.onToggle,
    required this.onDelete,
    required this.onTap,
  });
  
  Color _getCategoryColor() {
    switch (task.category) {
      case 'personal':
        return AppColors.violet;
      case 'work':
        return AppColors.amber;
      case 'health':
        return AppColors.emerald;
      case 'shopping':
        return AppColors.rose;
      default:
        return AppColors.sky;
    }
  }
  
  IconData _getPriorityIcon() {
    switch (task.priority) {
      case TaskPriority.high:
        return Iconsax.danger5;
      case TaskPriority.medium:
        return Iconsax.flag;
      case TaskPriority.low:
        return Iconsax.flag_2;
    }
  }
  
  Color _getPriorityColor() {
    switch (task.priority) {
      case TaskPriority.high:
        return AppColors.coral;
      case TaskPriority.medium:
        return AppColors.amber;
      case TaskPriority.low:
        return AppColors.emerald;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final categoryColor = _getCategoryColor();
    
    return Dismissible(
      key: Key(task.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) {
        HapticFeedback.mediumImpact();
        onDelete();
      },
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        decoration: BoxDecoration(
          color: AppColors.coral.withOpacity(0.2),
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Icon(
          Iconsax.trash,
          color: AppColors.coral,
        ),
      ),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: task.isCompleted
                  ? colorScheme.outline.withOpacity(0.3)
                  : categoryColor.withOpacity(0.3),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: categoryColor.withOpacity(task.isCompleted ? 0 : 0.08),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildCheckbox(colorScheme, categoryColor),
              16.hGap,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            task.title,
                            style: textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              decoration: task.isCompleted
                                  ? TextDecoration.lineThrough
                                  : null,
                              color: task.isCompleted
                                  ? colorScheme.onSurface.withOpacity(0.4)
                                  : null,
                            ),
                          ),
                        ),
                        _buildPriorityBadge(),
                      ],
                    ),
                    if (task.description != null && 
                        task.description!.isNotEmpty) ...[
                      8.vGap,
                      Text(
                        task.description!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurface.withOpacity(0.5),
                        ),
                      ),
                    ],
                    12.vGap,
                    Row(
                      children: [
                        _buildCategoryChip(textTheme, categoryColor),
                        if (task.dueDate != null) ...[
                          12.hGap,
                          _buildDueDateChip(context, textTheme),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildCheckbox(ColorScheme colorScheme, Color categoryColor) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onToggle();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: task.isCompleted ? categoryColor : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: task.isCompleted
                ? categoryColor
                : colorScheme.onSurface.withOpacity(0.2),
            width: 2,
          ),
        ),
        child: task.isCompleted
            ? const Icon(
                Icons.check_rounded,
                size: 18,
                color: Colors.white,
              )
            : null,
      ),
    );
  }
  
  Widget _buildPriorityBadge() {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: _getPriorityColor().withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        _getPriorityIcon(),
        size: 14,
        color: _getPriorityColor(),
      ),
    );
  }
  
  Widget _buildCategoryChip(TextTheme textTheme, Color categoryColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: categoryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        task.category.substring(0, 1).toUpperCase() + 
            task.category.substring(1),
        style: textTheme.labelSmall?.copyWith(
          color: categoryColor,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
  
  Widget _buildDueDateChip(BuildContext context, TextTheme textTheme) {
    final colorScheme = Theme.of(context).colorScheme;
    final isOverdue = task.dueDate!.isBefore(DateTime.now()) && !task.isCompleted;
    final isToday = _isToday(task.dueDate!);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isOverdue
            ? AppColors.coral.withOpacity(0.1)
            : colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Iconsax.calendar_1,
            size: 12,
            color: isOverdue
                ? AppColors.coral
                : colorScheme.onSurface.withOpacity(0.5),
          ),
          4.hGap,
          Text(
            isToday ? 'Today' : DateFormat('MMM d').format(task.dueDate!),
            style: textTheme.labelSmall?.copyWith(
              color: isOverdue
                  ? AppColors.coral
                  : colorScheme.onSurface.withOpacity(0.5),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
  
  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
           date.month == now.month &&
           date.day == now.day;
  }
}
