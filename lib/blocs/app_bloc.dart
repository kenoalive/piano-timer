import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../services/services.dart';
import 'app_event.dart';
import 'app_state.dart';

class AppBloc extends Bloc<AppEvent, AppState> {
  final SettingsService _settings;
  final NetworkService _network;
  final CloudService _cloud;
  StreamSubscription<bool>? _networkSubscription;

  AppBloc({
    required SettingsService settingsService,
    required NetworkService networkService,
    required CloudService cloudService,
  })  : _settings = settingsService,
        _network = networkService,
        _cloud = cloudService,
        super(const AppState()) {
    on<AppInitialized>(_onInitialized);
    on<ThemeModeChanged>(_onThemeModeChanged);
    on<NetworkStatusChanged>(_onNetworkStatusChanged);
    on<DailyGoalChanged>(_onDailyGoalChanged);
    on<SyncTriggered>(_onSyncTriggered);

    // 监听网络状态变化
    _networkSubscription = _network.onNetworkChange.listen((isOnline) {
      add(NetworkStatusChanged(isOnline));
    });
  }

  Future<void> _onInitialized(AppInitialized event, Emitter<AppState> emit) async {
    final settings = await _settings.getSettings();
    final isOnline = await _network.checkConnection();

    emit(state.copyWith(
      themeMode: settings.themeMode,
      isOnline: isOnline,
      dailyGoalMinutes: settings.dailyGoalMinutes,
      autoSync: settings.autoSync,
      lastSyncTime: settings.lastSyncTime,
      isInitialized: true,
    ));

    // 初始化云端服务
    await _cloud.initialize();

    // 自动同步
    if (settings.autoSync && isOnline) {
      add(const SyncTriggered());
    }
  }

  Future<void> _onThemeModeChanged(ThemeModeChanged event, Emitter<AppState> emit) async {
    await _settings.updateThemeMode(event.themeMode.index);
    emit(state.copyWith(themeMode: event.themeMode));
  }

  void _onNetworkStatusChanged(NetworkStatusChanged event, Emitter<AppState> emit) {
    emit(state.copyWith(isOnline: event.isOnline));

    // 网络恢复时自动同步
    if (event.isOnline && state.autoSync) {
      add(const SyncTriggered());
    }
  }

  Future<void> _onDailyGoalChanged(DailyGoalChanged event, Emitter<AppState> emit) async {
    await _settings.updateDailyGoal(event.minutes);
    emit(state.copyWith(dailyGoalMinutes: event.minutes));
  }

  Future<void> _onSyncTriggered(SyncTriggered event, Emitter<AppState> emit) async {
    if (state.isSyncing) return;

    emit(state.copyWith(isSyncing: true));
    await _cloud.syncToCloud();
    final settings = await _settings.getSettings();
    emit(state.copyWith(
      isSyncing: false,
      lastSyncTime: settings.lastSyncTime,
    ));
  }

  @override
  Future<void> close() {
    _networkSubscription?.cancel();
    return super.close();
  }
}
