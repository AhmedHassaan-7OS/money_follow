import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:money_follow/control/sqlcontrol.dart';
import 'package:money_follow/models/expense_model.dart';
import 'package:money_follow/models/income_model.dart';
import 'package:money_follow/models/commitment_model.dart';
import 'package:money_follow/utils/date_ranges.dart';
import 'home_state.dart';

/// Handles data loading for the home screen.
///
/// Phase B decisions (user-approved):
///  • التواريخ المستقبلية مبتدخلش في الرصيد الحالي ولا "مصروفات الشهر".
///  • فلتر الأسبوع = أسبوع تقويمي بدايته حسب لغة الجهاز (مختلف عن آخر 7 أيام).
class HomeCubit extends Cubit<HomeState> {
  final SqlControl _sql;

  /// نقطة الزمن المستخدمة في كل حسابات "اليوم/الشهر/الأسبوع".
  /// قابلة للاستبدال في الاختبارات (injection) عشان النتائج تبقى حتمية.
  final DateTime Function() _now;

  HomeCubit({SqlControl? sql, DateTime Function()? now})
      : _sql = sql ?? SqlControl(),
        _now = now ?? DateTime.now,
        super(const HomeState());

  Future<void> loadData() async {
    emit(state.copyWith(isLoading: true));
    try {
      final balance = await _calculateBalance();
      final expenses = await _loadExpenses();
      final commitments = await _loadCommitments();
      final monthlyExp = _monthlyExpenses(expenses);

      emit(state.copyWith(
        totalBalance: balance,
        monthlyExpenses: monthlyExp,
        expenses: expenses,
        commitments: commitments,
        isLoading: false,
        clearErrorMessage: true,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load home data: $e',
      ));
    }
  }

  /// الرصيد = دخل لحد النهاردة − مصاريف لحد النهاردة (القرار: المستقبلي مستبعد).
  Future<double> _calculateBalance() async {
    final today = fmtDay(_now());
    final incomeData = await _sql.getData('incomes');
    final incomes = incomeData.map((e) => IncomeModel.fromMap(e));
    final expenseData = await _sql.getData('expenses');
    final allExp = expenseData.map((e) => ExpenseModel.fromMap(e));
    final totalIn = incomes
        .where((i) => isOnOrBefore(i.date, today))
        .fold(0.0, (s, i) => s + i.amount);
    final totalEx = allExp
        .where((e) => isOnOrBefore(e.date, today))
        .fold(0.0, (s, e) => s + e.amount);
    return totalIn - totalEx;
  }

  Future<List<ExpenseModel>> _loadExpenses() async {
    final data = await _sql.getData('expenses');
    return data.map((e) => ExpenseModel.fromMap(e)).toList();
  }

  Future<List<CommitmentModel>> _loadCommitments() async {
    final data = await _sql.getData('commitments');
    final list = data.map((e) => CommitmentModel.fromMap(e)).toList();
    list.sort((a, b) => a.dueDate.compareTo(b.dueDate));
    return list;
  }

  /// مصروفات الشهر = الشهر التقويمي لحد النهاردة فقط (B4 fix —
  /// بيطابق رقم StatisticsCubit بالتعريف مش بالصدفة).
  double _monthlyExpenses(List<ExpenseModel> expenses) {
    final now = _now();
    final monthPrefix = DateFormat('yyyy-MM').format(now);
    final today = fmtDay(now);
    return expenses
        .where((e) =>
            e.date.startsWith(monthPrefix) && isOnOrBefore(e.date, today))
        .fold(0.0, (s, e) => s + e.amount);
  }

  void setChartTimeFilter(String f) => emit(state.copyWith(chartTimeFilter: f));
  
  void setCustomDateRange(DateTime? start, DateTime? end) {
    emit(state.copyWith(chartTimeFilter: 'Custom', customStartDate: start, customEndDate: end));
  }
  
  void setFilterCategory(String? cat) {
    emit(state.copyWith(filterCategory: cat, clearFilterCategory: cat == null));
  }

  void setChartType(String type) => emit(state.copyWith(chartType: type));
  
  void toggleChartType() {
    emit(state.copyWith(chartType: state.chartType == 'Pie' ? 'Bar' : 'Pie'));
  }

  Map<String, double> getExpensesByCategory() {
    final map = <String, double>{};
    final now = _now();
    final today = fmtDay(now);
    for (final e in state.expenses) {
      final edate = DateTime.tryParse(e.date);
      if (edate == null) continue;
      
      bool include = false;
      if (state.chartTimeFilter == 'Week') {
        // B5 fix: أسبوع تقويمي حسب لغة الجهاز مع استبعاد التواريخ المستقبلية داخل نفس الأسبوع
        include = !edate.isBefore(DateTime.parse('${weekStartForSystemLocale(now)}T00:00')) &&
            edate.isBefore(DateTime.parse('${weekEndExclusiveForSystemLocale(now)}T00:00')) &&
            isOnOrBefore(e.date, today);
      } else if (state.chartTimeFilter == 'Month') {
        // B4 fix: الشهر لكن من غير التواريخ المستقبلية
        include = edate.year == now.year &&
            edate.month == now.month &&
            isOnOrBefore(e.date, today);
      } else if (state.chartTimeFilter == 'Year') {
        // B4 fix: السنة لكن من غير المستقبلي
        include = edate.year == now.year && isOnOrBefore(e.date, today);
      } else if (state.chartTimeFilter == 'Custom') {
        if (state.customStartDate != null && state.customEndDate != null) {
          include = edate.isAfter(state.customStartDate!.subtract(const Duration(days: 1))) && 
                    edate.isBefore(state.customEndDate!.add(const Duration(days: 1)));
        } else {
          include = true;
        }
      } else {
        include = true; // AllTime
      }

      if (state.filterCategory != null && state.filterCategory != 'All' && e.category != state.filterCategory) {
        include = false;
      }
      
      if (include) {
        map[e.category] = (map[e.category] ?? 0) + e.amount;
      }
    }
    return map;
  }
}
