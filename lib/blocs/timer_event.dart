import 'package:equatable/equatable.dart';
import '../models/models.dart';

enum TimerStatus { idle, running, paused }

abstract class TimerEvent extends Equatable {
  const TimerEvent();

  @override
  List<Object?> get props => [];
}

class TimerStarted extends TimerEvent {
  const TimerStarted();
}

class TimerPaused extends TimerEvent {
  const TimerPaused();
}

class TimerResumed extends TimerEvent {
  const TimerResumed();
}

class TimerTicked extends TimerEvent {
  final int duration;

  const TimerTicked(this.duration);

  @override
  List<Object?> get props => [duration];
}

class TimerCompleted extends TimerEvent {
  final String? notes;
  final List<Video> videos;

  const TimerCompleted({this.notes, this.videos = const []});

  @override
  List<Object?> get props => [notes, videos];
}

class TimerReset extends TimerEvent {
  const TimerReset();
}

class TimerNotesUpdated extends TimerEvent {
  final String notes;

  const TimerNotesUpdated(this.notes);

  @override
  List<Object?> get props => [notes];
}

class TimerLoaded extends TimerEvent {
  final PracticeRecord? runningRecord;

  const TimerLoaded({this.runningRecord});

  @override
  List<Object?> get props => [runningRecord];
}

/// APP 从后台恢复时重新计算时间
class TimerAppResumed extends TimerEvent {
  const TimerAppResumed();
}

/// 练琴完成，请求刷新数据
class TimerDataRefreshRequested extends TimerEvent {
  const TimerDataRefreshRequested();
}
