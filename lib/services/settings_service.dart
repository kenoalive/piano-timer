import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/models.dart';

class SettingsService {
  static const String _settingsKey = 'user_settings';

  Future<UserSettings> getSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(_settingsKey);
    if (json == null) return const UserSettings();

    try {
      final map = jsonDecode(json) as Map<String, dynamic>;
      return UserSettings.fromMap(map);
    } catch (e) {
      return const UserSettings();
    }
  }

  Future<void> saveSettings(UserSettings settings) async {
    final prefs = await SharedPreferences.getInstance();
    final json = jsonEncode(settings.toMap());
    await prefs.setString(_settingsKey, json);
  }

  Future<void> updateDailyGoal(int minutes) async {
    final settings = await getSettings();
    await saveSettings(settings.copyWith(dailyGoalMinutes: minutes));
  }

  Future<void> updateThemeMode(int mode) async {
    final settings = await getSettings();
    await saveSettings(settings.copyWith(themeMode: ThemeMode.values[mode]));
  }

  Future<void> updateAutoSync(bool enabled) async {
    final settings = await getSettings();
    await saveSettings(settings.copyWith(autoSync: enabled));
  }

  Future<void> updateLastSyncTime() async {
    final settings = await getSettings();
    await saveSettings(settings.copyWith(lastSyncTime: DateTime.now()));
  }

  Future<void> updateCloudEnvId(String envId) async {
    final settings = await getSettings();
    await saveSettings(settings.copyWith(cloudEnvId: envId));
  }
}
