import 'package:equatable/equatable.dart';
import 'stats_event.dart';

class StatsState extends Equatable {
  final StatsPeriod period;
  final int totalDuration; // 秒
  final int consecutiveDays;
  final int monthDuration; // 秒
  final int averageDailyDuration; // 秒
  final int totalVideoCount;
  final int averageVideoDuration; // 秒
  final Map<String, int> durationByDay;
  final Map<String, int> practiceDays; // 日期 -> 练习次数
  final bool isLoading;
  final String? error;

  const StatsState({
    this.period = StatsPeriod.week,
    this.totalDuration = 0,
    this.consecutiveDays = 0,
    this.monthDuration = 0,
    this.averageDailyDuration = 0,
    this.totalVideoCount = 0,
    this.averageVideoDuration = 0,
    this.durationByDay = const {},
    this.practiceDays = const {},
    this.isLoading = false,
    this.error,
  });

  StatsState copyWith({
    StatsPeriod? period,
    int? totalDuration,
    int? consecutiveDays,
    int? monthDuration,
    int? averageDailyDuration,
    int? totalVideoCount,
    int? averageVideoDuration,
    Map<String, int>? durationByDay,
    Map<String, int>? practiceDays,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) {
    return StatsState(
      period: period ?? this.period,
      totalDuration: totalDuration ?? this.totalDuration,
      consecutiveDays: consecutiveDays ?? this.consecutiveDays,
      monthDuration: monthDuration ?? this.monthDuration,
      averageDailyDuration: averageDailyDuration ?? this.averageDailyDuration,
      totalVideoCount: totalVideoCount ?? this.totalVideoCount,
      averageVideoDuration: averageVideoDuration ?? this.averageVideoDuration,
      durationByDay: durationByDay ?? this.durationByDay,
      practiceDays: practiceDays ?? this.practiceDays,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }

  @override
  List<Object?> get props => [
        period,
        totalDuration,
        consecutiveDays,
        monthDuration,
        averageDailyDuration,
        totalVideoCount,
        averageVideoDuration,
        durationByDay,
        practiceDays,
        isLoading,
        error,
      ];
}
