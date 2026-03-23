import 'package:equatable/equatable.dart';

enum StatsPeriod { week, month, year }

abstract class StatsEvent extends Equatable {
  const StatsEvent();

  @override
  List<Object?> get props => [];
}

class StatsLoaded extends StatsEvent {
  const StatsLoaded();
}

class StatsPeriodChanged extends StatsEvent {
  final StatsPeriod period;

  const StatsPeriodChanged(this.period);

  @override
  List<Object?> get props => [period];
}

class StatsRefreshed extends StatsEvent {
  const StatsRefreshed();
}
