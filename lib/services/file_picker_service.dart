import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:money_follow/models/backup_models.dart';
import 'package:money_follow/constants/backup_constants.dart';
import 'package:money_follow/services/permission_service.dart';

/// Service for handling file picker operations
/// Manages file selection, validation, and content reading
class FilePickerService {
  // Singleton instance
  static final FilePickerService _instance = FilePickerService._internal();
  factory FilePickerService() => _instance;
  FilePickerService._internal();

  /// Pick and read backup file using file_picker with enhanced error handling
  static Future<BackupFileResult> pickBackupFile([BuildContext? context]) async {
    try {
      // Check permissions first
      final hasPermissions = await _checkPermissions(context);
      if (!hasPermissions) {
        return BackupFileResult.failure(BackupConstants.permissionDeniedMessage);
      }

      // Use file_picker with enhanced configuration
      final result = await _attemptFilePicker();
      if (result == null) {
        return BackupFileResult.failure(BackupConstants.noFileSelectedMessage);
      }

      final pickedFile = result.files.first;
      
      // Validate file extension
      if (!BackupConstants.isValidJsonExtension(pickedFile.extension)) {
        return BackupFileResult.failure(BackupConstants.invalidFileExtensionMessage);
      }

      // Read file content
      final contentResult = await _readFileContent(pickedFile);
      if (!contentResult.success) {
        return contentResult;
      }

      // Validate content format
      if (!_validateFileContent(contentResult.content!)) {
        return BackupFileResult.failure(BackupConstants.invalidFormatMessage);
      }

      debugPrint('Successfully read backup file: ${pickedFile.name}');
      
      return BackupFileResult.success(
        filePath: pickedFile.path,
        fileName: pickedFile.name,
        content: contentResult.content,
      );
      
    } catch (e) {
      debugPrint('File picker error: $e');
      return BackupFileResult.failure(
        'خطأ في اختيار الملف: $e. يرجى استخدام الإدخال اليدوي كبديل.'
      );
    }
  }

  /// Check and request permissions for file operations
  static Future<bool> _checkPermissions([BuildContext? context]) async {
    if (context != null) {
      return await PermissionService.requestPermissionsForBackup(context);
    } else {
      return await PermissionService.checkCurrentPermissionStatus();
    }
  }

  /// Attempt to use file picker with fallback options
  static Future<FilePickerResult?> _attemptFilePicker() async {
    try {
      // First attempt: Try with JSON filter
      return await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: BackupConstants.allowedExtensions,
        withData: true, // Important for reading file content
        allowMultiple: false,
      );
    } catch (e) {
      debugPrint('JSON filter failed, trying with any file type: $e');
      
      // Fallback: Allow any file type
      try {
        return await FilePicker.platform.pickFiles(
          type: FileType.any,
          withData: true,
          allowMultiple: false,
        );
      } catch (e2) {
        debugPrint('File picker completely failed: $e2');
        return null;
      }
    }
  }

  /// Read file content using multiple methods
  static Future<BackupFileResult> _readFileContent(PlatformFile pickedFile) async {
    try {
      String fileContent;
      
      if (pickedFile.bytes != null && pickedFile.bytes!.isNotEmpty) {
        // Primary method: Read from bytes (works with scoped storage)
        fileContent = utf8.decode(pickedFile.bytes!);
        debugPrint('Successfully read file from bytes');
      } else if (pickedFile.path != null) {
        // Fallback method: Read from file path
        final file = File(pickedFile.path!);
        if (await file.exists()) {
          fileContent = await file.readAsString(encoding: utf8);
          debugPrint('Successfully read file from path: ${pickedFile.path}');
        } else {
          throw Exception('File does not exist at path: ${pickedFile.path}');
        }
      } else {
        throw Exception('No file data or path available');
      }

      return BackupFileResult.success(content: fileContent);
    } catch (e) {
      debugPrint('Error reading file content: $e');
      return BackupFileResult.failure('خطأ في قراءة محتوى الملف: $e');
    }
  }

  /// Validate file content
  static bool _validateFileContent(String content) {
    // Check if content is empty
    if (content.trim().isEmpty) {
      return false;
    }

    // Validate JSON format
    return BackupConstants.isValidJsonFormat(content);
  }

  /// Validate file extension
  static bool validateFileExtension(String? extension) {
    return BackupConstants.isValidJsonExtension(extension);
  }

  /// Check if file picker is available on current platform
  static bool get isFilePickerSupported {
    return Platform.isAndroid || Platform.isIOS || Platform.isWindows || Platform.isMacOS || Platform.isLinux;
  }

  /// Get supported file types for display
  static List<String> get supportedFileTypes => BackupConstants.allowedExtensions;

  /// Generate file picker configuration
  static Map<String, dynamic> getFilePickerConfig({bool allowAnyType = false}) {
    return {
      'type': allowAnyType ? FileType.any : FileType.custom,
      'allowedExtensions': allowAnyType ? null : BackupConstants.allowedExtensions,
      'withData': true,
      'allowMultiple': false,
    };
  }
}
