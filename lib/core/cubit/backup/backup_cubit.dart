import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:money_follow/models/backup_models.dart';
import 'package:money_follow/services/backup_service.dart';
import 'backup_state.dart';

/// Handles backup export / import operations.
class BackupCubit extends Cubit<BackupState> {
  BackupCubit() : super(const BackupState());

  Future<void> loadBackupSize() async {
    final size = await BackupService.getBackupSize();
    emit(state.copyWith(backupSize: size));
  }

  Future<void> shareBackup([BuildContext? ctx]) async {
    emit(state.copyWith(isLoading: true));
    try {
      final ok = await BackupService.shareBackup(ctx);
      emit(state.copyWith(
        isLoading: false,
        isSuccess: ok,
        message: ok ? 'Backup exported successfully!' : 'Failed to export',
      ));
    } catch (e) {
      emit(state.copyWith(isLoading: false, message: 'Error: $e'));
    }
  }

  Future<void> copyToClipboard([BuildContext? ctx]) async {
    emit(state.copyWith(isLoading: true));
    try {
      final ok = await BackupService.copyBackupToClipboard(ctx);
      emit(state.copyWith(
        isLoading: false,
        isSuccess: ok,
        message: ok ? 'Copied to clipboard!' : 'Failed to copy',
      ));
    } catch (e) {
      emit(state.copyWith(isLoading: false, message: 'Error: $e'));
    }
  }

  Future<BackupImportResult> importFromClipboard() async {
    emit(state.copyWith(isLoading: true));
    try {
      final result = await BackupService.importFromClipboard();
      emit(state.copyWith(isLoading: false));
      return result;
    } catch (e) {
      emit(state.copyWith(isLoading: false, message: 'Error: $e'));
      return BackupImportResult(success: false, message: '$e');
    }
  }

  Future<BackupImportResult> pickAndImportFile([BuildContext? ctx]) async {
    emit(state.copyWith(isLoading: true));
    try {
      final result = await BackupService.pickAndImportFile(ctx);
      emit(state.copyWith(isLoading: false));
      return result;
    } catch (e) {
      emit(state.copyWith(isLoading: false, message: 'Error: $e'));
      return BackupImportResult(success: false, message: '$e');
    }
  }

  Future<BackupImportResult> importFromText(String text) async {
    emit(state.copyWith(isLoading: true));
    try {
      final result = await BackupService.importFromText(text);
      emit(state.copyWith(isLoading: false));
      return result;
    } catch (e) {
      emit(state.copyWith(isLoading: false, message: 'Error: $e'));
      return BackupImportResult(success: false, message: '$e');
    }
  }

  Future<void> performRestore(Map<String, dynamic> data) async {
    emit(state.copyWith(isLoading: true));
    try {
      final ok = await BackupService.restoreBackup(
        data,
        clearExisting: true,
      );
      emit(state.copyWith(
        isLoading: false,
        isSuccess: ok,
        message: ok ? 'Imported successfully!' : 'Failed to import',
      ));
      if (ok) await loadBackupSize();
    } catch (e) {
      emit(state.copyWith(isLoading: false, message: 'Error: $e'));
    }
  }
}
