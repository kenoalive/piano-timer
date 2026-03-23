import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

abstract class AppEvent extends Equatable {
  const AppEvent();

  @override
  List<Object?> get props => [];
}

class AppInitialized extends AppEvent {
  const AppInitialized();
}

class ThemeModeChanged extends AppEvent {
  final ThemeMode themeMode;

  const ThemeModeChanged(this.themeMode);

  @override
  List<Object?> get props => [themeMode];
}

class NetworkStatusChanged extends AppEvent {
  final bool isOnline;

  const NetworkStatusChanged(this.isOnline);

  @override
  List<Object?> get props => [isOnline];
}

class DailyGoalChanged extends AppEvent {
  final int minutes;

  const DailyGoalChanged(this.minutes);

  @override
  List<Object?> get props => [minutes];
}

class SyncTriggered extends AppEvent {
  const SyncTriggered();
}
