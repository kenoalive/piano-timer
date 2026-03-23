import 'package:equatable/equatable.dart';
import '../models/models.dart';
import 'timer_event.dart';

class TimerState extends Equatable {
  final TimerStatus status;
  final int duration; // 秒
  final int todayTotalDuration; // 秒
  final String notes;
  final List<Video> videos;
  final PracticeRecord? currentRecord;
  final String? error;

  const TimerState({
    this.status = TimerStatus.idle,
    this.duration = 0,
    this.todayTotalDuration = 0,
    this.notes = '',
    this.videos = const [],
    this.currentRecord,
    this.error,
  });

  bool get isRunning => status == TimerStatus.running;
  bool get isPaused => status == TimerStatus.paused;
  bool get isIdle => status == TimerStatus.idle;

  TimerState copyWith({
    TimerStatus? status,
    int? duration,
    int? todayTotalDuration,
    String? notes,
    List<Video>? videos,
    PracticeRecord? currentRecord,
    String? error,
    bool clearError = false,
    bool clearRecord = false,
  }) {
    return TimerState(
      status: status ?? this.status,
      duration: duration ?? this.duration,
      todayTotalDuration: todayTotalDuration ?? this.todayTotalDuration,
      notes: notes ?? this.notes,
      videos: videos ?? this.videos,
      currentRecord: clearRecord ? null : (currentRecord ?? this.currentRecord),
      error: clearError ? null : (error ?? this.error),
    );
  }

  @override
  List<Object?> get props => [
        status,
        duration,
        todayTotalDuration,
        notes,
        videos,
        currentRecord,
        error,
      ];
}
