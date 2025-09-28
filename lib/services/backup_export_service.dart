import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:money_follow/models/backup_models.dart';
import 'package:money_follow/constants/backup_constants.dart';
import 'package:money_follow/services/backup_data_processor.dart';
import 'package:money_follow/services/permission_service.dart';

/// Service for exporting backup data
/// Handles backup creation, file saving, and sharing operations
class BackupExportService {
  // Singleton instance
  static final BackupExportService _instance = BackupExportService._internal();
  factory BackupExportService() => _instance;
  BackupExportService._internal();

  /// Export backup and save to app directory for sharing
  static Future<String?> exportBackup([BuildContext? context]) async {
    try {
      // Check permissions first
      final hasPermissions = await _checkPermissions(context);
      if (!hasPermissions) {
        print('تم رفض صلاحيات التخزين - لا يمكن تصدير النسخة الاحتياطية');
        return null;
      }

      // Get all data from database
      final allData = await BackupDataProcessor.getAllData();

      // Create backup data structure
      final backupData = BackupDataProcessor.createBackupData(allData);

      // Convert to JSON
      final jsonString = jsonEncode(backupData.toMap());

      // Save to file
      final filePath = await _saveBackupToFile(jsonString);

      print('Backup exported to: $filePath');
      return filePath;
    } catch (e) {
      print('Error creating backup: $e');
      return null;
    }
  }

  /// Share backup file
  static Future<bool> shareBackup([BuildContext? context]) async {
    try {
      final filePath = await exportBackup(context);
      if (filePath != null) {
        await Share.shareXFiles(
          [XFile(filePath)],
          text: _generateShareText(),
        );
        return true;
      }
      return false;
    } catch (e) {
      print('Error sharing backup: $e');
      return false;
    }
  }

  /// Copy backup data to clipboard
  static Future<bool> copyBackupToClipboard([BuildContext? context]) async {
    try {
      // Note: Clipboard operations don't require storage permissions
      // but we check permissions to ensure user is aware of backup functionality
      final hasPermissions = await _checkPermissions(context);
      if (!hasPermissions && context != null) {
        // Show warning but still allow clipboard copy
        print('تحذير: لم يتم منح صلاحيات التخزين - ستكون ميزات النسخ الاحتياطي محدودة');
      }

      // Get backup data
      final backupJson = await _createBackupJson();
      
      // Copy to clipboard
      await Clipboard.setData(ClipboardData(text: backupJson));
      return true;
    } catch (e) {
      print('Error copying backup to clipboard: $e');
      return false;
    }
  }

  /// Get backup data as JSON string
  static Future<String> getBackupAsJson() async {
    return await _createBackupJson();
  }

  /// Get backup file size in MB
  static Future<double> getBackupSize() async {
    return await BackupDataProcessor.getBackupSize();
  }

  /// Check and request permissions for backup operations
  static Future<bool> _checkPermissions([BuildContext? context]) async {
    if (context != null) {
      return await PermissionService.requestPermissionsForBackup(context);
    } else {
      return await PermissionService.checkCurrentPermissionStatus();
    }
  }

  /// Create backup JSON string
  static Future<String> _createBackupJson() async {
    final allData = await BackupDataProcessor.getAllData();
    final backupData = BackupDataProcessor.createBackupData(allData);
    return jsonEncode(backupData.toMap());
  }

  /// Save backup to file in app directory
  static Future<String> _saveBackupToFile(String jsonString) async {
    // Get app documents directory
    final directory = await getApplicationDocumentsDirectory();
    final fileName = BackupConstants.generateBackupFileName();
    final filePath = '${directory.path}/$fileName';

    // Write to file
    final file = File(filePath);
    await file.writeAsString(jsonString, encoding: utf8);

    return filePath;
  }

  /// Generate share text for backup file
  static String _generateShareText() {
    final date = DateTime.now().toString().split(' ')[0];
    return 'Money Follow Backup - $date';
  }

  /// Create backup data structure for export
  static Future<BackupData> createBackupData() async {
    final allData = await BackupDataProcessor.getAllData();
    return BackupDataProcessor.createBackupData(allData);
  }

  /// Validate backup before export
  static Future<bool> validateBackupData() async {
    try {
      final allData = await BackupDataProcessor.getAllData();
      return allData.isNotEmpty;
    } catch (e) {
      print('Error validating backup data: $e');
      return false;
    }
  }

  /// Get backup statistics
  static Future<Map<String, int>> getBackupStatistics() async {
    try {
      final allData = await BackupDataProcessor.getAllData();
      return {
        'incomes': (allData['incomes'] as List?)?.length ?? 0,
        'expenses': (allData['expenses'] as List?)?.length ?? 0,
        'commitments': (allData['commitments'] as List?)?.length ?? 0,
        'total': BackupDataProcessor.countBackupItems(allData),
      };
    } catch (e) {
      print('Error getting backup statistics: $e');
      return {
        'incomes': 0,
        'expenses': 0,
        'commitments': 0,
        'total': 0,
      };
    }
  }

  /// Check if backup is possible (has data to backup)
  static Future<bool> canCreateBackup() async {
    try {
      final stats = await getBackupStatistics();
      return stats['total']! > 0;
    } catch (e) {
      return false;
    }
  }
}
