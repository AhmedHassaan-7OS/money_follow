import 'package:money_follow/models/income_model.dart';

class IncomeState {
  final List<IncomeModel> incomes;
  final DateTime selectedDate;
  final bool isLoading;
  final String? message;
  final bool isSuccess;

  IncomeState({
    this.incomes = const [],
    DateTime? selectedDate,
    this.isLoading = false,
    this.message,
    this.isSuccess = false,
  }) : selectedDate = selectedDate ?? DateTime.now();

  IncomeState copyWith({
    List<IncomeModel>? incomes,
    DateTime? selectedDate,
    bool? isLoading,
    String? message,
    bool? isSuccess,
  }) {
    return IncomeState(
      incomes: incomes ?? this.incomes,
      selectedDate: selectedDate ?? this.selectedDate,
      isLoading: isLoading ?? this.isLoading,
      message: message,
      isSuccess: isSuccess ?? false,
    );
  }
}
