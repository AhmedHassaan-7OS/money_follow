import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class SqlControl {
  static Database? _db;

  Future<Database> get db async {
    if (_db != null) return _db!;
    _db = await intialdb();
    return _db!;
  }

  intialdb() async {
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
    Database dbClient = await db;
    return await dbClient.insert(table, data);
  }

  /// Read
  Future<List<Map<String, dynamic>>> getData(String table) async {
    Database dbClient = await db;
    return await dbClient.query(table);
  }

  /// Update
  Future<int> updateData(
    String table,
    Map<String, dynamic> data,
    int id,
    List<int?> list,
  ) async {
    Database dbClient = await db;
    return await dbClient.update(table, data, where: 'id = ?', whereArgs: [id]);
  }

  /// Delete
  Future<int> deleteData(String table, int id) async {
    Database dbClient = await db;
    return await dbClient.delete(table, where: 'id = ?', whereArgs: [id]);
  }
}
