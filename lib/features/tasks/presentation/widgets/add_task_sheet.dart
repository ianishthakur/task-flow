import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/task_entity.dart';
import '../bloc/task_bloc.dart';

class AddTaskSheet extends StatefulWidget {
  final TaskEntity? task;
  
  const AddTaskSheet({super.key, this.task});

  @override
  State<AddTaskSheet> createState() => _AddTaskSheetState();
}

class _AddTaskSheetState extends State<AddTaskSheet> {
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late String _selectedCategory;
  late TaskPriority _selectedPriority;
  DateTime? _selectedDueDate;
  
  bool get isEditing => widget.task != null;
  
  static const List<Map<String, dynamic>> categories = [
    {'id': 'personal', 'name': 'Personal', 'icon': Iconsax.user, 'color': AppColors.violet},
    {'id': 'work', 'name': 'Work', 'icon': Iconsax.briefcase, 'color': AppColors.amber},
    {'id': 'health', 'name': 'Health', 'icon': Iconsax.heart, 'color': AppColors.emerald},
    {'id': 'shopping', 'name': 'Shopping', 'icon': Iconsax.bag_2, 'color': AppColors.rose},
  ];
  
  static const List<Map<String, dynamic>> priorities = [
    {'value': TaskPriority.low, 'name': 'Low', 'color': AppColors.emerald},
    {'value': TaskPriority.medium, 'name': 'Medium', 'color': AppColors.amber},
    {'value': TaskPriority.high, 'name': 'High', 'color': AppColors.coral},
  ];
  
  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task?.title ?? '');
    _descriptionController = TextEditingController(
      text: widget.task?.description ?? '',
    );
    _selectedCategory = widget.task?.category ?? 'personal';
    _selectedPriority = widget.task?.priority ?? TaskPriority.medium;
    _selectedDueDate = widget.task?.dueDate;
  }
  
  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;
    
    return Container(
      margin: EdgeInsets.only(bottom: bottomPadding),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: colorScheme.outline.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            24.vGap,
            
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  isEditing ? 'Edit Task' : 'New Task',
                  style: textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(
                    Iconsax.close_circle,
                    color: colorScheme.onSurface.withOpacity(0.4),
                  ),
                ),
              ],
            ).animate().fadeIn(duration: 300.ms),
            24.vGap,
            
            // Title Input
            Text(
              'Task Title',
              style: textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ).animate().fadeIn(delay: 50.ms, duration: 300.ms),
            10.vGap,
            TextField(
              controller: _titleController,
              autofocus: !isEditing,
              textCapitalization: TextCapitalization.sentences,
              style: textTheme.bodyLarge,
              decoration: const InputDecoration(
                hintText: 'Enter task title...',
                prefixIcon: Icon(Iconsax.edit_2, size: 20),
              ),
            ).animate().fadeIn(delay: 100.ms, duration: 300.ms),
            20.vGap,
            
            // Description Input
            Text(
              'Description (Optional)',
              style: textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ).animate().fadeIn(delay: 150.ms, duration: 300.ms),
            10.vGap,
            TextField(
              controller: _descriptionController,
              maxLines: 3,
              textCapitalization: TextCapitalization.sentences,
              style: textTheme.bodyMedium,
              decoration: const InputDecoration(
                hintText: 'Add more details...',
                alignLabelWithHint: true,
              ),
            ).animate().fadeIn(delay: 200.ms, duration: 300.ms),
            20.vGap,
            
            // Category Selection
            Text(
              'Category',
              style: textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ).animate().fadeIn(delay: 250.ms, duration: 300.ms),
            12.vGap,
            _buildCategorySelector(colorScheme, textTheme)
                .animate().fadeIn(delay: 300.ms, duration: 300.ms),
            20.vGap,
            
            // Priority Selection
            Text(
              'Priority',
              style: textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ).animate().fadeIn(delay: 350.ms, duration: 300.ms),
            12.vGap,
            _buildPrioritySelector(colorScheme, textTheme)
                .animate().fadeIn(delay: 400.ms, duration: 300.ms),
            20.vGap,
            
            // Due Date
            Text(
              'Due Date (Optional)',
              style: textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ).animate().fadeIn(delay: 450.ms, duration: 300.ms),
            12.vGap,
            _buildDatePicker(context, colorScheme, textTheme)
                .animate().fadeIn(delay: 500.ms, duration: 300.ms),
            32.vGap,
            
            // Submit Button
            SizedBox(
              width: double.infinity,
              child: GestureDetector(
                onTap: _submitTask,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  decoration: BoxDecoration(
                    gradient: AppColors.premiumGradient,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: colorScheme.primary.withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      isEditing ? 'Update Task' : 'Create Task',
                      style: textTheme.labelLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ).animate().fadeIn(delay: 550.ms, duration: 300.ms)
              .slideY(begin: 0.2, end: 0),
          ],
        ),
      ),
    );
  }
  
  Widget _buildCategorySelector(ColorScheme colorScheme, TextTheme textTheme) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: categories.map((category) {
        final isSelected = _selectedCategory == category['id'];
        final color = category['color'] as Color;
        
        return GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact();
            setState(() => _selectedCategory = category['id'] as String);
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isSelected ? color : colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isSelected ? color : Colors.transparent,
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  category['icon'] as IconData,
                  size: 18,
                  color: isSelected ? Colors.white : colorScheme.onSurface.withOpacity(0.6),
                ),
                8.hGap,
                Text(
                  category['name'] as String,
                  style: textTheme.labelMedium?.copyWith(
                    color: isSelected ? Colors.white : colorScheme.onSurface,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
  
  Widget _buildPrioritySelector(ColorScheme colorScheme, TextTheme textTheme) {
    return Row(
      children: priorities.map((priority) {
        final isSelected = _selectedPriority == priority['value'];
        final color = priority['color'] as Color;
        
        return Expanded(
          child: GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              setState(() => _selectedPriority = priority['value'] as TaskPriority);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: EdgeInsets.only(
                right: priority != priorities.last ? 10 : 0,
              ),
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: isSelected ? color.withOpacity(0.15) : colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isSelected ? color : Colors.transparent,
                  width: 2,
                ),
              ),
              child: Center(
                child: Text(
                  priority['name'] as String,
                  style: textTheme.labelMedium?.copyWith(
                    color: isSelected ? color : colorScheme.onSurface.withOpacity(0.6),
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
  
  Widget _buildDatePicker(
    BuildContext context, 
    ColorScheme colorScheme, 
    TextTheme textTheme,
  ) {
    return GestureDetector(
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: _selectedDueDate ?? DateTime.now(),
          firstDate: DateTime.now(),
          lastDate: DateTime.now().add(const Duration(days: 365)),
          builder: (context, child) {
            return Theme(
              data: Theme.of(context).copyWith(
                colorScheme: colorScheme,
              ),
              child: child!,
            );
          },
        );
        if (date != null) {
          HapticFeedback.lightImpact();
          setState(() => _selectedDueDate = date);
        }
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Iconsax.calendar_1,
                size: 20,
                color: colorScheme.primary,
              ),
            ),
            16.hGap,
            Expanded(
              child: Text(
                _selectedDueDate != null
                    ? DateFormat('EEEE, MMMM d, y').format(_selectedDueDate!)
                    : 'Select a date',
                style: textTheme.bodyMedium?.copyWith(
                  color: _selectedDueDate != null
                      ? colorScheme.onSurface
                      : colorScheme.onSurface.withOpacity(0.5),
                ),
              ),
            ),
            if (_selectedDueDate != null)
              GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  setState(() => _selectedDueDate = null);
                },
                child: Icon(
                  Iconsax.close_circle,
                  size: 20,
                  color: colorScheme.onSurface.withOpacity(0.4),
                ),
              ),
          ],
        ),
      ),
    );
  }
  
  void _submitTask() {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please enter a task title'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      return;
    }
    
    HapticFeedback.mediumImpact();
    
    if (isEditing) {
      final updatedTask = widget.task!.copyWith(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        category: _selectedCategory,
        priority: _selectedPriority,
        dueDate: _selectedDueDate,
        updatedAt: DateTime.now(),
      );
      context.read<TaskBloc>().add(UpdateTaskEvent(updatedTask));
    } else {
      context.read<TaskBloc>().add(AddTask(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        category: _selectedCategory,
        priority: _selectedPriority,
        dueDate: _selectedDueDate,
      ));
    }
    
    Navigator.pop(context);
  }
}
