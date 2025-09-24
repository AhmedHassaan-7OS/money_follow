import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:money_follow/control/sqlcontrol.dart';
import 'package:money_follow/model/income_model.dart';
import 'package:money_follow/model/expense_model.dart';
import 'package:money_follow/model/commitment_model.dart';

class BackupService {
  static const String _backupVersion = '1.0';
  static final SqlControl _sqlControl = SqlControl();

  /// Export all data to a backup file
  static Future<String?> exportBackup() async {
    try {
      // Get all data from database
      final backupData = await _getAllData();
      
      // Create backup object with metadata
      final backup = {
        'version': _backupVersion,
        'timestamp': DateTime.now().toIso8601String(),
        'app_name': 'Money Follow',
        'data': backupData,
      };

      // Convert to JSON
      final jsonString = jsonEncode(backup);
      
      // Get app documents directory
      final directory = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'money_follow_backup_$timestamp.json';
      final filePath = '${directory.path}/$fileName';
      
      // Write to file
      final file = File(filePath);
      await file.writeAsString(jsonString);
      
      return filePath;
    } catch (e) {
      print('Error creating backup: $e');
      return null;
    }
  }

  /// Share backup file
  static Future<bool> shareBackup() async {
    try {
      final filePath = await exportBackup();
      if (filePath != null) {
        await Share.shareXFiles(
          [XFile(filePath)],
          text: 'Money Follow Backup - ${DateTime.now().toString().split(' ')[0]}',
        );
        return true;
      }
      return false;
    } catch (e) {
      print('Error sharing backup: $e');
      return false;
    }
  }

  /// Copy backup data to clipboard for manual import
  static Future<bool> copyBackupToClipboard() async {
    try {
      // Get all data from database
      final backupData = await _getAllData();
      
      // Create backup object with metadata
      final backup = {
        'version': _backupVersion,
        'timestamp': DateTime.now().toIso8601String(),
        'app_name': 'Money Follow',
        'data': backupData,
      };

      // Convert to JSON
      final jsonString = jsonEncode(backup);
      
      // Copy to clipboard
      await Clipboard.setData(ClipboardData(text: jsonString));
      
      return true;
    } catch (e) {
      print('Error copying backup to clipboard: $e');
      return false;
    }
  }

  /// Import backup from clipboard
  static Future<BackupImportResult> importFromClipboard() async {
    try {
      // Get clipboard data
      ClipboardData? data = await Clipboard.getData('text/plain');
      
      if (data != null && data.text != null) {
        return await _processBackupData(data.text!);
      }
      
      return BackupImportResult(
        success: false,
        message: 'No data found in clipboard',
      );
    } catch (e) {
      return BackupImportResult(
        success: false,
        message: 'Error importing from clipboard: $e',
      );
    }
  }

  /// Process and validate backup data
  static Future<BackupImportResult> _processBackupData(String jsonString) async {
    try {
      final Map<String, dynamic> backup = jsonDecode(jsonString);
      
      // Validate backup format
      if (!backup.containsKey('version') || 
          !backup.containsKey('data') ||
          !backup.containsKey('app_name')) {
        return BackupImportResult(
          success: false,
          message: 'Invalid backup file format',
        );
      }

      if (backup['app_name'] != 'Money Follow') {
        return BackupImportResult(
          success: false,
          message: 'This backup file is not from Money Follow app',
        );
      }

      final data = backup['data'] as Map<String, dynamic>;
      
      // Count items to import
      int totalItems = 0;
      totalItems += (data['incomes'] as List?)?.length ?? 0;
      totalItems += (data['expenses'] as List?)?.length ?? 0;
      totalItems += (data['commitments'] as List?)?.length ?? 0;

      return BackupImportResult(
        success: true,
        message: 'Backup file validated successfully',
        data: data,
        itemCount: totalItems,
        backupDate: backup['timestamp'],
      );
    } catch (e) {
      return BackupImportResult(
        success: false,
        message: 'Error reading backup file: $e',
      );
    }
  }

  /// Actually restore the data to database
  static Future<bool> restoreBackup(Map<String, dynamic> data, {bool clearExisting = false}) async {
    try {
      // Clear existing data if requested
      if (clearExisting) {
        await _clearAllData();
      }

      int successCount = 0;
      int errorCount = 0;

      // Import incomes
      if (data.containsKey('incomes')) {
        final incomes = data['incomes'] as List;
        for (var incomeData in incomes) {
          try {
            final income = IncomeModel.fromMap(incomeData);
            await _sqlControl.insertData('incomes', income.toMap());
            successCount++;
          } catch (e) {
            errorCount++;
            print('Error importing income: $e');
          }
        }
      }

      // Import expenses
      if (data.containsKey('expenses')) {
        final expenses = data['expenses'] as List;
        for (var expenseData in expenses) {
          try {
            final expense = ExpenseModel.fromMap(expenseData);
            await _sqlControl.insertData('expenses', expense.toMap());
            successCount++;
          } catch (e) {
            errorCount++;
            print('Error importing expense: $e');
          }
        }
      }

      // Import commitments
      if (data.containsKey('commitments')) {
        final commitments = data['commitments'] as List;
        for (var commitmentData in commitments) {
          try {
            final commitment = CommitmentModel.fromMap(commitmentData);
            await _sqlControl.insertData('commitments', commitment.toMap());
            successCount++;
          } catch (e) {
            errorCount++;
            print('Error importing commitment: $e');
          }
        }
      }

      print('Import completed: $successCount success, $errorCount errors');
      return errorCount == 0;
    } catch (e) {
      print('Error restoring backup: $e');
      return false;
    }
  }

  /// Get all data from database
  static Future<Map<String, dynamic>> _getAllData() async {
    try {
      // Get all incomes
      final incomeData = await _sqlControl.getData('incomes');
      final incomes = incomeData.map((e) => IncomeModel.fromMap(e).toMap()).toList();

      // Get all expenses
      final expenseData = await _sqlControl.getData('expenses');
      final expenses = expenseData.map((e) => ExpenseModel.fromMap(e).toMap()).toList();

      // Get all commitments
      final commitmentData = await _sqlControl.getData('commitments');
      final commitments = commitmentData.map((e) => CommitmentModel.fromMap(e).toMap()).toList();

      return {
        'incomes': incomes,
        'expenses': expenses,
        'commitments': commitments,
      };
    } catch (e) {
      print('Error getting data: $e');
      return {};
    }
  }

  /// Clear all data from database
  static Future<void> _clearAllData() async {
    try {
      // Note: Since we don't have a clear method, we'll need to delete all records
      // This is a simplified approach - in production you might want to truncate tables
      final incomes = await _sqlControl.getData('incomes');
      for (var income in incomes) {
        await _sqlControl.deleteData('incomes', income['id']);
      }

      final expenses = await _sqlControl.getData('expenses');
      for (var expense in expenses) {
        await _sqlControl.deleteData('expenses', expense['id']);
      }

      final commitments = await _sqlControl.getData('commitments');
      for (var commitment in commitments) {
        await _sqlControl.deleteData('commitments', commitment['id']);
      }
    } catch (e) {
      print('Error clearing data: $e');
    }
  }

  /// Get backup file size in MB
  static Future<double> getBackupSize() async {
    try {
      final data = await _getAllData();
      final backup = {
        'version': _backupVersion,
        'timestamp': DateTime.now().toIso8601String(),
        'app_name': 'Money Follow',
        'data': data,
      };
      final jsonString = jsonEncode(backup);
      final sizeInBytes = utf8.encode(jsonString).length;
      return sizeInBytes / (1024 * 1024); // Convert to MB
    } catch (e) {
      return 0.0;
    }
  }
}

class BackupImportResult {
  final bool success;
  final String message;
  final Map<String, dynamic>? data;
  final int itemCount;
  final String? backupDate;

  BackupImportResult({
    required this.success,
    required this.message,
    this.data,
    this.itemCount = 0,
    this.backupDate,
  });
}
