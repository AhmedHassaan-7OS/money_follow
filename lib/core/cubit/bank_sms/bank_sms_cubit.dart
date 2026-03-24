import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:money_follow/services/bank_sms_service.dart';
import 'bank_sms_state.dart';

/// Manages bank SMS capture settings.
class BankSmsCubit extends Cubit<BankSmsState> {
  BankSmsCubit() : super(const BankSmsState());

  Future<void> loadState() async {
    try {
      final capture = await BankSmsService.getCaptureEnabled();
      final auto = await BankSmsService.getAutoRecordEnabled();
      final pending = await BankSmsService.getPendingTransactions();
      emit(state.copyWith(
        captureEnabled: capture,
        autoRecordEnabled: auto,
        pendingCount: pending.length,
        pendingTransactions: pending,
        isLoading: false,
      ));
    } catch (_) {
      emit(state.copyWith(isLoading: false));
    }
  }

  Future<bool> toggleCapture(bool value) async {
    if (value) {
      final granted = await BankSmsService.requestSmsPermissions();
      if (!granted) return false;
    }
    await BankSmsService.setCaptureEnabled(value);
    emit(state.copyWith(captureEnabled: value));
    return true;
  }

  Future<void> toggleAutoRecord(bool value) async {
    await BankSmsService.setAutoRecordEnabled(value);
    emit(state.copyWith(autoRecordEnabled: value));
  }

  Future<void> refreshPendingCount() async {
    final pending = await BankSmsService.getPendingTransactions();
    emit(state.copyWith(pendingCount: pending.length, pendingTransactions: pending));
  }

  Future<void> confirmAndSave(dynamic tx) async {
    await BankSmsService.confirmAndSave(tx);
    await refreshPendingCount();
  }

  Future<void> removePending(dynamic tx) async {
    await BankSmsService.removePendingById(tx.id);
    await refreshPendingCount();
  }
}
