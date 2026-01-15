import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../core/theme/app_theme.dart';
import '../bloc/task_bloc.dart';

class CategoryFilter extends StatelessWidget {
  const CategoryFilter({super.key});

  static const List<Map<String, dynamic>> categories = [
    {
      'id': 'all',
      'name': 'All',
      'icon': Iconsax.element_4,
      'color': AppColors.sky,
    },
    {
      'id': 'personal',
      'name': 'Personal',
      'icon': Iconsax.user,
      'color': AppColors.violet,
    },
    {
      'id': 'work',
      'name': 'Work',
      'icon': Iconsax.briefcase,
      'color': AppColors.amber,
    },
    {
      'id': 'health',
      'name': 'Health',
      'icon': Iconsax.heart,
      'color': AppColors.emerald,
    },
    {
      'id': 'shopping',
      'name': 'Shopping',
      'icon': Iconsax.bag_2,
      'color': AppColors.rose,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TaskBloc, TaskState>(
      builder: (context, state) {
        return SizedBox(
          height: 44,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: categories.length,
            separatorBuilder: (_, __) => 10.hGap,
            itemBuilder: (context, index) {
              final category = categories[index];
              final isSelected = state.selectedCategory == category['id'];

              return _CategoryChip(
                name: category['name'] as String,
                icon: category['icon'] as IconData,
                color: category['color'] as Color,
                isSelected: isSelected,
                onTap: () {
                  HapticFeedback.lightImpact();
                  context.read<TaskBloc>().add(
                    FilterTasksByCategory(category['id']),
                  );
                },
              );
            },
          ),
        );
      },
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String name;
  final IconData icon;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryChip({
    required this.name,
    required this.icon,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected ? color : colorScheme.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? color : colorScheme.outline.withOpacity(0.3),
            width: 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected
                  ? Colors.white
                  : colorScheme.onSurface.withOpacity(0.6),
            ),
            8.hGap,
            Text(
              name,
              style: textTheme.labelMedium?.copyWith(
                color: isSelected
                    ? Colors.white
                    : colorScheme.onSurface.withOpacity(0.8),
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
