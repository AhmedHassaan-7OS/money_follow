part of 'statistics_bloc.dart';

abstract class StatisticsState extends Equatable {
  const StatisticsState();

  @override
  List<Object> get props => [];
}

class StatisticsInitial extends StatisticsState {}

class StatisticsLoading extends StatisticsState {}

class StatisticsLoaded extends StatisticsState {
  final double totalSpentToday;
  final double totalSpentThisWeek;
  final double totalSpentThisMonth;
  final Map<String, Map<String, double>> dailySummaries;

  const StatisticsLoaded({
    required this.totalSpentToday,
    required this.totalSpentThisWeek,
    required this.totalSpentThisMonth,
    required this.dailySummaries,
  });

  @override
  List<Object> get props => [
        totalSpentToday,
        totalSpentThisWeek,
        totalSpentThisMonth,
        dailySummaries,
      ];
}

class StatisticsError extends StatisticsState {
  final String message;

  const StatisticsError(this.message);

  @override
  List<Object> get props => [message];
}
