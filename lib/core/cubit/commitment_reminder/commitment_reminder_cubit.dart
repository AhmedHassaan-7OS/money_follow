import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:money_follow/services/commitment_reminder_service.dart';
import 'commitment_reminder_state.dart';

/// Manages commitment reminder settings.
class CommitmentReminderCubit extends Cubit<CommitmentReminderState> {
  CommitmentReminderCubit() : super(const CommitmentReminderState());

  Future<void> loadSettings() async {
    final s = await CommitmentReminderService.getSettings();
    emit(state.copyWith(
      enabled: s.enabled,
      hoursBefore: s.hoursBefore,
      isLoading: false,
    ));
  }

  Future<bool> toggleEnabled(bool value) async {
    if (value) {
      final ok = await CommitmentReminderService
          .requestNotificationPermission();
      if (!ok) return false;
    }
    await CommitmentReminderService.setEnabled(value);
    emit(state.copyWith(enabled: value));
    if (value) {
      await CommitmentReminderService.checkAndNotifyDueCommitments();
    }
    return true;
  }

  Future<void> setHoursBefore(int value) async {
    await CommitmentReminderService.setHoursBefore(value);
    emit(state.copyWith(hoursBefore: value));
  }
}
