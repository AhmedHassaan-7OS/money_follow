import 'package:flutter/material.dart' show visibleForTesting;
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class SqlControl {
  static Database? _db;
  static Future<Database>? _openingDb;

  /// Test-only override: lets sqflite_common_ffi tests inject an
  /// in-memory database and get a clean DB per test.
  /// Test-only override: lets sqflite_common_ffi tests inject an
  /// in-memory database and get a clean DB per test.
  ///
  // ignore: invalid_visibility_annotation
  @visibleForTesting
  static Database? _injectedDb;

  @visibleForTesting
  static void setDatabaseForTest(Database? database) {
    _injectedDb = database;
    _db = null;
    _openingDb = null;
  }

  @visibleForTesting
  static Future<void> resetForTest() async {
    setDatabaseForTest(null);
  }

  @visibleForTesting
  Future<void> debugOnCreate(Database db, int version) => _onCreate(db, version);

  @visibleForTesting
  Future<void> debugOnUpgrade(Database db, int oldVersion, int newVersion) =>
      _onUpgrade(db, oldVersion, newVersion);

  Future<Database> get db async {
    if (_injectedDb != null) return _injectedDb!;
    if (_db != null) return _db!;
    _openingDb ??= initialDb();
    try {
      _db = await _openingDb!;
    } finally {
      _openingDb = null;
    }
    return _db!;
  }

  Future<Database> initialDb() async {
    String databasepath = await getDatabasesPath();
    String path = join(databasepath, 'moneyfollow.db');

    Database database = await openDatabase(
      path,
      version: 2,
      onConfigure: (db) async {
        await db.rawQuery('PRAGMA busy_timeout = 3000');
      },
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );

    return database;
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE expenses (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        amount REAL,
        category TEXT,
        date TEXT,
        note TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE incomes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        amount REAL,
        source TEXT,
        date TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE commitments (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT,
        amount REAL,
        dueDate TEXT,
        isCompleted INTEGER DEFAULT 0
      )
    ''');
  }

  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Add isCompleted column to existing commitments table
      await db.execute('''
        ALTER TABLE commitments ADD COLUMN isCompleted INTEGER DEFAULT 0
      ''');
    }
  }

  /// Insert
  Future<int> insertData(String table, Map<String, dynamic> data) async {
    try {
      Database dbClient = await db;
      return await dbClient.insert(table, data);
    } catch (_) {
      rethrow;
    }
  }

  /// Read
  Future<List<Map<String, dynamic>>> getData(String table) async {
    try {
      Database dbClient = await db;
      return await dbClient.query(table);
    } catch (_) {
      rethrow;
    }
  }

  /// Update
  Future<int> updateData(
    String table,
    Map<String, dynamic> data,
    int id,
  ) async {
    try {
      Database dbClient = await db;
      return await dbClient.update(table, data, where: 'id = ?', whereArgs: [id]);
    } catch (_) {
      rethrow;
    }
  }

  /// Delete
  Future<int> deleteData(String table, int id) async {
    try {
      Database dbClient = await db;
      return await dbClient.delete(table, where: 'id = ?', whereArgs: [id]);
    } catch (_) {
      rethrow;
    }
  }

  // Get total amount for a specific date range.
  // B6 fix: المدى نص مفتوح [startDate, endDate + 1 يوم) — النفس مقارنة يدف
  // بيشمل تواريخ فيها وقت (2026-10-16T23:59) وبيستبعد 2026-10-17،
  // وبيحافظ على إمكانية استفادة الـ index.
  // endDate لازم بصيغة yyyy-MM-dd (أو yyyy-MM-ddTHH:mm — بنزبطها هنا).
  Future<double> getTotalAmountForDateRange(String table, String startDate, String endDate) async {
    try {
      // نطبيء الحد الأعلى: ناخد أول 10 حروف (yyyy-MM-dd) ونزوّد يوم واحد.
      final endDay = endDate.length > 10 ? endDate.substring(0, 10) : endDate;
      final endDateExclusive = DateTime.parse('$endDay' 'T00:00').add(const Duration(days: 1));
      final endDateNext = endDateExclusive.toIso8601String().substring(0, 10);
      Database dbClient = await db;
      final result = await dbClient.rawQuery('''
        SELECT SUM(amount) as total
        FROM $table
        WHERE date >= ? AND date < ?
      ''', [startDate, endDateNext]);

      if (result.isNotEmpty && result.first['total'] != null) {
        return (result.first['total'] as num).toDouble();
      }
      return 0.0;
    } catch (_) {
      return 0.0;
    }
  }

  // Get daily summaries for all transaction days
  Future<Map<String, Map<String, double>>> getDailySummaries() async {
    try {
      Database dbClient = await db;

      final expensesResult = await dbClient.rawQuery('''
        SELECT date, SUM(amount) as total
        FROM expenses
        GROUP BY date
      ''');

      final incomesResult = await dbClient.rawQuery('''
        SELECT date, SUM(amount) as total
        FROM incomes
        GROUP BY date
      ''');

      Map<String, Map<String, double>> summaries = {};

      for (var row in expensesResult) {
        final date = (row['date'] as String).split('T').first;
        final total = (row['total'] as num).toDouble();
        summaries.putIfAbsent(date, () => {'expense': 0, 'income': 0});
        // Bug fix (فرع B6): نفس اليوم ممكن يطلع من صيغتين (بوقت ومن غير) —
        // ناجمع += بدل overwrite اللي كان بيضيع قيمة.
        summaries[date]!['expense'] = (summaries[date]!['expense'] ?? 0) + total;
      }

      for (var row in incomesResult) {
        final date = (row['date'] as String).split('T').first;
        final total = (row['total'] as num).toDouble();
        summaries.putIfAbsent(date, () => {'expense': 0, 'income': 0});
        summaries[date]!['income'] = (summaries[date]!['income'] ?? 0) + total;
      }

      return summaries;
    } catch (_) {
      return {};
    }
  }
}
