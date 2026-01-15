import 'package:equatable/equatable.dart';

class SettingsEntity extends Equatable {
  final bool isDarkMode;
  final bool notificationsEnabled;
  final String defaultCategory;
  final bool showCompletedTasks;
  
  const SettingsEntity({
    this.isDarkMode = false,
    this.notificationsEnabled = true,
    this.defaultCategory = 'personal',
    this.showCompletedTasks = true,
  });
  
  SettingsEntity copyWith({
    bool? isDarkMode,
    bool? notificationsEnabled,
    String? defaultCategory,
    bool? showCompletedTasks,
  }) {
    return SettingsEntity(
      isDarkMode: isDarkMode ?? this.isDarkMode,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      defaultCategory: defaultCategory ?? this.defaultCategory,
      showCompletedTasks: showCompletedTasks ?? this.showCompletedTasks,
    );
  }
  
  @override
  List<Object?> get props => [
    isDarkMode,
    notificationsEnabled,
    defaultCategory,
    showCompletedTasks,
  ];
}
