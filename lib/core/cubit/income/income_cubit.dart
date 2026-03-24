import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:money_follow/core/constants/app_constants.dart';
import 'package:money_follow/models/income_model.dart';
import 'package:money_follow/repository/income_repository.dart';
import 'income_state.dart';

/// Handles income CRUD and form state.
class IncomeCubit extends Cubit<IncomeState> {
  final IncomeRepository _repository;

  IncomeCubit({IncomeRepository? repository})
      : _repository = repository ?? IncomeRepository(),
        super(IncomeState());

  Future<void> loadIncomes() async {
    emit(state.copyWith(isLoading: true));
    try {
      final items = await _repository.getAll();
      items.sort((a, b) => b.date.compareTo(a.date));
      emit(state.copyWith(incomes: items, isLoading: false));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        message: 'Error loading incomes: $e',
      ));
    }
  }

  Future<void> saveIncome({
    required double amount,
    required String source,
  }) async {
    try {
      final income = IncomeModel(
        amount: amount,
        source: source,
        date: DateFormat(AppConstants.dbDateFormat)
            .format(state.selectedDate),
      );
      await _repository.insert(income);
      emit(state.copyWith(
        message: 'Income saved successfully!',
        isSuccess: true,
        selectedDate: DateTime.now(),
      ));
      await loadIncomes();
    } catch (e) {
      emit(state.copyWith(message: 'Error saving income: $e'));
    }
  }

  void setDate(DateTime date) {
    emit(state.copyWith(selectedDate: date));
  }
}
