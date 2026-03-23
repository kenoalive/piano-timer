import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../models/models.dart';
import '../services/services.dart';
import 'timer_event.dart';
import 'timer_state.dart';

class TimerBloc extends Bloc<TimerEvent, TimerState> {
  final DatabaseService _db;
  final _uuid = const Uuid();
  Timer? _timer;
  int _elapsedSeconds = 0;

  TimerBloc({
    required DatabaseService databaseService,
    required SettingsService settingsService,
  })  : _db = databaseService,
        super(const TimerState()) {
    on<TimerLoaded>(_onLoaded);
    on<TimerStarted>(_onStarted);
    on<TimerPaused>(_onPaused);
    on<TimerResumed>(_onResumed);
    on<TimerTicked>(_onTicked);
    on<TimerCompleted>(_onCompleted);
    on<TimerReset>(_onReset);
    on<TimerNotesUpdated>(_onNotesUpdated);
    on<TimerAppResumed>(_onAppResumed);
    on<TimerDataRefreshRequested>(_onDataRefreshRequested);
  }

  Future<void> _onLoaded(TimerLoaded event, Emitter<TimerState> emit) async {
    final todayTotal = await _db.getTodayTotalDuration();

    if (event.runningRecord != null) {
      final elapsed = DateTime.now().difference(event.runningRecord!.startTime).inSeconds;
      _elapsedSeconds = elapsed;

      emit(state.copyWith(
        status: TimerStatus.running,
        duration: elapsed,
        todayTotalDuration: todayTotal,
        currentRecord: event.runningRecord,
        notes: event.runningRecord!.notes ?? '',
        videos: event.runningRecord!.videos,
      ));

      _startTicker();
    } else {
      emit(state.copyWith(
        status: TimerStatus.idle,
        duration: 0,
        todayTotalDuration: todayTotal,
        clearRecord: true,
      ));
    }
  }

  void _onStarted(TimerStarted event, Emitter<TimerState> emit) async {
    final now = DateTime.now();
    final record = PracticeRecord(
      id: _uuid.v4(),
      startTime: now,
      duration: 0,
      createdAt: now,
      updatedAt: now,
    );

    await _db.insertRecord(record);

    _elapsedSeconds = 0;
    emit(state.copyWith(
      status: TimerStatus.running,
      duration: 0,
      currentRecord: record,
      notes: '',
      videos: [],
      clearError: true,
    ));

    _startTicker();
  }

  void _onPaused(TimerPaused event, Emitter<TimerState> emit) {
    _timer?.cancel();
    emit(state.copyWith(status: TimerStatus.paused));
  }

  void _onResumed(TimerResumed event, Emitter<TimerState> emit) {
    emit(state.copyWith(status: TimerStatus.running));
    _startTicker();
  }

  void _onTicked(TimerTicked event, Emitter<TimerState> emit) {
    _elapsedSeconds = event.duration;

    // 每30秒保存一次进度
    if (event.duration % 30 == 0 && state.currentRecord != null) {
      _saveProgress(event.duration);
    }

    emit(state.copyWith(duration: event.duration));
  }

  Future<void> _saveProgress(int duration) async {
    if (state.currentRecord != null) {
      final updated = state.currentRecord!.copyWith(
        duration: duration,
        updatedAt: DateTime.now(),
      );
      await _db.updateRecord(updated);
    }
  }

  Future<void> _onCompleted(TimerCompleted event, Emitter<TimerState> emit) async {
    _timer?.cancel();

    if (state.currentRecord != null) {
      final now = DateTime.now();
      final notesValue = (event.notes?.isNotEmpty ?? false)
          ? event.notes
          : (state.notes.isNotEmpty ? state.notes : null);
      final record = state.currentRecord!.copyWith(
        endTime: now,
        duration: _elapsedSeconds,
        notes: notesValue,
        videos: event.videos,
        updatedAt: now,
      );

      // 保存视频
      for (final video in event.videos) {
        await _db.insertVideo(record.id, video);
      }

      await _db.updateRecord(record);

      final todayTotal = await _db.getTodayTotalDuration();

      emit(state.copyWith(
        status: TimerStatus.idle,
        duration: 0,
        todayTotalDuration: todayTotal,
        notes: '',
        videos: [],
        clearRecord: true,
        clearError: true,
      ));
    }
  }

  void _onReset(TimerReset event, Emitter<TimerState> emit) {
    _timer?.cancel();
    _elapsedSeconds = 0;

    emit(state.copyWith(
      status: TimerStatus.idle,
      duration: 0,
      notes: '',
      videos: [],
      clearRecord: true,
    ));
  }

  void _onNotesUpdated(TimerNotesUpdated event, Emitter<TimerState> emit) {
    emit(state.copyWith(notes: event.notes));
  }

  /// APP 从后台恢复时，重新计算时间
  void _onAppResumed(TimerAppResumed event, Emitter<TimerState> emit) {
    if (state.currentRecord != null && (state.isRunning || state.isPaused)) {
      // 重新计算从开始到现在经过的秒数
      final elapsed = DateTime.now().difference(state.currentRecord!.startTime).inSeconds;
      _elapsedSeconds = elapsed;

      // 同时更新数据库中的记录
      _saveProgress(elapsed);

      emit(state.copyWith(duration: elapsed));

      // 如果之前是运行状态，确保计时器在运行
      if (state.isRunning) {
        _startTicker();
      }
    }
  }

  /// 刷新数据（首页、记录页、统计页）
  Future<void> _onDataRefreshRequested(TimerDataRefreshRequested event, Emitter<TimerState> emit) async {
    final todayTotal = await _db.getTodayTotalDuration();
    emit(state.copyWith(todayTotalDuration: todayTotal));
  }

  void _startTicker() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      add(TimerTicked(_elapsedSeconds + 1));
    });
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}
