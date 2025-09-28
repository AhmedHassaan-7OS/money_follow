import 'package:money_follow/model/expense_model.dart';

/// States for Expense BLoC
/// These represent all possible states the expense feature can be in
abstract class ExpenseState {}

/// Initial state when the BLoC is first created
class ExpenseInitial extends ExpenseState {}

/// State when expenses are being loaded
class ExpenseLoading extends ExpenseState {}

/// State when expenses are successfully loaded
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

  /// Create a copy of this state with some values updated
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

/// State when an error occurs
class ExpenseError extends ExpenseState {
  final String message;

  ExpenseError(this.message);
}

/// State when an expense is being saved
class ExpenseSaving extends ExpenseState {}

/// State when an expense is successfully saved
class ExpenseSaved extends ExpenseState {
  final String message;

  ExpenseSaved(this.message);
}

/// State when an expense is being deleted
class ExpenseDeleting extends ExpenseState {}

/// State when an expense is successfully deleted
class ExpenseDeleted extends ExpenseState {
  final String message;

  ExpenseDeleted(this.message);
}
