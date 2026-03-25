import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:money_follow/control/sqlcontrol.dart';
import 'package:money_follow/models/expense_model.dart';
import 'package:money_follow/models/income_model.dart';
import 'package:money_follow/models/commitment_model.dart';
import 'home_state.dart';

/// Handles data loading for the home screen.
class HomeCubit extends Cubit<HomeState> {
  final SqlControl _sql = SqlControl();

  HomeCubit() : super(const HomeState());

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
      ));
    } catch (_) {
      emit(state.copyWith(isLoading: false));
    }
  }

  Future<double> _calculateBalance() async {
    final incomeData = await _sql.getData('incomes');
    final incomes = incomeData.map((e) => IncomeModel.fromMap(e));
    final expenseData = await _sql.getData('expenses');
    final allExp = expenseData.map((e) => ExpenseModel.fromMap(e));
    final totalIn = incomes.fold(0.0, (s, i) => s + i.amount);
    final totalEx = allExp.fold(0.0, (s, e) => s + e.amount);
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

  double _monthlyExpenses(List<ExpenseModel> expenses) {
    final currentMonth = DateFormat('yyyy-MM').format(DateTime.now());
    return expenses
        .where((e) => e.date.startsWith(currentMonth))
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
    final now = DateTime.now();
    for (final e in state.expenses) {
      final edate = DateTime.tryParse(e.date);
      if (edate == null) continue;
      
      bool include = false;
      if (state.chartTimeFilter == 'Week') {
        include = edate.isAfter(now.subtract(const Duration(days: 7))) || 
                  (edate.year == now.year && edate.month == now.month && edate.day == now.day);
      } else if (state.chartTimeFilter == 'Month') {
        include = edate.year == now.year && edate.month == now.month;
      } else if (state.chartTimeFilter == 'Year') {
        include = edate.year == now.year;
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
