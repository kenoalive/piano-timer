import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class AppState extends Equatable {
  final ThemeMode themeMode;
  final bool isOnline;
  final int dailyGoalMinutes;
  final bool autoSync;
  final DateTime? lastSyncTime;
  final bool isSyncing;
  final bool isInitialized;

  const AppState({
    this.themeMode = ThemeMode.system,
    this.isOnline = true,
    this.dailyGoalMinutes = 45,
    this.autoSync = true,
    this.lastSyncTime,
    this.isSyncing = false,
    this.isInitialized = false,
  });

  AppState copyWith({
    ThemeMode? themeMode,
    bool? isOnline,
    int? dailyGoalMinutes,
    bool? autoSync,
    DateTime? lastSyncTime,
    bool? isSyncing,
    bool? isInitialized,
  }) {
    return AppState(
      themeMode: themeMode ?? this.themeMode,
      isOnline: isOnline ?? this.isOnline,
      dailyGoalMinutes: dailyGoalMinutes ?? this.dailyGoalMinutes,
      autoSync: autoSync ?? this.autoSync,
      lastSyncTime: lastSyncTime ?? this.lastSyncTime,
      isSyncing: isSyncing ?? this.isSyncing,
      isInitialized: isInitialized ?? this.isInitialized,
    );
  }

  @override
  List<Object?> get props => [
        themeMode,
        isOnline,
        dailyGoalMinutes,
        autoSync,
        lastSyncTime,
        isSyncing,
        isInitialized,
      ];
}
