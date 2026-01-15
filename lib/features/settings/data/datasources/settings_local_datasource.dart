import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/settings_entity.dart';

abstract class SettingsLocalDataSource {
  Future<SettingsEntity> getSettings();
  Future<SettingsEntity> saveSettings(SettingsEntity settings);
}

class SettingsLocalDataSourceImpl implements SettingsLocalDataSource {
  final SharedPreferences sharedPreferences;
  
  static const String _keyIsDarkMode = 'is_dark_mode';
  static const String _keyNotificationsEnabled = 'notifications_enabled';
  static const String _keyDefaultCategory = 'default_category';
  static const String _keyShowCompletedTasks = 'show_completed_tasks';
  
  SettingsLocalDataSourceImpl({required this.sharedPreferences});
  
  @override
  Future<SettingsEntity> getSettings() async {
    return SettingsEntity(
      isDarkMode: sharedPreferences.getBool(_keyIsDarkMode) ?? false,
      notificationsEnabled: sharedPreferences.getBool(_keyNotificationsEnabled) ?? true,
      defaultCategory: sharedPreferences.getString(_keyDefaultCategory) ?? 'personal',
      showCompletedTasks: sharedPreferences.getBool(_keyShowCompletedTasks) ?? true,
    );
  }
  
  @override
  Future<SettingsEntity> saveSettings(SettingsEntity settings) async {
    await sharedPreferences.setBool(_keyIsDarkMode, settings.isDarkMode);
    await sharedPreferences.setBool(_keyNotificationsEnabled, settings.notificationsEnabled);
    await sharedPreferences.setString(_keyDefaultCategory, settings.defaultCategory);
    await sharedPreferences.setBool(_keyShowCompletedTasks, settings.showCompletedTasks);
    return settings;
  }
}
