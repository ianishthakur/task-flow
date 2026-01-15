import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/usecases/usecase.dart';
import '../../domain/entities/task_entity.dart';
import '../../domain/usecases/create_task.dart';
import '../../domain/usecases/delete_task.dart';
import '../../domain/usecases/get_tasks.dart';
import '../../domain/usecases/update_task.dart';

// Events
abstract class TaskEvent extends Equatable {
  const TaskEvent();
  
  @override
  List<Object?> get props => [];
}

class LoadTasks extends TaskEvent {}

class AddTask extends TaskEvent {
  final String title;
  final String? description;
  final String category;
  final TaskPriority priority;
  final DateTime? dueDate;
  
  const AddTask({
    required this.title,
    this.description,
    required this.category,
    this.priority = TaskPriority.medium,
    this.dueDate,
  });
  
  @override
  List<Object?> get props => [title, description, category, priority, dueDate];
}

class UpdateTaskEvent extends TaskEvent {
  final TaskEntity task;
  
  const UpdateTaskEvent(this.task);
  
  @override
  List<Object?> get props => [task];
}

class ToggleTaskCompletion extends TaskEvent {
  final TaskEntity task;
  
  const ToggleTaskCompletion(this.task);
  
  @override
  List<Object?> get props => [task];
}

class DeleteTaskEvent extends TaskEvent {
  final String taskId;
  
  const DeleteTaskEvent(this.taskId);
  
  @override
  List<Object?> get props => [taskId];
}

class FilterTasksByCategory extends TaskEvent {
  final String category;
  
  const FilterTasksByCategory(this.category);
  
  @override
  List<Object?> get props => [category];
}

class FilterTasksByStatus extends TaskEvent {
  final TaskFilterStatus filterStatus;
  
  const FilterTasksByStatus(this.filterStatus);
  
  @override
  List<Object?> get props => [filterStatus];
}

// Filter Status Enum
enum TaskFilterStatus { all, pending, completed }

// State
class TaskState extends Equatable {
  final List<TaskEntity> tasks;
  final List<TaskEntity> filteredTasks;
  final bool isLoading;
  final String? errorMessage;
  final String selectedCategory;
  final TaskFilterStatus filterStatus;
  
  const TaskState({
    this.tasks = const [],
    this.filteredTasks = const [],
    this.isLoading = false,
    this.errorMessage,
    this.selectedCategory = 'all',
    this.filterStatus = TaskFilterStatus.all,
  });
  
  TaskState copyWith({
    List<TaskEntity>? tasks,
    List<TaskEntity>? filteredTasks,
    bool? isLoading,
    String? errorMessage,
    String? selectedCategory,
    TaskFilterStatus? filterStatus,
  }) {
    return TaskState(
      tasks: tasks ?? this.tasks,
      filteredTasks: filteredTasks ?? this.filteredTasks,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      filterStatus: filterStatus ?? this.filterStatus,
    );
  }
  
  // Computed properties
  int get totalTasks => tasks.length;
  int get completedTasks => tasks.where((t) => t.isCompleted).length;
  int get pendingTasks => tasks.where((t) => !t.isCompleted).length;
  double get completionRate => totalTasks > 0 ? completedTasks / totalTasks : 0;
  
  List<TaskEntity> get todayTasks {
    final today = DateTime.now();
    return tasks.where((task) {
      if (task.dueDate == null) return false;
      return task.dueDate!.year == today.year &&
             task.dueDate!.month == today.month &&
             task.dueDate!.day == today.day;
    }).toList();
  }
  
  List<TaskEntity> get overdueTasks {
    final today = DateTime.now();
    return tasks.where((task) {
      if (task.dueDate == null || task.isCompleted) return false;
      return task.dueDate!.isBefore(DateTime(today.year, today.month, today.day));
    }).toList();
  }
  
  @override
  List<Object?> get props => [
    tasks,
    filteredTasks,
    isLoading,
    errorMessage,
    selectedCategory,
    filterStatus,
  ];
}

// BLoC
class TaskBloc extends Bloc<TaskEvent, TaskState> {
  final GetTasks getTasks;
  final CreateTask createTask;
  final UpdateTask updateTask;
  final DeleteTask deleteTask;
  
  TaskBloc({
    required this.getTasks,
    required this.createTask,
    required this.updateTask,
    required this.deleteTask,
  }) : super(const TaskState()) {
    on<LoadTasks>(_onLoadTasks);
    on<AddTask>(_onAddTask);
    on<UpdateTaskEvent>(_onUpdateTask);
    on<ToggleTaskCompletion>(_onToggleTaskCompletion);
    on<DeleteTaskEvent>(_onDeleteTask);
    on<FilterTasksByCategory>(_onFilterByCategory);
    on<FilterTasksByStatus>(_onFilterByStatus);
  }
  
  Future<void> _onLoadTasks(LoadTasks event, Emitter<TaskState> emit) async {
    emit(state.copyWith(isLoading: true));
    
    final result = await getTasks(const NoParams());
    
    result.fold(
      (failure) => emit(state.copyWith(
        isLoading: false,
        errorMessage: failure.message,
      )),
      (tasks) => emit(state.copyWith(
        isLoading: false,
        tasks: tasks,
        filteredTasks: _applyFilters(
          tasks, 
          state.selectedCategory, 
          state.filterStatus,
        ),
      )),
    );
  }
  
  Future<void> _onAddTask(AddTask event, Emitter<TaskState> emit) async {
    final now = DateTime.now();
    final newTask = TaskEntity(
      id: const Uuid().v4(),
      title: event.title,
      description: event.description,
      category: event.category,
      priority: event.priority,
      dueDate: event.dueDate,
      createdAt: now,
      updatedAt: now,
    );
    
    final result = await createTask(newTask);
    
    result.fold(
      (failure) => emit(state.copyWith(errorMessage: failure.message)),
      (task) {
        final updatedTasks = [task, ...state.tasks];
        emit(state.copyWith(
          tasks: updatedTasks,
          filteredTasks: _applyFilters(
            updatedTasks,
            state.selectedCategory,
            state.filterStatus,
          ),
        ));
      },
    );
  }
  
  Future<void> _onUpdateTask(
    UpdateTaskEvent event, 
    Emitter<TaskState> emit,
  ) async {
    final result = await updateTask(event.task);
    
    result.fold(
      (failure) => emit(state.copyWith(errorMessage: failure.message)),
      (updatedTask) {
        final updatedTasks = state.tasks.map((task) {
          return task.id == updatedTask.id ? updatedTask : task;
        }).toList();
        emit(state.copyWith(
          tasks: updatedTasks,
          filteredTasks: _applyFilters(
            updatedTasks,
            state.selectedCategory,
            state.filterStatus,
          ),
        ));
      },
    );
  }
  
  Future<void> _onToggleTaskCompletion(
    ToggleTaskCompletion event,
    Emitter<TaskState> emit,
  ) async {
    final updatedTask = event.task.copyWith(
      isCompleted: !event.task.isCompleted,
      updatedAt: DateTime.now(),
    );
    
    add(UpdateTaskEvent(updatedTask));
  }
  
  Future<void> _onDeleteTask(
    DeleteTaskEvent event, 
    Emitter<TaskState> emit,
  ) async {
    final result = await deleteTask(event.taskId);
    
    result.fold(
      (failure) => emit(state.copyWith(errorMessage: failure.message)),
      (_) {
        final updatedTasks = state.tasks
            .where((task) => task.id != event.taskId)
            .toList();
        emit(state.copyWith(
          tasks: updatedTasks,
          filteredTasks: _applyFilters(
            updatedTasks,
            state.selectedCategory,
            state.filterStatus,
          ),
        ));
      },
    );
  }
  
  void _onFilterByCategory(
    FilterTasksByCategory event,
    Emitter<TaskState> emit,
  ) {
    emit(state.copyWith(
      selectedCategory: event.category,
      filteredTasks: _applyFilters(
        state.tasks,
        event.category,
        state.filterStatus,
      ),
    ));
  }
  
  void _onFilterByStatus(
    FilterTasksByStatus event,
    Emitter<TaskState> emit,
  ) {
    emit(state.copyWith(
      filterStatus: event.filterStatus,
      filteredTasks: _applyFilters(
        state.tasks,
        state.selectedCategory,
        event.filterStatus,
      ),
    ));
  }
  
  List<TaskEntity> _applyFilters(
    List<TaskEntity> tasks,
    String category,
    TaskFilterStatus status,
  ) {
    var filtered = tasks;
    
    // Filter by category
    if (category != 'all' && category.isNotEmpty) {
      filtered = filtered.where((t) => t.category == category).toList();
    }
    
    // Filter by status
    switch (status) {
      case TaskFilterStatus.pending:
        filtered = filtered.where((t) => !t.isCompleted).toList();
        break;
      case TaskFilterStatus.completed:
        filtered = filtered.where((t) => t.isCompleted).toList();
        break;
      case TaskFilterStatus.all:
        break;
    }
    
    return filtered;
  }
}
