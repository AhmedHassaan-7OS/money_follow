import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:money_follow/control/sqlcontrol.dart';
import 'package:money_follow/model/expense_model.dart';
import 'package:money_follow/model/income_model.dart';
import 'package:money_follow/model/commitment_model.dart';
import 'package:money_follow/models/backup_models.dart';
import 'package:money_follow/constants/backup_constants.dart';

/// Service for processing backup data
/// Handles data validation, transformation, and database operations
class BackupDataProcessor {
  // Singleton instance
  static final BackupDataProcessor _instance = BackupDataProcessor._internal();
  factory BackupDataProcessor() => _instance;
  BackupDataProcessor._internal();

  // Database controller
  static final SqlControl _sqlControl = SqlControl();

  /// Process and validate backup data from JSON string
  static Future<BackupImportResult> processBackupData(String jsonString) async {
    try {
      final Map<String, dynamic> backupMap = jsonDecode(jsonString);
      final backupData = BackupData.fromMap(backupMap);

      // Validate backup format
      if (!backupData.isValid) {
        return BackupImportResult.failure(BackupConstants.invalidBackupFormatMessage);
      }

      // Validate app name
      if (!BackupConstants.isValidAppName(backupData.appName)) {
        return BackupImportResult.failure(BackupConstants.wrongAppMessage);
      }

      return BackupImportResult.success(
        message: BackupConstants.backupValidatedMessage,
        data: backupData.data,
        itemCount: backupData.itemCount,
        backupDate: backupData.timestamp,
      );
    } catch (e) {
      return BackupImportResult.failure('خطأ في قراءة ملف النسخة الاحتياطية: $e');
    }
  }

  /// Get all data from database
  static Future<Map<String, dynamic>> getAllData() async {
    try {
      final incomeData = await _sqlControl.getData(BackupConstants.incomesTable);
      final incomes = incomeData.map((e) => IncomeModel.fromMap(e).toMap()).toList();

      final expenseData = await _sqlControl.getData(BackupConstants.expensesTable);
      final expenses = expenseData.map((e) => ExpenseModel.fromMap(e).toMap()).toList();

      final commitmentData = await _sqlControl.getData(BackupConstants.commitmentsTable);
      final commitments = commitmentData.map((e) => CommitmentModel.fromMap(e).toMap()).toList();

      return {
        'incomes': incomes,
        'expenses': expenses,
        'commitments': commitments,
      };
    } catch (e) {
      debugPrint('Error getting data: $e');
      return {};
    }
  }

  /// Create backup data structure
  static BackupData createBackupData(Map<String, dynamic> data) {
    return BackupData.create(
      version: BackupConstants.backupVersion,
      appName: BackupConstants.appName,
      data: data,
    );
  }

  /// Restore backup data to database
  static Future<bool> restoreBackup(
    Map<String, dynamic> data, {
    bool clearExisting = false,
  }) async {
    try {
      debugPrint('Starting backup restore...');
      
      // Clear existing data if requested
      if (clearExisting) {
        await _clearAllData();
        debugPrint('Existing data cleared');
      }

      int successCount = 0;
      int errorCount = 0;

      // Import incomes
      if (data.containsKey('incomes')) {
        final result = await _importIncomes(data['incomes'] as List);
        successCount += result['success'] as int;
        errorCount += result['errors'] as int;
      }

      // Import expenses
      if (data.containsKey('expenses')) {
        final result = await _importExpenses(data['expenses'] as List);
        successCount += result['success'] as int;
        errorCount += result['errors'] as int;
      }

      // Import commitments
      if (data.containsKey('commitments')) {
        final result = await _importCommitments(data['commitments'] as List);
        successCount += result['success'] as int;
        errorCount += result['errors'] as int;
      }

      debugPrint('Import completed: $successCount success, $errorCount errors');
      return errorCount == 0;
    } catch (e) {
      debugPrint('Error restoring backup: $e');
      return false;
    }
  }

  /// Import incomes from backup data
  static Future<Map<String, int>> _importIncomes(List incomes) async {
    int successCount = 0;
    int errorCount = 0;

    for (var incomeData in incomes) {
      try {
        if (!incomeData.containsKey('amount') || !incomeData.containsKey('date')) {
          throw Exception('Missing required fields in income data');
        }
        
        final income = IncomeModel.fromMap(incomeData);
        await _sqlControl.insertData(BackupConstants.incomesTable, income.toMap());
        successCount++;
      } catch (e) {
        errorCount++;
        debugPrint('Error importing income: $e');
      }
    }

    return {'success': successCount, 'errors': errorCount};
  }

  /// Import expenses from backup data
  static Future<Map<String, int>> _importExpenses(List expenses) async {
    int successCount = 0;
    int errorCount = 0;

    for (var expenseData in expenses) {
      try {
        final expense = ExpenseModel.fromMap(expenseData);
        await _sqlControl.insertData(BackupConstants.expensesTable, expense.toMap());
        successCount++;
      } catch (e) {
        errorCount++;
        debugPrint('Error importing expense: $e');
      }
    }

    return {'success': successCount, 'errors': errorCount};
  }

  /// Import commitments from backup data
  static Future<Map<String, int>> _importCommitments(List commitments) async {
    int successCount = 0;
    int errorCount = 0;

    for (var commitmentData in commitments) {
      try {
        final commitment = CommitmentModel.fromMap(commitmentData);
        await _sqlControl.insertData(BackupConstants.commitmentsTable, commitment.toMap());
        successCount++;
      } catch (e) {
        errorCount++;
        debugPrint('Error importing commitment: $e');
      }
    }

    return {'success': successCount, 'errors': errorCount};
  }

  /// Clear all data from database
  static Future<void> _clearAllData() async {
    try {
      for (String tableName in BackupConstants.allTableNames) {
        final data = await _sqlControl.getData(tableName);
        for (var item in data) {
          await _sqlControl.deleteData(tableName, item['id']);
        }
      }
    } catch (e) {
      debugPrint('Error clearing data: $e');
    }
  }

  /// Get backup file size in MB
  static Future<double> getBackupSize() async {
    try {
      final data = await getAllData();
      final backupData = createBackupData(data);
      
      final jsonString = jsonEncode(backupData.toMap());
      final sizeInBytes = utf8.encode(jsonString).length;
      return sizeInBytes / (1024 * 1024); // Convert to MB
    } catch (e) {
      debugPrint('Error calculating backup size: $e');
      return 0.0;
    }
  }

  /// Validate JSON format
  static bool validateJsonFormat(String content) {
    return BackupConstants.isValidJsonFormat(content);
  }

  /// Count items in backup data
  static int countBackupItems(Map<String, dynamic> data) {
    int total = 0;
    total += (data['incomes'] as List?)?.length ?? 0;
    total += (data['expenses'] as List?)?.length ?? 0;
    total += (data['commitments'] as List?)?.length ?? 0;
    return total;
  }
}
