import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:money_follow/core/constants/app_constants.dart';
import 'package:money_follow/models/expense_model.dart';
import 'package:money_follow/repository/expense_repository.dart';
import 'package:money_follow/services/ai_suggestion_service.dart';
import 'package:money_follow/utils/validators.dart';
import 'expense_state.dart';

/// Handles expense CRUD, category/date selection.
class ExpenseCubit extends Cubit<ExpenseState> {
  final ExpenseRepository _repo;

  ExpenseCubit({ExpenseRepository? repository})
      : _repo = repository ?? ExpenseRepository(),
        super(ExpenseInitial());

  Future<void> loadExpenses() async {
    try {
      emit(ExpenseLoading());
      final list = await _repo.getAllSorted();
      emit(ExpenseLoaded(expenses: list));
    } catch (e) {
      emit(ExpenseError('Failed to load expenses: $e'));
    }
  }

  Future<void> addExpense({
    required double amount,
    required String category,
    required String date,
    String? note,
  }) async {
    try {
      emit(ExpenseSaving());
      final expense = ExpenseModel(
        amount: amount,
        category: category,
        date: date,
        note: note,
      );
      await _repo.insert(expense);
      emit(ExpenseSaved('Expense saved successfully!'));
      loadExpenses();
    } catch (e) {
      emit(ExpenseError('Failed to save expense: $e'));
    }
  }

  Future<void> updateExpense({
    required int id,
    required double amount,
    required String category,
    required String date,
    String? note,
  }) async {
    try {
      emit(ExpenseSaving());
      final expense = ExpenseModel(
        id: id, amount: amount, category: category,
        date: date, note: note,
      );
      await _repo.update(expense, id);
      emit(ExpenseSaved('Expense updated successfully!'));
      loadExpenses();
    } catch (e) {
      emit(ExpenseError('Failed to update: $e'));
    }
  }

  Future<void> deleteExpense(int id) async {
    try {
      emit(ExpenseDeleting());
      await _repo.delete(id);
      emit(ExpenseDeleted('Expense deleted successfully!'));
      loadExpenses();
    } catch (e) {
      emit(ExpenseError('Failed to delete: $e'));
    }
  }

  void changeCategory(String category) {
    if (state is ExpenseLoaded) {
      emit((state as ExpenseLoaded).copyWith(
        selectedCategory: category,
        isCustomCategory: category == 'Other',
      ));
    }
  }

  void changeDate(DateTime date) {
    if (state is ExpenseLoaded) {
      emit((state as ExpenseLoaded).copyWith(selectedDate: date));
    }
  }

  String getFormattedDate(DateTime date) =>
      DateFormat(AppConstants.dbDateFormat).format(date);

  String? validateAmount(String? value) => AppValidators.amount(value);

  String suggestCategory(String desc) =>
      AISuggestionService.suggestCategory(desc);

  List<String> getFinancialTips(double income) {
    if (state is! ExpenseLoaded) {
      return ['Start tracking expenses to get tips!'];
    }
    final expenses = (state as ExpenseLoaded).expenses;
    final month = DateFormat('yyyy-MM').format(DateTime.now());
    final spending = <String, double>{};
    for (final e in expenses) {
      if (e.date.startsWith(month)) {
        spending[e.category] = (spending[e.category] ?? 0) + e.amount;
      }
    }
    return AISuggestionService.getFinancialTips(spending, income);
  }

  Map<String, String> getSpendingInsights() {
    if (state is! ExpenseLoaded) return {'general': 'No data'};
    final expenses = (state as ExpenseLoaded).expenses;
    final month = DateFormat('yyyy-MM').format(DateTime.now());
    final spending = <String, double>{};
    for (final e in expenses) {
      if (e.date.startsWith(month)) {
        spending[e.category] = (spending[e.category] ?? 0) + e.amount;
      }
    }
    return AISuggestionService.getSpendingInsights(spending);
  }
}
