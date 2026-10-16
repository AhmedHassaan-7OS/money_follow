import 'dart:convert';
import 'package:money_follow/utils/isolate_json.dart';
import 'package:money_follow/control/sqlcontrol.dart';
import 'package:money_follow/models/expense_model.dart';
import 'package:money_follow/models/income_model.dart';
import 'package:money_follow/models/commitment_model.dart';
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
      // Decode + parse on a background isolate to keep the UI thread free.
      final Map<String, dynamic> backupMap = await decodeJsonMapInBackground(
        jsonString,
      );
      final backupData = BackupData.fromMap(backupMap);

      // Validate backup format
      if (!backupData.isValid) {
        return BackupImportResult.failure(
          BackupConstants.invalidBackupFormatMessage,
        );
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
      return BackupImportResult.failure(
        'خطأ في قراءة ملف النسخة الاحتياطية: $e',
      );
    }
  }

  /// Get all data from database
  static Future<Map<String, dynamic>> getAllData() async {
    try {
      final incomeData = await _sqlControl.getData(
        BackupConstants.incomesTable,
      );
      final incomes = incomeData
          .map((e) => IncomeModel.fromMap(e).toMap())
          .toList();

      final expenseData = await _sqlControl.getData(
        BackupConstants.expensesTable,
      );
      final expenses = expenseData
          .map((e) => ExpenseModel.fromMap(e).toMap())
          .toList();

      final commitmentData = await _sqlControl.getData(
        BackupConstants.commitmentsTable,
      );
      final commitments = commitmentData
          .map((e) => CommitmentModel.fromMap(e).toMap())
          .toList();

      return {
        'incomes': incomes,
        'expenses': expenses,
        'commitments': commitments,
      };
    } catch (_) {
      rethrow;
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

  /// Restore backup data to database atomically inside a transaction (B3 fix)
  static Future<bool> restoreBackup(
    Map<String, dynamic> data, {
    bool clearExisting = false,
  }) async {
    try {
      await _sqlControl.transaction((_) async {
        // Clear existing data if requested
        if (clearExisting) {
          await _clearAllData();
        }

        int errorCount = 0;

        // Import incomes
        if (data.containsKey('incomes')) {
          final result = await _importIncomes(
            data['incomes'] as List,
            clearExisting: clearExisting,
          );
          errorCount += result['errors'] as int;
        }

        // Import expenses
        if (data.containsKey('expenses')) {
          final result = await _importExpenses(
            data['expenses'] as List,
            clearExisting: clearExisting,
          );
          errorCount += result['errors'] as int;
        }

        // Import commitments
        if (data.containsKey('commitments')) {
          final result = await _importCommitments(
            data['commitments'] as List,
            clearExisting: clearExisting,
          );
          errorCount += result['errors'] as int;
        }

        if (errorCount > 0) {
          throw StateError(
            'Backup restore encountered $errorCount invalid records; rolling back transaction.',
          );
        }
      });

      return true;
    } catch (_) {
      return false;
    }
  }

  /// Import incomes from backup data
  static Future<Map<String, int>> _importIncomes(
    List incomes, {
    bool clearExisting = false,
  }) async {
    int successCount = 0;
    int errorCount = 0;

    final existingKeys = <String>{};
    if (!clearExisting) {
      final existingRows = await _sqlControl.getData(BackupConstants.incomesTable);
      for (var row in existingRows) {
        final amt = (row['amount'] as num?)?.toDouble() ?? 0.0;
        existingKeys.add('${amt}_${row['source']}_${row['date']}');
      }
    }

    for (var incomeData in incomes) {
      try {
        if (!incomeData.containsKey('amount') ||
            !incomeData.containsKey('date')) {
          throw Exception('Missing required fields in income data');
        }

        final income = IncomeModel.fromMap(incomeData);
        final map = income.toMap();
        if (!clearExisting) {
          map.remove('id');
          final key = '${income.amount}_${income.source}_${income.date}';
          if (existingKeys.contains(key)) {
            continue;
          }
          existingKeys.add(key);
        }
        await _sqlControl.insertData(
          BackupConstants.incomesTable,
          map,
        );
        successCount++;
      } catch (_) {
        errorCount++;
      }
    }

    return {'success': successCount, 'errors': errorCount};
  }

  /// Import expenses from backup data
  static Future<Map<String, int>> _importExpenses(
    List expenses, {
    bool clearExisting = false,
  }) async {
    int successCount = 0;
    int errorCount = 0;

    final existingKeys = <String>{};
    if (!clearExisting) {
      final existingRows = await _sqlControl.getData(BackupConstants.expensesTable);
      for (var row in existingRows) {
        final amt = (row['amount'] as num?)?.toDouble() ?? 0.0;
        existingKeys.add('${amt}_${row['category']}_${row['date']}_${row['note'] ?? ''}');
      }
    }

    for (var expenseData in expenses) {
      try {
        final expense = ExpenseModel.fromMap(expenseData);
        final map = expense.toMap();
        if (!clearExisting) {
          map.remove('id');
          final key = '${expense.amount}_${expense.category}_${expense.date}_${expense.note ?? ''}';
          if (existingKeys.contains(key)) {
            continue;
          }
          existingKeys.add(key);
        }
        await _sqlControl.insertData(
          BackupConstants.expensesTable,
          map,
        );
        successCount++;
      } catch (_) {
        errorCount++;
      }
    }

    return {'success': successCount, 'errors': errorCount};
  }

  /// Import commitments from backup data
  static Future<Map<String, int>> _importCommitments(
    List commitments, {
    bool clearExisting = false,
  }) async {
    int successCount = 0;
    int errorCount = 0;

    final existingKeys = <String>{};
    if (!clearExisting) {
      final existingRows = await _sqlControl.getData(BackupConstants.commitmentsTable);
      for (var row in existingRows) {
        final amt = (row['amount'] as num?)?.toDouble() ?? 0.0;
        existingKeys.add('${row['title']}_${amt}_${row['dueDate']}');
      }
    }

    for (var commitmentData in commitments) {
      try {
        final commitment = CommitmentModel.fromMap(commitmentData);
        final map = commitment.toMap();
        if (!clearExisting) {
          map.remove('id');
          final key = '${commitment.title}_${commitment.amount}_${commitment.dueDate}';
          if (existingKeys.contains(key)) {
            continue;
          }
          existingKeys.add(key);
        }
        await _sqlControl.insertData(
          BackupConstants.commitmentsTable,
          map,
        );
        successCount++;
      } catch (_) {
        errorCount++;
      }
    }

    return {'success': successCount, 'errors': errorCount};
  }

  /// Clear all data from database (rethrows on error so transaction rolls back)
  static Future<void> _clearAllData() async {
    for (String tableName in BackupConstants.allTableNames) {
      await _sqlControl.clearTable(tableName);
    }
  }

  /// Get backup file size in MB
  static Future<double> getBackupSize() async {
    final data = await getAllData();
    final backupData = createBackupData(data);

    // Encode on a background isolate; the payload can be large.
    final jsonString = await encodeJsonInBackground(backupData.toMap());
    final sizeInBytes = utf8.encode(jsonString).length;
    return sizeInBytes / (1024 * 1024); // Convert to MB
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
