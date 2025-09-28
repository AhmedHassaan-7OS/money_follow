import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:money_follow/bloc/expense/expense_event.dart';
import 'package:money_follow/bloc/expense/expense_state.dart';
import 'package:money_follow/control/sqlcontrol.dart';
import 'package:money_follow/model/expense_model.dart';
import 'package:money_follow/services/ai_suggestion_service.dart';

/// BLoC for managing expense-related business logic
/// This separates all business logic from the UI components
class ExpenseBloc extends Bloc<ExpenseEvent, ExpenseState> {
  final SqlControl _sqlControl = SqlControl();

  /// Available expense categories
  static const List<String> categories = [
    'Food',
    'Transport',
    'Shopping',
    'Entertainment',
    'Bills',
    'Healthcare',
    'Education',
    'Other',
  ];

  ExpenseBloc() : super(ExpenseInitial()) {
    // Register event handlers
    on<LoadExpenses>(_onLoadExpenses);
    on<AddExpense>(_onAddExpense);
    on<UpdateExpense>(_onUpdateExpense);
    on<DeleteExpense>(_onDeleteExpense);
    on<ChangeCategoryExpense>(_onChangeCategoryExpense);
    on<ChangeDateExpense>(_onChangeDateExpense);
  }

  /// Handle loading expenses from database
  Future<void> _onLoadExpenses(
    LoadExpenses event,
    Emitter<ExpenseState> emit,
  ) async {
    try {
      emit(ExpenseLoading());
      
      final expenseData = await _sqlControl.getData('expenses');
      final expenses = expenseData
          .map((e) => ExpenseModel.fromMap(e))
          .toList();

      // Sort by date (newest first)
      expenses.sort((a, b) => b.date.compareTo(a.date));

      emit(ExpenseLoaded(expenses: expenses));
    } catch (e) {
      emit(ExpenseError('Failed to load expenses: $e'));
    }
  }

  /// Handle adding a new expense
  Future<void> _onAddExpense(
    AddExpense event,
    Emitter<ExpenseState> emit,
  ) async {
    try {
      emit(ExpenseSaving());

      final expense = ExpenseModel(
        amount: event.amount,
        category: event.category,
        date: event.date,
        note: event.note,
      );

      await _sqlControl.insertData('expenses', expense.toMap());
      
      emit(ExpenseSaved('Expense saved successfully!'));
      
      // Reload expenses to update the list
      add(LoadExpenses());
    } catch (e) {
      emit(ExpenseError('Failed to save expense: $e'));
    }
  }

  /// Handle updating an existing expense
  Future<void> _onUpdateExpense(
    UpdateExpense event,
    Emitter<ExpenseState> emit,
  ) async {
    try {
      emit(ExpenseSaving());

      final expense = ExpenseModel(
        id: event.id,
        amount: event.amount,
        category: event.category,
        date: event.date,
        note: event.note,
      );

      await _sqlControl.updateData('expenses', expense.toMap(), event.id);
      
      emit(ExpenseSaved('Expense updated successfully!'));
      
      // Reload expenses to update the list
      add(LoadExpenses());
    } catch (e) {
      emit(ExpenseError('Failed to update expense: $e'));
    }
  }

  /// Handle deleting an expense
  Future<void> _onDeleteExpense(
    DeleteExpense event,
    Emitter<ExpenseState> emit,
  ) async {
    try {
      emit(ExpenseDeleting());

      await _sqlControl.deleteData('expenses', event.id);
      
      emit(ExpenseDeleted('Expense deleted successfully!'));
      
      // Reload expenses to update the list
      add(LoadExpenses());
    } catch (e) {
      emit(ExpenseError('Failed to delete expense: $e'));
    }
  }

  /// Handle category change
  Future<void> _onChangeCategoryExpense(
    ChangeCategoryExpense event,
    Emitter<ExpenseState> emit,
  ) async {
    if (state is ExpenseLoaded) {
      final currentState = state as ExpenseLoaded;
      emit(currentState.copyWith(
        selectedCategory: event.category,
        isCustomCategory: event.category == 'Other',
      ));
    }
  }

  /// Handle date change
  Future<void> _onChangeDateExpense(
    ChangeDateExpense event,
    Emitter<ExpenseState> emit,
  ) async {
    if (state is ExpenseLoaded) {
      final currentState = state as ExpenseLoaded;
      emit(currentState.copyWith(selectedDate: event.date));
    }
  }

  /// Get formatted date string
  String getFormattedDate(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  /// Validate expense data
  String? validateAmount(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter an amount';
    }
    if (double.tryParse(value) == null) {
      return 'Please enter a valid number';
    }
    if (double.parse(value) <= 0) {
      return 'Amount must be greater than 0';
    }
    return null;
  }

  /// Get AI suggestion for category based on description
  String suggestCategoryFromDescription(String description) {
    return AISuggestionService.suggestCategory(description);
  }

  /// Get financial tips based on current expenses
  List<String> getFinancialTips(double monthlyIncome) {
    if (state is ExpenseLoaded) {
      final expenses = (state as ExpenseLoaded).expenses;
      
      // Calculate category spending for current month
      final now = DateTime.now();
      final currentMonth = DateFormat('yyyy-MM').format(now);
      
      Map<String, double> categorySpending = {};
      
      for (var expense in expenses) {
        if (expense.date.startsWith(currentMonth)) {
          categorySpending[expense.category] = 
              (categorySpending[expense.category] ?? 0) + expense.amount;
        }
      }
      
      return AISuggestionService.getFinancialTips(categorySpending, monthlyIncome);
    }
    
    return ['Start tracking expenses to get personalized tips!'];
  }

  /// Get spending insights
  Map<String, String> getSpendingInsights() {
    if (state is ExpenseLoaded) {
      final expenses = (state as ExpenseLoaded).expenses;
      
      // Calculate category spending for current month
      final now = DateTime.now();
      final currentMonth = DateFormat('yyyy-MM').format(now);
      
      Map<String, double> categorySpending = {};
      
      for (var expense in expenses) {
        if (expense.date.startsWith(currentMonth)) {
          categorySpending[expense.category] = 
              (categorySpending[expense.category] ?? 0) + expense.amount;
        }
      }
      
      return AISuggestionService.getSpendingInsights(categorySpending);
    }
    
    return {'general': 'No expenses tracked yet'};
  }
}
