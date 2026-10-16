import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:money_follow/control/sqlcontrol.dart';
import 'package:money_follow/core/constants/app_constants.dart';
import 'package:money_follow/models/commitment_model.dart';
import 'package:money_follow/models/expense_model.dart';
import 'package:money_follow/repository/commitment_repository.dart';
import 'package:money_follow/repository/expense_repository.dart';
import 'package:money_follow/services/commitment_reminder_service.dart';
import 'commitment_state.dart';

/// Handles commitment CRUD, filtering, and reminders.
class CommitmentCubit extends Cubit<CommitmentState> {
  final CommitmentRepository _repo;
  final ExpenseRepository _expenseRepo;
  final SqlControl _sql;

  CommitmentCubit({
    CommitmentRepository? repo,
    ExpenseRepository? expenseRepo,
    SqlControl? sql,
  })  : _repo = repo ?? CommitmentRepository(),
        _expenseRepo = expenseRepo ?? ExpenseRepository(),
        _sql = sql ?? SqlControl(),
        super(const CommitmentState());

  Future<void> load() async {
    emit(state.copyWith(isLoading: true));
    try {
      final items = await _repo.getAllSortedByDueDate();
      emit(state.copyWith(commitments: items, isLoading: false));
      _triggerReminderCheck();
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        message: 'Error loading commitments: $e',
      ));
    }
  }

  void setFilter(CommitmentFilter filter) {
    emit(state.copyWith(filter: filter));
  }

  Future<void> toggleStatus(
    CommitmentModel item,
    bool value, {
    bool recordAsExpense = false,
  }) async {
    if (item.id == null) return;
    try {
      final updated = CommitmentModel(
        id: item.id,
        title: item.title,
        amount: item.amount,
        dueDate: item.dueDate,
        isCompleted: value,
      );
      await _repo.update(updated, item.id!);
      if (value) {
        await CommitmentReminderService
            .clearReminderMarkersForCommitment(item.id!);
        if (recordAsExpense) {
          await _expenseRepo.insert(ExpenseModel(
            amount: item.amount,
            category: 'Bills',
            date: DateFormat(AppConstants.dbDateFormat).format(DateTime.now()),
            note: 'Paid commitment: ${item.title}',
          ));
        }
      }
      await load();
    } catch (e) {
      emit(state.copyWith(message: 'Error updating: $e'));
    }
  }

  Future<void> delete(CommitmentModel item) async {
    if (item.id == null) return;
    try {
      await _repo.delete(item.id!);
      await CommitmentReminderService
          .clearReminderMarkersForCommitment(item.id!);
      emit(state.copyWith(
        message: 'Commitment deleted',
        isSuccess: true,
      ));
      await load();
    } catch (e) {
      emit(state.copyWith(message: 'Error deleting: $e'));
    }
  }

  Future<int> insertSafe(CommitmentModel commitment) async {
    try {
      return await _repo.insert(commitment).timeout(
            const Duration(seconds: 2),
          );
    } catch (_) {
      final map = commitment.toMap()..remove('id');
      return await _sql.insertData('commitments', map).timeout(
            const Duration(seconds: 2),
          );
    }
  }

  Future<void> _triggerReminderCheck() async {
    try {
      await CommitmentReminderService
          .checkAndNotifyDueCommitments()
          .timeout(const Duration(seconds: 2));
    } catch (_) {}
  }
}
