import 'package:money_follow/models/expense_model.dart';
import 'package:money_follow/models/commitment_model.dart';

class HomeState {
  final double totalBalance;
  final double monthlyExpenses;
  final List<ExpenseModel> expenses;
  final List<CommitmentModel> commitments;
  final bool isLoading;

  const HomeState({
    this.totalBalance = 0.0,
    this.monthlyExpenses = 0.0,
    this.expenses = const [],
    this.commitments = const [],
    this.isLoading = true,
  });

  HomeState copyWith({
    double? totalBalance,
    double? monthlyExpenses,
    List<ExpenseModel>? expenses,
    List<CommitmentModel>? commitments,
    bool? isLoading,
  }) {
    return HomeState(
      totalBalance: totalBalance ?? this.totalBalance,
      monthlyExpenses: monthlyExpenses ?? this.monthlyExpenses,
      expenses: expenses ?? this.expenses,
      commitments: commitments ?? this.commitments,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}
