import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class UserSettings extends Equatable {
  final int dailyGoalMinutes;
  final ThemeMode themeMode;
  final bool autoSync;
  final DateTime? lastSyncTime;
  final String cloudEnvId;

  const UserSettings({
    this.dailyGoalMinutes = 45,
    this.themeMode = ThemeMode.system,
    this.autoSync = true,
    this.lastSyncTime,
    this.cloudEnvId = '',
  });

  UserSettings copyWith({
    int? dailyGoalMinutes,
    ThemeMode? themeMode,
    bool? autoSync,
    DateTime? lastSyncTime,
    String? cloudEnvId,
  }) {
    return UserSettings(
      dailyGoalMinutes: dailyGoalMinutes ?? this.dailyGoalMinutes,
      themeMode: themeMode ?? this.themeMode,
      autoSync: autoSync ?? this.autoSync,
      lastSyncTime: lastSyncTime ?? this.lastSyncTime,
      cloudEnvId: cloudEnvId ?? this.cloudEnvId,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'dailyGoalMinutes': dailyGoalMinutes,
      'themeMode': themeMode.index,
      'autoSync': autoSync,
      'lastSyncTime': lastSyncTime?.toIso8601String(),
      'cloudEnvId': cloudEnvId,
    };
  }

  factory UserSettings.fromMap(Map<String, dynamic> map) {
    return UserSettings(
      dailyGoalMinutes: map['dailyGoalMinutes'] as int? ?? 120,
      themeMode: ThemeMode.values[map['themeMode'] as int? ?? 0],
      autoSync: map['autoSync'] as bool? ?? true,
      lastSyncTime: map['lastSyncTime'] != null
          ? DateTime.parse(map['lastSyncTime'] as String)
          : null,
      cloudEnvId: map['cloudEnvId'] as String? ?? '',
    );
  }

  @override
  List<Object?> get props => [
        dailyGoalMinutes,
        themeMode,
        autoSync,
        lastSyncTime,
        cloudEnvId,
      ];
}
