import 'package:money_follow/models/expense_model.dart';
import 'package:money_follow/models/commitment_model.dart';

class HomeState {
  final double totalBalance;
  final double monthlyExpenses;
  final List<ExpenseModel> expenses;
  final List<CommitmentModel> commitments;
  final bool isLoading;
  final String chartTimeFilter;
  final String chartType;
  final DateTime? customStartDate;
  final DateTime? customEndDate;
  final String? filterCategory;

  const HomeState({
    this.totalBalance = 0.0,
    this.monthlyExpenses = 0.0,
    this.expenses = const [],
    this.commitments = const [],
    this.isLoading = true,
    this.chartTimeFilter = 'Month',
    this.chartType = 'Pie',
    this.customStartDate,
    this.customEndDate,
    this.filterCategory,
  });

  HomeState copyWith({
    double? totalBalance,
    double? monthlyExpenses,
    List<ExpenseModel>? expenses,
    List<CommitmentModel>? commitments,
    bool? isLoading,
    String? chartTimeFilter,
    String? chartType,
    DateTime? customStartDate,
    DateTime? customEndDate,
    String? filterCategory,
  }) {
    return HomeState(
      totalBalance: totalBalance ?? this.totalBalance,
      monthlyExpenses: monthlyExpenses ?? this.monthlyExpenses,
      expenses: expenses ?? this.expenses,
      commitments: commitments ?? this.commitments,
      isLoading: isLoading ?? this.isLoading,
      chartTimeFilter: chartTimeFilter ?? this.chartTimeFilter,
      chartType: chartType ?? this.chartType,
      customStartDate: customStartDate ?? this.customStartDate,
      customEndDate: customEndDate ?? this.customEndDate,
      filterCategory: filterCategory ?? this.filterCategory,
    );
  }
}
