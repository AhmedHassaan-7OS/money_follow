import 'package:flutter/material.dart';
import 'package:money_follow/models/backup_models.dart';
import 'package:money_follow/services/backup_export_service.dart';
import 'package:money_follow/services/backup_import_service.dart';
import 'package:money_follow/services/permission_service.dart';

/// Main service for handling backup and restore operations
/// Acts as a facade for all backup-related functionality
class BackupService {
  // Singleton instance
  static final BackupService _instance = BackupService._internal();
  factory BackupService() => _instance;
  
  // Private constructor
  BackupService._internal();

  // ============================================================================
  // PERMISSION MANAGEMENT
  // ============================================================================

  /// Check and request storage permissions for backup operations
  static Future<bool> checkAndRequestPermissions([BuildContext? context]) async {
    if (context != null) {
      return await PermissionService.requestPermissionsForBackup(context);
    } else {
      return await PermissionService.checkCurrentPermissionStatus();
    }
  }

  // ============================================================================
  // BACKUP EXPORT OPERATIONS
  // ============================================================================

  /// Export backup and save to app directory for sharing
  static Future<String?> exportBackup([BuildContext? context]) async {
    return await BackupExportService.exportBackup(context);
  }

  /// Share backup file
  static Future<bool> shareBackup([BuildContext? context]) async {
    return await BackupExportService.shareBackup(context);
  }

  /// Copy backup data to clipboard
  static Future<bool> copyBackupToClipboard([BuildContext? context]) async {
    return await BackupExportService.copyBackupToClipboard(context);
  }

  /// Get backup data as JSON string
  static Future<String> getBackupAsJson() async {
    return await BackupExportService.getBackupAsJson();
  }

  /// Get backup file size in MB
  static Future<double> getBackupSize() async {
    return await BackupExportService.getBackupSize();
  }

  /// Check if backup is possible (has data to backup)
  static Future<bool> canCreateBackup() async {
    return await BackupExportService.canCreateBackup();
  }

  /// Get backup statistics
  static Future<Map<String, int>> getBackupStatistics() async {
    return await BackupExportService.getBackupStatistics();
  }

  // ============================================================================
  // BACKUP IMPORT OPERATIONS
  // ============================================================================

  /// Pick and import backup file using file picker
  static Future<BackupImportResult> pickAndImportFile([BuildContext? context]) async {
    return await BackupImportService.pickAndImportFile(context);
  }

  /// Import backup from text input
  static Future<BackupImportResult> importFromText(String backupText) async {
    return await BackupImportService.importFromText(backupText);
  }

  /// Import backup from clipboard
  static Future<BackupImportResult> importFromClipboard() async {
    return await BackupImportService.importFromClipboard();
  }

  /// Restore backup data to database
  static Future<bool> restoreBackup(
    Map<String, dynamic> data, {
    bool clearExisting = false,
  }) async {
    return await BackupImportService.restoreBackup(data, clearExisting: clearExisting);
  }

  /// Validate backup text before processing
  static BackupImportResult validateBackupText(String backupText) {
    return BackupImportService.validateBackupText(backupText);
  }

  /// Get available import options
  static List<ImportOption> getAvailableImportOptions() {
    return BackupImportService.getAvailableImportOptions();
  }

  /// Check if file picker import is available
  static bool get isFilePickerAvailable => BackupImportService.isFilePickerAvailable;

  /// Get supported file types for import
  static List<String> get supportedFileTypes => BackupImportService.supportedFileTypes;

  /// Preview backup data without importing
  static Future<BackupImportResult> previewBackup(String backupText) async {
    return await BackupImportService.previewBackup(backupText);
  }

  /// Get import statistics from backup data
  static Map<String, int> getImportStatistics(Map<String, dynamic> data) {
    return BackupImportService.getImportStatistics(data);
  }

  // ============================================================================
  // UTILITY METHODS
  // ============================================================================

  /// Show permission status dialog
  static Future<void> showPermissionStatusDialog(BuildContext context) async {
    return await PermissionService.showPermissionStatusDialog(context);
  }

  /// Check current permission status
  static Future<bool> checkCurrentPermissionStatus() async {
    return await PermissionService.checkCurrentPermissionStatus();
  }
}
