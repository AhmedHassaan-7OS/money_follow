import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:money_follow/control/sqlcontrol.dart';
import 'statistics_state.dart';

/// Statistics Cubit (converted from StatisticsBloc).
class StatisticsCubit extends Cubit<StatisticsState> {
  final SqlControl _sql;

  StatisticsCubit({SqlControl? sql})
      : _sql = sql ?? SqlControl(),
        super(StatisticsInitial());

  Future<void> loadStatistics() async {
    emit(StatisticsLoading());
    try {
      final now = DateTime.now();
      final today = DateFormat('yyyy-MM-dd').format(now);
      final weekStart = DateFormat('yyyy-MM-dd')
          .format(now.subtract(Duration(days: now.weekday - 1)));
      final monthStart = DateFormat('yyyy-MM-dd')
          .format(DateTime(now.year, now.month, 1));

      final spentToday = await _sql.getTotalAmountForDateRange(
          'expenses', today, today);
      final spentWeek = await _sql.getTotalAmountForDateRange(
          'expenses', weekStart, today);
      final spentMonth = await _sql.getTotalAmountForDateRange(
          'expenses', monthStart, today);
      final summaries = await _sql.getDailySummaries();

      emit(StatisticsLoaded(
        totalSpentToday: spentToday,
        totalSpentThisWeek: spentWeek,
        totalSpentThisMonth: spentMonth,
        dailySummaries: summaries,
      ));
    } catch (e) {
      emit(StatisticsError('Failed to load statistics: $e'));
    }
  }
}
