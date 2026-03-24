import 'package:money_follow/models/expense_model.dart';

/// States for Expense Cubit.
abstract class ExpenseState {}

class ExpenseInitial extends ExpenseState {}

class ExpenseLoading extends ExpenseState {}

class ExpenseLoaded extends ExpenseState {
  final List<ExpenseModel> expenses;
  final String selectedCategory;
  final DateTime selectedDate;
  final bool isCustomCategory;

  ExpenseLoaded({
    required this.expenses,
    this.selectedCategory = 'Food',
    DateTime? selectedDate,
    this.isCustomCategory = false,
  }) : selectedDate = selectedDate ?? DateTime.now();

  ExpenseLoaded copyWith({
    List<ExpenseModel>? expenses,
    String? selectedCategory,
    DateTime? selectedDate,
    bool? isCustomCategory,
  }) {
    return ExpenseLoaded(
      expenses: expenses ?? this.expenses,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      selectedDate: selectedDate ?? this.selectedDate,
      isCustomCategory: isCustomCategory ?? this.isCustomCategory,
    );
  }
}

class ExpenseError extends ExpenseState {
  final String message;
  ExpenseError(this.message);
}

class ExpenseSaving extends ExpenseState {}

class ExpenseSaved extends ExpenseState {
  final String message;
  ExpenseSaved(this.message);
}

class ExpenseDeleting extends ExpenseState {}

class ExpenseDeleted extends ExpenseState {
  final String message;
  ExpenseDeleted(this.message);
}
