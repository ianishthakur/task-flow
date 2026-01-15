import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../settings/presentation/pages/settings_page.dart';
import '../../domain/entities/task_entity.dart';
import '../bloc/task_bloc.dart';
import '../widgets/add_task_sheet.dart';
import '../widgets/category_filter.dart';
import '../widgets/empty_state.dart';
import '../widgets/stats_card.dart';
import '../widgets/task_card.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  late AnimationController _fabController;

  @override
  void initState() {
    super.initState();
    _fabController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _fabController.dispose();
    super.dispose();
  }

  void _showAddTaskSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const AddTaskSheet(),
    );
  }

  void _navigateToSettings() {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const SettingsPage(),
        transitionsBuilder: (_, animation, __, child) {
          return SlideTransition(
            position: Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero)
                .animate(
                  CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeOutCubic,
                  ),
                ),
            child: child,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: SafeArea(
        child: BlocBuilder<TaskBloc, TaskState>(
          builder: (context, state) {
            return CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // Header
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _getGreeting(),
                                  style: textTheme.bodyMedium?.copyWith(
                                    color: colorScheme.onSurface.withOpacity(
                                      0.6,
                                    ),
                                  ),
                                ).animate().fadeIn(duration: 400.ms),
                                4.vGap,
                                Text(
                                      'TaskFlow',
                                      style: textTheme.displaySmall?.copyWith(
                                        fontWeight: FontWeight.w700,
                                      ),
                                    )
                                    .animate()
                                    .fadeIn(delay: 100.ms, duration: 400.ms)
                                    .slideX(begin: -0.1, end: 0),
                              ],
                            ),
                            _buildProfileButton(colorScheme),
                          ],
                        ),
                        24.vGap,
                        // Stats Card
                        StatsCard(
                              totalTasks: state.totalTasks,
                              completedTasks: state.completedTasks,
                              completionRate: state.completionRate,
                            )
                            .animate()
                            .fadeIn(delay: 200.ms, duration: 500.ms)
                            .slideY(begin: 0.1, end: 0),
                        24.vGap,
                        // Category Filter
                        const CategoryFilter().animate().fadeIn(
                          delay: 300.ms,
                          duration: 400.ms,
                        ),
                        16.vGap,
                        // Section Header
                        _buildSectionHeader(state, textTheme, colorScheme),
                      ],
                    ),
                  ),
                ),

                // Task List
                if (state.isLoading)
                  const SliverFillRemaining(
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (state.filteredTasks.isEmpty)
                  SliverFillRemaining(
                    child: EmptyState(onAddTask: _showAddTaskSheet),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(24, 8, 24, 100),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final task = state.filteredTasks[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child:
                              TaskCard(
                                    task: task,
                                    onToggle: () => _toggleTask(task),
                                    onDelete: () => _deleteTask(task.id),
                                    onTap: () => _editTask(task),
                                  )
                                  .animate()
                                  .fadeIn(
                                    delay: Duration(milliseconds: 100 * index),
                                    duration: 400.ms,
                                  )
                                  .slideY(begin: 0.1, end: 0),
                        );
                      }, childCount: state.filteredTasks.length),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
      floatingActionButton: _buildFAB(colorScheme),
    );
  }

  Widget _buildProfileButton(ColorScheme colorScheme) {
    return GestureDetector(
          onTap: _navigateToSettings,
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: AppColors.premiumGradient,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: colorScheme.primary.withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(Iconsax.setting_2, color: Colors.white, size: 22),
          ),
        )
        .animate()
        .fadeIn(delay: 100.ms, duration: 400.ms)
        .scale(begin: const Offset(0.8, 0.8), end: const Offset(1, 1));
  }

  Widget _buildSectionHeader(
    TaskState state,
    TextTheme textTheme,
    ColorScheme colorScheme,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Your Tasks',
          style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: colorScheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            '${state.filteredTasks.length} items',
            style: textTheme.labelMedium?.copyWith(
              color: colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFAB(ColorScheme colorScheme) {
    return BlocBuilder<TaskBloc, TaskState>(
          builder: (context, state) {
            return Visibility(
              visible: state.filteredTasks.isNotEmpty,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: AppColors.premiumGradient,
                  boxShadow: [
                    BoxShadow(
                      color: colorScheme.primary.withOpacity(0.4),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: FloatingActionButton.extended(
                  onPressed: _showAddTaskSheet,
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  highlightElevation: 0,
                  icon: const Icon(Iconsax.add, color: Colors.white),
                  label: const Text(
                    'Add Task',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            );
          },
        )
        .animate()
        .fadeIn(delay: 500.ms, duration: 400.ms)
        .slideY(begin: 1, end: 0, curve: Curves.easeOutCubic);
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  void _toggleTask(TaskEntity task) {
    context.read<TaskBloc>().add(ToggleTaskCompletion(task));
  }

  void _deleteTask(String id) {
    context.read<TaskBloc>().add(DeleteTaskEvent(id));
  }

  void _editTask(TaskEntity task) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddTaskSheet(task: task),
    );
  }
}
