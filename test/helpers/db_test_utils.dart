// ============================================================
// DB test utils — قاعدة SQLite حقيقية عبر sqflite_common_ffi.
// نستخدم onCreate/onUpgrade الحقيقيين من SqlControl نفسه
// عشان الـ schema والـ migration يتباختباروا بمهم.
// ============================================================

import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:money_follow/control/sqlcontrol.dart';

bool _ffiReady = false;

void ensureFfi() {
  if (_ffiReady) return;
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;
  _ffiReady = true;
}

final SqlControl _sql = SqlControl();

/// قاعدة نضيفة في الذاكرة بنفس onCreate الحقيقي، مربوطة بالـ SqlControl.
Future<Database> openGoldenDb() async {
  ensureFfi();
  final db = await openDatabase(
    inMemoryDatabasePath,
    version: 2,
    onCreate: _sql.debugOnCreate,
    onUpgrade: _sql.debugOnUpgrade,
  );
  SqlControl.setDatabaseForTest(db);
  return db;
}

/// فولدر مؤقت لملفات قواعد بيانات التستات.
Future<Directory> createTempDbDir() async =>
    await Directory.systemTemp.createTemp('moneyfollow_test');

/// مسار ملف قاعدة بيانات داخل المجلد المؤقت.
String tempDbPath(Directory dir) => p.join(dir.path, 'test.db');
