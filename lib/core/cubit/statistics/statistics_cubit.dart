import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:money_follow/control/sqlcontrol.dart';
import 'package:money_follow/utils/date_ranges.dart';
import 'statistics_state.dart';

/// Statistics Cubit (converted from StatisticsBloc).
///
/// Phase B: نفس دوال date_ranges المستخدمة في HomeCubit عشان
/// "مصروفات الشهر/الأسبوع" يطابقوا بالتعريف (B4/B5 fix).
class StatisticsCubit extends Cubit<StatisticsState> {
  final SqlControl _sql;
  final DateTime Function() _now;

  StatisticsCubit({SqlControl? sql, DateTime Function()? now})
      : _sql = sql ?? SqlControl(),
        _now = now ?? DateTime.now,
        super(StatisticsInitial());

  Future<void> loadStatistics() async {
    emit(StatisticsLoading());
    try {
      final now = _now();
      final today = fmtDay(now);
      final weekStart = weekStartForSystemLocale(now);
      final monthStartStr = monthStart(now);

      final spentToday = await _sql.getTotalAmountForDateRange(
          'expenses', today, today);
      final spentWeek = await _sql.getTotalAmountForDateRange(
          'expenses', weekStart, today);
      final spentMonth = await _sql.getTotalAmountForDateRange(
          'expenses', monthStartStr, today);
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
