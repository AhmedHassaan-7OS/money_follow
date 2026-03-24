import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:money_follow/config/app_theme.dart';
import 'package:money_follow/control/sqlcontrol.dart';
import 'package:money_follow/core/constants/app_constants.dart';
import 'package:money_follow/models/expense_model.dart';
import 'package:money_follow/models/income_model.dart';
import 'package:money_follow/models/commitment_model.dart';
import 'history_state.dart';

/// Loads and manages transaction history.
class HistoryCubit extends Cubit<HistoryState> {
  final SqlControl _sql;

  HistoryCubit({SqlControl? sql})
      : _sql = sql ?? SqlControl(),
        super(const HistoryState());

  Future<void> loadHistory() async {
    emit(state.copyWith(isLoading: true));
    try {
      final items = <HistoryItem>[];
      await _loadExpenses(items);
      await _loadIncomes(items);
      await _loadCommitments(items);
      items.sort((a, b) => b.date.compareTo(a.date));
      emit(state.copyWith(items: items, isLoading: false));
    } catch (_) {
      emit(state.copyWith(isLoading: false));
    }
  }

  void setFilter(String filter) {
    emit(state.copyWith(selectedFilter: filter));
  }

  Future<void> _loadExpenses(List<HistoryItem> out) async {
    final data = await _sql.getData('expenses');
    for (final row in data) {
      final m = ExpenseModel.fromMap(row);
      out.add(HistoryItem(
        id: m.id.toString(),
        type: 'Expense',
        title: m.category,
        amount: -m.amount,
        date: DateTime.parse(m.date),
        note: m.note,
        icon: AppConstants.getCategoryIcon(m.category),
        color: AppTheme.errorColor,
      ));
    }
  }

  Future<void> _loadIncomes(List<HistoryItem> out) async {
    final data = await _sql.getData('incomes');
    for (final row in data) {
      final m = IncomeModel.fromMap(row);
      out.add(HistoryItem(
        id: m.id.toString(),
        type: 'Income',
        title: m.source,
        amount: m.amount,
        date: DateTime.parse(m.date),
        icon: AppConstants.getIncomeSourceIcon(m.source),
        color: AppTheme.accentGreen,
      ));
    }
  }

  Future<void> _loadCommitments(List<HistoryItem> out) async {
    final data = await _sql.getData('commitments');
    for (final row in data) {
      final m = CommitmentModel.fromMap(row);
      out.add(HistoryItem(
        id: m.id.toString(),
        type: 'Commitment',
        title: m.title,
        amount: -m.amount,
        date: DateTime.parse(m.dueDate),
        icon: AppConstants.getCommitmentIcon(m.title),
        color: AppTheme.warningColor,
      ));
    }
  }

  // ── Item lookup for edit navigation ──

  Future<IncomeModel?> getIncomeById(String id) async {
    return _findById<IncomeModel>(
      'incomes', id, (m) => IncomeModel.fromMap(m),
    );
  }

  Future<ExpenseModel?> getExpenseById(String id) async {
    return _findById<ExpenseModel>(
      'expenses', id, (m) => ExpenseModel.fromMap(m),
    );
  }

  Future<CommitmentModel?> getCommitmentById(String id) async {
    return _findById<CommitmentModel>(
      'commitments', id, (m) => CommitmentModel.fromMap(m),
    );
  }

  Future<T?> _findById<T>(
    String table,
    String id,
    T Function(Map<String, dynamic>) fromMap,
  ) async {
    try {
      final data = await _sql.getData(table);
      final target = int.parse(id);
      for (final row in data) {
        if (row['id'] == target) return fromMap(row);
      }
    } catch (_) {}
    return null;
  }
}
