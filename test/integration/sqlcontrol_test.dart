import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite/sqflite.dart' show openDatabase;
import 'package:money_follow/control/sqlcontrol.dart';

import '../helpers/db_test_utils.dart';

void main() {
  setUp(() async {});

  group('SqlControl schema + CRUD (onCreate الحقيقي)', () {
    test('schema created and CRUD works for all tables', () async {
      final db = await openGoldenDb();
      final sql = SqlControl();

      final e1 = await sql.insertData('expenses', {
        'amount': 99.99, 'category': 'Food', 'date': '2026-10-16', 'note': null,
      });
      final e2 = await sql.insertData('expenses', {
        'amount': 15.00, 'category': 'Transport', 'date': '2026-10-15',
      });
      expect(e1, isNonZero);
      expect(e2, e1 + 1); // AUTOINCREMENT متسلسل

      final i1 = await sql.insertData('incomes',
          {'amount': 5000.00, 'source': 'Salary', 'date': '2026-10-01'});
      final c1 = await sql.insertData('commitments', {
        'title': 'Rent', 'amount': 2000.00, 'dueDate': '2026-10-25',
      });

      final expenses = await sql.getData('expenses');
      expect(expenses.length, 2);
      expect(expenses.first['amount'], 99.99);

      final incomes = await sql.getData('incomes');
      expect(incomes.length, 1);
      expect(i1, incomes.first['id']);

      final commitments = await sql.getData('commitments');
      expect(commitments.length, 1);
      expect(c1, commitments.first['id']);
      expect(commitments.first['isCompleted'], 0); // DEFAULT 0

      await db.close();
    });

    test('update existing row + update/delete on missing id => 0 rows', () async {
      final db = await openGoldenDb();
      final sql = SqlControl();

      final id = await sql.insertData('expenses', {'amount': 20.0, 'category': 'Food', 'date': '2026-10-16'});
      var updated = await sql.updateData(
          'expenses', {'amount': 25.0}, id);
      expect(updated, 1);
      final rows = await sql.getData('expenses');
      expect(rows.first['amount'], 25.0);

      updated = await sql.updateData('expenses', {'amount': 1.0}, 9999);
      expect(updated, 0);
      final deleted = await sql.deleteData('expenses', 9999);
      expect(deleted, 0);

      await db.close();
    });

    test('AUTOINCREMENT never reuses ids after delete', () async {
      final db = await openGoldenDb();
      final sql = SqlControl();

      final a = await sql.insertData('expenses', {'amount': 5.0, 'category': 'Food', 'date': '2026-10-16'});
      await sql.deleteData('expenses', a);
      final b = await sql.insertData('expenses', {'amount': 6.0, 'category': 'Food', 'date': '2026-10-16'});
      expect(b, a + 1);

      await db.close();
    });

    test('parallel inserts are safe (race على _openingDb)', () async {
      final db = await openGoldenDb();
      final sql = SqlControl();

      final futures = List.generate(20, (i) =>
          sql.insertData('expenses', {'amount': i + 1.0, 'category': 'Food', 'date': '2026-10-16'}));
      final ids = await Future.wait(futures);
      expect(ids.toSet().length, 20); // كل id فريد

      final rows = await sql.getData('expenses');
      expect(rows.length, 20);

      await db.close();
    });
  });

  group('migration v1 → v2 (isCompleted column)', () {
    test('old data preserved and isCompleted defaults to 0', () async {
      ensureFfi();
      final dir = await createTempDbDir();
      final path = tempDbPath(dir);
      final sql = SqlControl();

      // إنشاء قاعدة v1 (بدون عمود isCompleted)
      final v1db = await openDatabase(path, version: 1, onCreate: (db, v) async {
        await db.execute('CREATE TABLE expenses (id INTEGER PRIMARY KEY AUTOINCREMENT, amount REAL, category TEXT, date TEXT, note TEXT)');
        await db.execute('CREATE TABLE incomes (id INTEGER PRIMARY KEY AUTOINCREMENT, amount REAL, source TEXT, date TEXT)');
        await db.execute('CREATE TABLE commitments (id INTEGER PRIMARY KEY AUTOINCREMENT, title TEXT, amount REAL, dueDate TEXT)');
      });
      await v1db.insert('commitments', {'title': 'OldRent', 'amount': 1500.0, 'dueDate': '2025-12-01'});
      await v1db.close();

      // فتح بنفس الـ onUpgrade الحقيقي
      final upgraded = await openDatabase(
        path, version: 2,
        onCreate: sql.debugOnCreate, onUpgrade: sql.debugOnUpgrade,
      );
      final rows = await upgraded.query('commitments');
      expect(rows.length, 1);
      expect(rows.first['title'], 'OldRent');
      expect(rows.first['amount'], 1500.0);
      expect(rows.first['dueDate'], '2025-12-01');
      expect(rows.first['isCompleted'], 0); // المحدثة = false

      // الجدول المحوّل يقبل inserting isCompleted
      await upgraded.insert('commitments', {
        'title': 'Phone', 'amount': 150.0, 'dueDate': '2026-10-01', 'isCompleted': 1,
      });
      final after = await upgraded.query('commitments');
      expect(after.length, 2);
      await upgraded.close();
      await dir.delete(recursive: true);
    });
  });

  group('getTotalAmountForDateRange', () {
    test('empty table => 0.0', () async {
      final db = await openGoldenDb();
      final total = await (SqlControl()).getTotalAmountForDateRange('expenses', '2026-10-01', '2026-10-16');
      expect(total, 0.0);
      await db.close();
    });

    test('both endpoints inclusive', () async {
      final db = await openGoldenDb();
      final sql = SqlControl();
      await sql.insertData('expenses', {'amount': 50.0, 'category': 'Food', 'date': '2026-10-01'});
      await sql.insertData('expenses', {'amount': 70.0, 'category': 'Food', 'date': '2026-10-16'});
      final total = await sql.getTotalAmountForDateRange('expenses', '2026-10-01', '2026-10-16');
      expect(total, 120.0);
      await db.close();
    });

    test('B6: dates stored with time (T) are NOT counted — البيج', () async {
      // planner दا B6: لو في وقت مخزن، المقارنة النصية بتحوله خارج المدى
      final db = await openGoldenDb();
      final sql = SqlControl();
      // عايزينهم داخل المدى (إصلاح B6)؛
      await sql.insertData('expenses', {'amount': 100.0, 'category': 'Food', 'date': '2026-10-16T10:00'});
      await sql.insertData('expenses', {'amount': 40.0, 'category': 'Food', 'date': '2026-10-16T23:59'});
      final total = await sql.getTotalAmountForDateRange('expenses', '2026-10-16', '2026-10-16');
      expect(total, 140.0, reason: 'B6: التواريخ المخزنة بوقت (T) بتطلع خارج المدى بمقارنة النصوص');
      await db.close();
    });
  });

  group('getDailySummaries', () {
    test('groups same-day records and defaults missing side to 0', () async {
      final db = await openGoldenDb();
      final sql = SqlControl();
      await sql.insertData('expenses', {'amount': 30.0, 'category': 'Food', 'date': '2026-10-16'});
      await sql.insertData('expenses', {'amount': 70.0, 'category': 'Food', 'date': '2026-10-16'});
      await sql.insertData('incomes', {'amount': 5000.0, 'source': 'Salary', 'date': '2026-10-01'});

      final summaries = await sql.getDailySummaries();
      expect(summaries.length, 2);
      expect(summaries['2026-10-16']!['expense'], 100.0);
      expect(summaries['2026-10-16']!['income'], 0);
      expect(summaries['2026-10-01']!['income'], 5000.0);
      expect(summaries['2026-10-01']!['expense'], 0);
      await db.close();
    });

    test('dates stored with time split on T', () async {
      final db = await openGoldenDb();
      final sql = SqlControl();
      await sql.insertData('expenses', {'amount': 10.0, 'category': 'Food', 'date': '2026-10-16T07:30'});
      await sql.insertData('expenses', {'amount': 20.0, 'category': 'Food', 'date': '2026-10-16T09:45'});
      final summaries = await sql.getDailySummaries();
      expect(summaries.containsKey('2026-10-16'), isTrue);
      expect(summaries['2026-10-16']!['expense'], 30.0, reason:
          'bug مكشوف: نفس اليوم بصيغتين (بوقت) بيتجمّعوا غلط — آخر قيمة بتطغى بدل ما تتجمع');
      await db.close();
    });
  });
}
