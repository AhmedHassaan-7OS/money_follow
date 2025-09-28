/// Events for Expense BLoC
/// These represent all possible actions that can happen with expenses
abstract class ExpenseEvent {}

/// Event to load all expenses from database
class LoadExpenses extends ExpenseEvent {}

/// Event to add a new expense
class AddExpense extends ExpenseEvent {
  final double amount;
  final String category;
  final String date;
  final String? note;

  AddExpense({
    required this.amount,
    required this.category,
    required this.date,
    this.note,
  });
}

/// Event to update an existing expense
class UpdateExpense extends ExpenseEvent {
  final int id;
  final double amount;
  final String category;
  final String date;
  final String? note;

  UpdateExpense({
    required this.id,
    required this.amount,
    required this.category,
    required this.date,
    this.note,
  });
}

/// Event to delete an expense
class DeleteExpense extends ExpenseEvent {
  final int id;

  DeleteExpense(this.id);
}

/// Event to change the selected category
class ChangeCategoryExpense extends ExpenseEvent {
  final String category;

  ChangeCategoryExpense(this.category);
}

/// Event to change the selected date
class ChangeDateExpense extends ExpenseEvent {
  final DateTime date;

  ChangeDateExpense(this.date);
}
