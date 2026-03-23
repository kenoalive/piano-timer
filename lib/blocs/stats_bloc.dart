import 'package:flutter_bloc/flutter_bloc.dart';
import '../services/services.dart';
import 'stats_event.dart';
import 'stats_state.dart';

class StatsBloc extends Bloc<StatsEvent, StatsState> {
  final DatabaseService _db;

  StatsBloc({required DatabaseService databaseService})
      : _db = databaseService,
        super(const StatsState()) {
    on<StatsLoaded>(_onLoaded);
    on<StatsPeriodChanged>(_onPeriodChanged);
    on<StatsRefreshed>(_onRefreshed);
  }

  Future<void> _onLoaded(StatsLoaded event, Emitter<StatsState> emit) async {
    emit(state.copyWith(isLoading: true));
    await _loadStats(emit);
  }

  Future<void> _onPeriodChanged(
      StatsPeriodChanged event, Emitter<StatsState> emit) async {
    emit(state.copyWith(period: event.period, isLoading: true));
    await _loadStats(emit);
  }

  Future<void> _onRefreshed(StatsRefreshed event, Emitter<StatsState> emit) async {
    emit(state.copyWith(isLoading: true));
    await _loadStats(emit);
  }

  Future<void> _loadStats(Emitter<StatsState> emit) async {
    try {
      final now = DateTime.now();
      DateTime start;

      switch (state.period) {
        case StatsPeriod.week:
          start = now.subtract(Duration(days: now.weekday - 1));
          break;
        case StatsPeriod.month:
          start = DateTime(now.year, now.month, 1);
          break;
        case StatsPeriod.year:
          start = DateTime(now.year, 1, 1);
          break;
      }

      final end = now.add(const Duration(days: 1));

      // 获取累计时长
      final totalDuration = await _db.getTotalDuration();

      // 获取连续天数
      final consecutiveDays = await _db.getConsecutiveDays();

      // 获取本月累计
      final monthStart = DateTime(now.year, now.month, 1);
      final monthEnd = DateTime(now.year, now.month + 1, 1);
      final monthDurationResult = await _db.getDurationByDay(monthStart, monthEnd);
      final monthDuration = monthDurationResult.values.fold(0, (a, b) => a + b);

      // 获取周期内每日时长
      final durationByDay = await _db.getDurationByDay(start, end);

      // 计算平均每日
      final averageDaily = durationByDay.isNotEmpty
          ? durationByDay.values.fold(0, (a, b) => a + b) ~/
              durationByDay.length
          : 0;

      // 视频统计
      final totalVideoCount = await _db.getTotalVideoCount();
      final allVideos = await _db.getAllVideos();
      final avgVideoDuration = allVideos.isNotEmpty
          ? allVideos.map((v) => v.duration).reduce((a, b) => a + b) ~/
              allVideos.length
          : 0;

      // 练琴日历数据
      final calendarStart = DateTime(now.year, now.month - 2, 1);
      final calendarEnd = DateTime(now.year, now.month + 1, 1);
      final practiceDays = await _db.getDurationByDay(calendarStart, calendarEnd);

      emit(state.copyWith(
        totalDuration: totalDuration,
        consecutiveDays: consecutiveDays,
        monthDuration: monthDuration,
        averageDailyDuration: averageDaily,
        totalVideoCount: totalVideoCount,
        averageVideoDuration: avgVideoDuration,
        durationByDay: durationByDay,
        practiceDays: practiceDays,
        isLoading: false,
        clearError: true,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        error: e.toString(),
      ));
    }
  }
}
