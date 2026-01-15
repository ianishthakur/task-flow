import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/usecases/usecase.dart';
import '../../domain/entities/settings_entity.dart';
import '../../domain/usecases/get_settings.dart';
import '../../domain/usecases/update_settings.dart';

// Events
abstract class SettingsEvent extends Equatable {
  const SettingsEvent();
  
  @override
  List<Object?> get props => [];
}

class LoadSettings extends SettingsEvent {}

class ToggleDarkMode extends SettingsEvent {}

class ToggleNotifications extends SettingsEvent {}

class UpdateDefaultCategory extends SettingsEvent {
  final String category;
  
  const UpdateDefaultCategory(this.category);
  
  @override
  List<Object?> get props => [category];
}

class ToggleShowCompletedTasks extends SettingsEvent {}

// State
class SettingsState extends Equatable {
  final bool isDarkMode;
  final bool notificationsEnabled;
  final String defaultCategory;
  final bool showCompletedTasks;
  final bool isLoading;
  final String? errorMessage;
  
  const SettingsState({
    this.isDarkMode = false,
    this.notificationsEnabled = true,
    this.defaultCategory = 'personal',
    this.showCompletedTasks = true,
    this.isLoading = false,
    this.errorMessage,
  });
  
  SettingsState copyWith({
    bool? isDarkMode,
    bool? notificationsEnabled,
    String? defaultCategory,
    bool? showCompletedTasks,
    bool? isLoading,
    String? errorMessage,
  }) {
    return SettingsState(
      isDarkMode: isDarkMode ?? this.isDarkMode,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      defaultCategory: defaultCategory ?? this.defaultCategory,
      showCompletedTasks: showCompletedTasks ?? this.showCompletedTasks,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
  
  SettingsEntity toEntity() {
    return SettingsEntity(
      isDarkMode: isDarkMode,
      notificationsEnabled: notificationsEnabled,
      defaultCategory: defaultCategory,
      showCompletedTasks: showCompletedTasks,
    );
  }
  
  @override
  List<Object?> get props => [
    isDarkMode,
    notificationsEnabled,
    defaultCategory,
    showCompletedTasks,
    isLoading,
    errorMessage,
  ];
}

// BLoC
class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  final GetSettings getSettings;
  final UpdateSettings updateSettings;
  
  SettingsBloc({
    required this.getSettings,
    required this.updateSettings,
  }) : super(const SettingsState()) {
    on<LoadSettings>(_onLoadSettings);
    on<ToggleDarkMode>(_onToggleDarkMode);
    on<ToggleNotifications>(_onToggleNotifications);
    on<UpdateDefaultCategory>(_onUpdateDefaultCategory);
    on<ToggleShowCompletedTasks>(_onToggleShowCompletedTasks);
  }
  
  Future<void> _onLoadSettings(
    LoadSettings event, 
    Emitter<SettingsState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));
    
    final result = await getSettings(const NoParams());
    
    result.fold(
      (failure) => emit(state.copyWith(
        isLoading: false,
        errorMessage: failure.message,
      )),
      (settings) => emit(state.copyWith(
        isLoading: false,
        isDarkMode: settings.isDarkMode,
        notificationsEnabled: settings.notificationsEnabled,
        defaultCategory: settings.defaultCategory,
        showCompletedTasks: settings.showCompletedTasks,
      )),
    );
  }
  
  Future<void> _onToggleDarkMode(
    ToggleDarkMode event,
    Emitter<SettingsState> emit,
  ) async {
    final newState = state.copyWith(isDarkMode: !state.isDarkMode);
    emit(newState);
    await _saveSettings(newState);
  }
  
  Future<void> _onToggleNotifications(
    ToggleNotifications event,
    Emitter<SettingsState> emit,
  ) async {
    final newState = state.copyWith(
      notificationsEnabled: !state.notificationsEnabled,
    );
    emit(newState);
    await _saveSettings(newState);
  }
  
  Future<void> _onUpdateDefaultCategory(
    UpdateDefaultCategory event,
    Emitter<SettingsState> emit,
  ) async {
    final newState = state.copyWith(defaultCategory: event.category);
    emit(newState);
    await _saveSettings(newState);
  }
  
  Future<void> _onToggleShowCompletedTasks(
    ToggleShowCompletedTasks event,
    Emitter<SettingsState> emit,
  ) async {
    final newState = state.copyWith(
      showCompletedTasks: !state.showCompletedTasks,
    );
    emit(newState);
    await _saveSettings(newState);
  }
  
  Future<void> _saveSettings(SettingsState state) async {
    await updateSettings(state.toEntity());
  }
}
