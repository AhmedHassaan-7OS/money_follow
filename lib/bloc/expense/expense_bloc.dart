import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:money_follow/bloc/expense/expense_event.dart';
import 'package:money_follow/bloc/expense/expense_state.dart';
import 'package:money_follow/core/constants/app_constants.dart'
    show AppConstants;
import 'package:money_follow/model/expense_model.dart';
import 'package:money_follow/repository/expense_repository.dart'
    show ExpenseRepository;
import 'package:money_follow/services/ai_suggestion_service.dart';
import 'package:money_follow/utils/validators.dart';

/// ============================================================
/// ExpenseBloc — Business logic for expenses.
///
/// SOLID:
///  • SRP : يعمل فقط لوجيك المصاريف، مش DB مش UI.
///  • DIP : يستخدم ExpenseRepository (abstraction) مش SqlControl.
///  • OCP : الـ handlers مفصولة، سهل إضافة event جديد.
/// ============================================================
class ExpenseBloc extends Bloc<ExpenseEvent, ExpenseState> {
  final ExpenseRepository _repository;

  ExpenseBloc({ExpenseRepository? repository})
    : _repository = repository ?? ExpenseRepository(),
      super(ExpenseInitial()) {
    on<LoadExpenses>(_onLoadExpenses);
    on<AddExpense>(_onAddExpense);
    on<UpdateExpense>(_onUpdateExpense);
    on<DeleteExpense>(_onDeleteExpense);
    on<ChangeCategoryExpense>(_onChangeCategoryExpense);
    on<ChangeDateExpense>(_onChangeDateExpense);
  }

  // ─── Event Handlers ───────────────────────────────────────────────────────

  Future<void> _onLoadExpenses(
    LoadExpenses event,
    Emitter<ExpenseState> emit,
  ) async {
    try {
      emit(ExpenseLoading());
      final expenses = await _repository.getAllSorted();
      emit(ExpenseLoaded(expenses: expenses));
    } catch (e) {
      emit(ExpenseError('Failed to load expenses: $e'));
    }
  }

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
      await _repository.insert(expense);
      emit(ExpenseSaved('Expense saved successfully!'));
      add(LoadExpenses());
    } catch (e) {
      emit(ExpenseError('Failed to save expense: $e'));
    }
  }

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
      await _repository.update(expense, event.id);
      emit(ExpenseSaved('Expense updated successfully!'));
      add(LoadExpenses());
    } catch (e) {
      emit(ExpenseError('Failed to update expense: $e'));
    }
  }

  Future<void> _onDeleteExpense(
    DeleteExpense event,
    Emitter<ExpenseState> emit,
  ) async {
    try {
      emit(ExpenseDeleting());
      await _repository.delete(event.id);
      emit(ExpenseDeleted('Expense deleted successfully!'));
      add(LoadExpenses());
    } catch (e) {
      emit(ExpenseError('Failed to delete expense: $e'));
    }
  }

  Future<void> _onChangeCategoryExpense(
    ChangeCategoryExpense event,
    Emitter<ExpenseState> emit,
  ) async {
    if (state is ExpenseLoaded) {
      emit(
        (state as ExpenseLoaded).copyWith(
          selectedCategory: event.category,
          isCustomCategory: event.category == 'Other',
        ),
      );
    }
  }

  Future<void> _onChangeDateExpense(
    ChangeDateExpense event,
    Emitter<ExpenseState> emit,
  ) async {
    if (state is ExpenseLoaded) {
      emit((state as ExpenseLoaded).copyWith(selectedDate: event.date));
    }
  }

  // ─── Public Helpers ───────────────────────────────────────────────────────

  /// يرجع التاريخ بصيغة DB.
  String getFormattedDate(DateTime date) =>
      DateFormat(AppConstants.dbDateFormat).format(date);

  /// يتحقق من صحة المبلغ — يستخدم AppValidators (DRY).
  String? validateAmount(String? value) => AppValidators.amount(value);

  /// يقترح فئة بناءً على الوصف.
  String suggestCategoryFromDescription(String description) =>
      AISuggestionService.suggestCategory(description);

  /// يرجع نصائح مالية.
  List<String> getFinancialTips(double monthlyIncome) {
    if (state is! ExpenseLoaded) {
      return ['Start tracking expenses to get personalized tips!'];
    }
    final expenses = (state as ExpenseLoaded).expenses;
    final currentMonth = DateFormat('yyyy-MM').format(DateTime.now());
    final categorySpending = <String, double>{};
    for (final e in expenses) {
      if (e.date.startsWith(currentMonth)) {
        categorySpending[e.category] =
            (categorySpending[e.category] ?? 0) + e.amount;
      }
    }
    return AISuggestionService.getFinancialTips(
      categorySpending,
      monthlyIncome,
    );
  }

  /// يرجع insights على الإنفاق.
  Map<String, String> getSpendingInsights() {
    if (state is! ExpenseLoaded) return {'general': 'No expenses tracked yet'};
    final expenses = (state as ExpenseLoaded).expenses;
    final currentMonth = DateFormat('yyyy-MM').format(DateTime.now());
    final categorySpending = <String, double>{};
    for (final e in expenses) {
      if (e.date.startsWith(currentMonth)) {
        categorySpending[e.category] =
            (categorySpending[e.category] ?? 0) + e.amount;
      }
    }
    return AISuggestionService.getSpendingInsights(categorySpending);
  }
}
