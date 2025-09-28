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
      version: 1,
      onCreate: _onCreate,
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
        dueDate TEXT
      )
    ''');
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
}
