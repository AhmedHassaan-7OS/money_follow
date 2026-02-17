import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class SqlControl {
  static Database? _db;

  Future<Database> get db async {
    if (_db != null) return _db!;
    _db = await initialDb();
    return _db!;
  }

  initialDb() async {
    String databasepath = await getDatabasesPath();
    String path = join(databasepath, 'moneyfollow.db');

    Database database = await openDatabase(
      path,
      version: 2,
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
    } catch (e) {
      print('Error inserting data into $table: $e');
      rethrow;
    }
  }

  /// Read
  Future<List<Map<String, dynamic>>> getData(String table) async {
    try {
      Database dbClient = await db;
      return await dbClient.query(table);
    } catch (e) {
      print('Error reading data from $table: $e');
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
    } catch (e) {
      print('Error updating data in $table: $e');
      rethrow;
    }
  }

  /// Delete
  Future<int> deleteData(String table, int id) async {
    try {
      Database dbClient = await db;
      return await dbClient.delete(table, where: 'id = ?', whereArgs: [id]);
    } catch (e) {
      print('Error deleting data from $table: $e');
      rethrow;
    }
  }

  // Get total amount for a specific date range
  Future<double> getTotalAmountForDateRange(String table, String startDate, String endDate) async {
    try {
      Database dbClient = await db;
      final result = await dbClient.rawQuery('''
        SELECT SUM(amount) as total
        FROM $table
        WHERE date >= ? AND date <= ?
      ''', [startDate, endDate]);

      if (result.isNotEmpty && result.first['total'] != null) {
        return result.first['total'] as double;
      }
      return 0.0;
    } catch (e) {
      print('Error getting total amount for $table: $e');
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
        final total = row['total'] as double;
        summaries.putIfAbsent(date, () => {'expense': 0, 'income': 0});
        summaries[date]!['expense'] = total;
      }

      for (var row in incomesResult) {
        final date = (row['date'] as String).split('T').first;
        final total = row['total'] as double;
        summaries.putIfAbsent(date, () => {'expense': 0, 'income': 0});
        summaries[date]!['income'] = total;
      }

      return summaries;
    } catch (e) {
      print('Error getting daily summaries: $e');
      return {};
    }
  }
}
