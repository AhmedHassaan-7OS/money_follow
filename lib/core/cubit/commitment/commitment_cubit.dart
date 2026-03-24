import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:money_follow/control/sqlcontrol.dart';
import 'package:money_follow/models/commitment_model.dart';
import 'package:money_follow/repository/commitment_repository.dart';
import 'package:money_follow/services/commitment_reminder_service.dart';
import 'commitment_state.dart';

/// Handles commitment CRUD, filtering, and reminders.
class CommitmentCubit extends Cubit<CommitmentState> {
  final CommitmentRepository _repo;
  final SqlControl _sql;

  CommitmentCubit({
    CommitmentRepository? repo,
    SqlControl? sql,
  })  : _repo = repo ?? CommitmentRepository(),
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

  Future<void> toggleStatus(CommitmentModel item, bool value) async {
    try {
      final updated = CommitmentModel(
        id: item.id,
        title: item.title,
        amount: item.amount,
        dueDate: item.dueDate,
        isCompleted: value,
      );
      await _repo.update(updated, item.id!);
      if (value && item.id != null) {
        await CommitmentReminderService
            .clearReminderMarkersForCommitment(item.id!);
      }
      await load();
    } catch (e) {
      emit(state.copyWith(message: 'Error updating: $e'));
    }
  }

  Future<void> delete(CommitmentModel item) async {
    try {
      await _repo.delete(item.id!);
      if (item.id != null) {
        await CommitmentReminderService
            .clearReminderMarkersForCommitment(item.id!);
      }
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
      debugPrint('Commitment save: repository insert');
      return await _repo.insert(commitment).timeout(
            const Duration(seconds: 2),
          );
    } catch (_) {
      debugPrint('Commitment save: fallback sqlcontrol');
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
