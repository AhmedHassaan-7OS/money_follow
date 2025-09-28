import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:money_follow/models/backup_models.dart';
import 'package:money_follow/constants/backup_constants.dart';
import 'package:money_follow/services/backup_data_processor.dart';
import 'package:money_follow/services/file_picker_service.dart';

/// Service for importing backup data
/// Handles backup import from files, text input, and clipboard
class BackupImportService {
  // Singleton instance
  static final BackupImportService _instance = BackupImportService._internal();
  factory BackupImportService() => _instance;
  BackupImportService._internal();

  /// Pick and import backup file using file picker
  static Future<BackupImportResult> pickAndImportFile([BuildContext? context]) async {
    try {
      // Use file picker service to select and read file
      final fileResult = await FilePickerService.pickBackupFile(context);
      
      if (!fileResult.success) {
        return BackupImportResult.failure(fileResult.error ?? BackupConstants.filePickerFailedMessage);
      }

      // Process the backup data
      return await BackupDataProcessor.processBackupData(fileResult.content!);
      
    } catch (e) {
      print('File picker error: $e');
      return BackupImportResult.failure(
        'خطأ في اختيار الملف: $e. يرجى استخدام الإدخال اليدوي كبديل.'
      );
    }
  }

  /// Import backup from text input
  static Future<BackupImportResult> importFromText(String backupText) async {
    if (backupText.trim().isEmpty) {
      return BackupImportResult.failure(BackupConstants.emptyInputMessage);
    }

    return await BackupDataProcessor.processBackupData(backupText.trim());
  }

  /// Import backup from clipboard
  static Future<BackupImportResult> importFromClipboard() async {
    try {
      final data = await Clipboard.getData('text/plain');
      if (data?.text != null) {
        return await BackupDataProcessor.processBackupData(data!.text!);
      }
      
      return BackupImportResult.failure(BackupConstants.noClipboardDataMessage);
    } catch (e) {
      return BackupImportResult.failure('خطأ في استيراد البيانات من الحافظة: $e');
    }
  }

  /// Restore backup data to database
  static Future<bool> restoreBackup(
    Map<String, dynamic> data, {
    bool clearExisting = false,
  }) async {
    return await BackupDataProcessor.restoreBackup(data, clearExisting: clearExisting);
  }

  /// Validate backup text before processing
  static BackupImportResult validateBackupText(String backupText) {
    if (backupText.trim().isEmpty) {
      return BackupImportResult.failure(BackupConstants.emptyInputMessage);
    }

    // Validate JSON format
    if (!BackupDataProcessor.validateJsonFormat(backupText)) {
      return BackupImportResult.failure(BackupConstants.invalidFormatMessage);
    }

    return BackupImportResult.success(message: 'تنسيق صحيح');
  }

  /// Get import options available on current platform
  static List<ImportOption> getAvailableImportOptions() {
    final options = <ImportOption>[
      ImportOption.manualInput,
      ImportOption.clipboard,
    ];

    // Add file picker option if supported
    if (FilePickerService.isFilePickerSupported) {
      options.insert(0, ImportOption.filePicker);
    }

    return options;
  }

  /// Check if file picker import is available
  static bool get isFilePickerAvailable => FilePickerService.isFilePickerSupported;

  /// Get supported file types for import
  static List<String> get supportedFileTypes => FilePickerService.supportedFileTypes;

  /// Import backup with automatic source detection
  static Future<BackupImportResult> importBackupAuto(String input) async {
    // Try to detect if input is a file path or JSON content
    if (input.trim().startsWith('{') && input.trim().endsWith('}')) {
      // Looks like JSON content
      return await importFromText(input);
    } else {
      // Might be a file path or invalid input
      return BackupImportResult.failure('تنسيق غير مدعوم. يرجى استخدام محتوى JSON أو اختيار ملف.');
    }
  }

  /// Get import statistics from backup data
  static Map<String, int> getImportStatistics(Map<String, dynamic> data) {
    return {
      'incomes': (data['incomes'] as List?)?.length ?? 0,
      'expenses': (data['expenses'] as List?)?.length ?? 0,
      'commitments': (data['commitments'] as List?)?.length ?? 0,
      'total': BackupDataProcessor.countBackupItems(data),
    };
  }

  /// Preview backup data without importing
  static Future<BackupImportResult> previewBackup(String backupText) async {
    try {
      final result = await BackupDataProcessor.processBackupData(backupText);
      if (result.success) {
        // Return preview without actually importing
        return BackupImportResult.success(
          message: 'معاينة النسخة الاحتياطية',
          data: result.data,
          itemCount: result.itemCount,
          backupDate: result.backupDate,
        );
      }
      return result;
    } catch (e) {
      return BackupImportResult.failure('خطأ في معاينة النسخة الاحتياطية: $e');
    }
  }
}

/// Available import options
enum ImportOption {
  filePicker,
  manualInput,
  clipboard,
}

/// Extension for ImportOption enum
extension ImportOptionExtension on ImportOption {
  String get displayName {
    switch (this) {
      case ImportOption.filePicker:
        return 'اختيار ملف';
      case ImportOption.manualInput:
        return 'إدخال يدوي';
      case ImportOption.clipboard:
        return 'من الحافظة';
    }
  }

  String get description {
    switch (this) {
      case ImportOption.filePicker:
        return 'اختر ملف النسخة الاحتياطية من الجهاز';
      case ImportOption.manualInput:
        return 'الصق محتوى النسخة الاحتياطية يدوياً';
      case ImportOption.clipboard:
        return 'استيراد من الحافظة مباشرة';
    }
  }
}
