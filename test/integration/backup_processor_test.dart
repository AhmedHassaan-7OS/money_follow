import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:money_follow/services/backup_data_processor.dart';
import 'package:money_follow/control/sqlcontrol.dart';
import 'package:money_follow/constants/backup_constants.dart';

import '../helpers/db_test_utils.dart';
import '../helpers/golden_dataset.dart';

void main() {
  group('processBackupData — validation', () {
    test('valid backup JSON passes with item counts', () async {
      final json = jsonEncode({
        'version': BackupConstants.backupVersion,
        'timestamp': '2026-10-16T12:00:00',
        'app_name': BackupConstants.appName,
        'data': {
          'incomes': [
            {'amount': 1000.0, 'source': 'Salary', 'date': '2026-10-01'},
          ],
          'expenses': [
            {'amount': 50.0, 'category': 'Food', 'date': '2026-10-01'},
            {'amount': 25.0, 'category': 'Bills', 'date': '2026-10-02'},
          ],
          'commitments': [],
        },
      });
      final result = await BackupDataProcessor.processBackupData(json);
      expect(result.success, isTrue);
      expect(result.itemCount, 3);
    });

    test('corrupt JSON rejected', () async {
      final result = await BackupDataProcessor.processBackupData('{not valid json');
      expect(result.success, isFalse);
    });

    test('JSON array (تطبيق تاني) rejected', () async {
      final result = await BackupDataProcessor.processBackupData('[1,2,3]');
      expect(result.success, isFalse);
    });

    test('wrong app name rejected', () async {
      final json = jsonEncode({
        'version': '1.0',
        'timestamp': '2026-10-16T12:00:00',
        'app_name': 'SomeOtherApp',
        'data': {'expenses': []},
      });
      final result = await BackupDataProcessor.processBackupData(json);
      expect(result.success, isFalse);
      expect(result.message, BackupConstants.wrongAppMessage);
    });

    test('missing version/timestamp/data rejected', () async {
      final json = jsonEncode({'app_name': BackupConstants.appName});
      final result = await BackupDataProcessor.processBackupData(json);
      expect(result.success, isFalse);
    });
  });

  group('export → import round trip on a real DB', () {
    test('getAllData returns exactly the Golden Dataset', () async {
      final db = await openGoldenDb();
      await seedGoldenDataset(SqlControl());

      final data = await BackupDataProcessor.getAllData();
      expect(data['incomes']!.length, 2);
      expect(data['expenses']!.length, 5);
      expect(data['commitments']!.length, 2);

      final incomes = data['incomes'] as List<Map<String, dynamic>>;
      final inc1 = incomes.firstWhere((i) => i['source'] == 'Salary');
      expect(inc1['amount'], 5000.00);

      await db.close();
    });

    test('full round trip: export → validate → clear → restore → نفس الأرقام', () async {
      var db = await openGoldenDb();
      await seedGoldenDataset(SqlControl());

      final data = await BackupDataProcessor.getAllData();
      final backupData = BackupDataProcessor.createBackupData(data);
      final json = jsonEncode(backupData.toMap());

      await db.close();
      db = await openGoldenDb(); // قاعدة نضيفة للاستيراد

      final parsed = await BackupDataProcessor.processBackupData(json);
      expect(parsed.success, isTrue);
      expect(parsed.itemCount, 9);

      final ok = await BackupDataProcessor.restoreBackup(parsed.data!, clearExisting: true);
      expect(ok, isTrue);

      final restored = await BackupDataProcessor.getAllData();
      expect(restored['incomes']!.length, 2);
      expect(restored['expenses']!.length, 5);
      expect(restored['commitments']!.length, 2);

      expect(
        (restored['expenses'] as List).map((e) => e['amount']).reduce((a, b) => a + b),
        closeTo(1399.99, 0.001),
      );
      expect(
        (restored['incomes'] as List).map((e) => e['amount']).reduce((a, b) => a + b),
        closeTo(6200.50, 0.001),
      );

      // الالتزام المكتمل رجع مكتمل
      final commitments = restored['commitments'] as List;
      final phone = commitments.firstWhere((c) => c['title'] == 'Phone');
      expect(phone['isCompleted'], 1);

      await db.close();
    });

    test('B2: JSON بـ amount صحيح (int) لازم يتستورد مش ينفجر', () async {
      final db = await openGoldenDb();
      final json = jsonEncode({
        'version': BackupConstants.backupVersion,
        'timestamp': '2026-10-16T12:00:00',
        'app_name': BackupConstants.appName,
        'data': {
          'expenses': [
            {'amount': 100, 'category': 'Food', 'date': '2026-10-01'}, // int!
          ],
        },
      });
      final parsed = await BackupDataProcessor.processBackupData(json);
      expect(parsed.success, isTrue);

      final ok = await BackupDataProcessor.restoreBackup(parsed.data!);
      expect(ok, isTrue, reason: 'B2: int amount لازم يعدي');

      final rows = await SqlControl().getData('expenses');
      expect(rows.length, 1, reason: 'B2: السجلة لازم تتنقل كاملة');
      expect(rows.first['amount'], 100.0);
      await db.close();
    });

    test('B3: restore بدون clear مع ids موجودة مسبقاً', () async {
      final db = await openGoldenDb();
      await SqlControl().insertData('expenses',
          {'id': 1, 'amount': 10.0, 'category': 'Food', 'date': '2026-10-10'});

      final json = jsonEncode({
        'version': BackupConstants.backupVersion,
        'timestamp': '2026-10-16T12:00:00',
        'app_name': BackupConstants.appName,
        'data': {
          'expenses': [
            {'id': 2, 'amount': 20.0, 'category': 'Bills', 'date': '2026-10-01'},
            {'id': 3, 'amount': 30.0, 'category': 'Bills', 'date': '2026-10-02'},
          ],
        },
      });
      final parsed = await BackupDataProcessor.processBackupData(json);
      expect(parsed.success, isTrue);

      final ok = await BackupDataProcessor.restoreBackup(parsed.data!, clearExisting: false);
      expect(ok, isTrue, reason: 'B3: restore جزئي/فاشل حالياً بسبب id conflict');

      final rows = await SqlControl().getData('expenses');
      expect(rows.length, 3, reason: 'B3: المطلوب 3 سجلات (الجديدة + الموجودة)');
      await db.close();
    });

    test('باسدة داخل النسخة => restore جزئي (سجل الخطا محفوظ)', () async {
      final db = await openGoldenDb();
      final json = jsonEncode({
        'version': BackupConstants.backupVersion,
        'timestamp': '2026-10-16T12:00:00',
        'app_name': BackupConstants.appName,
        'data': {
          'expenses': [
            {'amount': 10.0, 'category': 'Food', 'date': '2026-10-01'},
            {'amount': 'خطأ', 'category': 'Food', 'date': '2026-10-02'}, // فاسد
          ],
        },
      });
      final parsed = await BackupDataProcessor.processBackupData(json);
      final ok = await BackupDataProcessor.restoreBackup(parsed.data!);
      expect(ok, isFalse, reason: 'سجل واحد فاسد يخلي الباك أب false');
      final rows = await SqlControl().getData('expenses');
      expect(rows.length, 1, reason:
          'سلوك حالي موثّق: السجل السليم بيتستورد والفاسد بيتعدّى (restore جزئي بدون transaction)');
      await db.close();
    });
  });
}
