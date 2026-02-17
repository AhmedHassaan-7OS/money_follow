import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:intl/intl.dart';
import 'package:money_follow/control/sqlcontrol.dart';

part 'statistics_event.dart';
part 'statistics_state.dart';

class StatisticsBloc extends Bloc<StatisticsEvent, StatisticsState> {
  final SqlControl _sqlControl = SqlControl();

  StatisticsBloc() : super(StatisticsInitial()) {
    on<LoadStatistics>(_onLoadStatistics);
  }

  Future<void> _onLoadStatistics(
    LoadStatistics event,
    Emitter<StatisticsState> emit,
  ) async {
    try {
      emit(StatisticsLoading());

      final now = DateTime.now();
      final today = DateFormat('yyyy-MM-dd').format(now);
      final startOfWeek = DateFormat('yyyy-MM-dd')
          .format(now.subtract(Duration(days: now.weekday - 1)));
      final startOfMonth = DateFormat('yyyy-MM-dd').format(DateTime(now.year, now.month, 1));

      final totalSpentToday = await _sqlControl.getTotalAmountForDateRange(
        'expenses',
        today,
        today,
      );

      final totalSpentThisWeek = await _sqlControl.getTotalAmountForDateRange(
        'expenses',
        startOfWeek,
        today,
      );

      final totalSpentThisMonth = await _sqlControl.getTotalAmountForDateRange(
        'expenses',
        startOfMonth,
        today,
      );

      final dailySummaries = await _sqlControl.getDailySummaries();

      emit(StatisticsLoaded(
        totalSpentToday: totalSpentToday,
        totalSpentThisWeek: totalSpentThisWeek,
        totalSpentThisMonth: totalSpentThisMonth,
        dailySummaries: dailySummaries,
      ));
    } catch (e) {
      emit(StatisticsError('Failed to load statistics: $e'));
    }
  }
}
