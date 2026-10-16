import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite/sqflite.dart';
import 'package:money_follow/control/sqlcontrol.dart';
import 'package:money_follow/core/cubit/home/home_cubit.dart';
import 'package:money_follow/core/cubit/statistics/statistics_cubit.dart';
import 'package:money_follow/core/cubit/statistics/statistics_state.dart';

import '../helpers/db_test_utils.dart';
import '../helpers/golden_dataset.dart';

void main() {
  late Database db;
  late SqlControl sql;

  setUp(() async {
    db = await openGoldenDb();
    sql = SqlControl();
  });

  tearDown(() async {
    await db.close();
    await SqlControl.resetForTest();
  });

  group('HomeCubit — الحسابات الأساسية', () {
    test('الرصيد على Golden Dataset = 4800.51', () async {
      await seedGoldenDataset(sql);
      final cubit = HomeCubit(sql: sql, now: fixedClock())..loadData();
      await Future<void>.delayed(const Duration(milliseconds: 50));
      expect(cubit.state.totalBalance, closeTo(4800.51, 0.001));
      expect(cubit.state.isLoading, isFalse);
    });

    test('قاعدة فاضية => رصيد 0 و صفر مصروفات شهرية', () async {
      final cubit = HomeCubit(sql: sql, now: fixedClock())..loadData();
      await Future<void>.delayed(const Duration(milliseconds: 50));
      expect(cubit.state.totalBalance, 0.0);
      expect(cubit.state.monthlyExpenses, 0.0);
      expect(cubit.state.expenses, isEmpty);
      expect(cubit.state.commitments, isEmpty);
    });

    test('رصيد سالب في مصاريف اكتر من دخل', () async {
      await sql.insertData('incomes', {'amount': 1000.0, 'source': 'Gift', 'date': '2026-10-01'});
      await sql.insertData('expenses', {'amount': 1500.0, 'category': 'Bills', 'date': '2026-10-05'});
      final cubit = HomeCubit(sql: sql, now: fixedClock())..loadData();
      await Future<void>.delayed(const Duration(milliseconds: 50));
      expect(cubit.state.totalBalance, -500.0);
    });

    test('B4: Home monthlyExpenses بتحسب كامل الشهر (بما فيه المستقبلي) = 1300', () async {
      // حسب الخطة §3: كارت الشهر في Home بيحسب كل الشهر (300 Shopping بـ 10-20 داخل)
      await seedGoldenDataset(sql);
      final cubit = HomeCubit(sql: sql, now: fixedClock())..loadData();
      await Future<void>.delayed(const Duration(milliseconds: 50));
      expect(cubit.state.monthlyExpenses, closeTo(1300.00, 0.001));
    });

    test('عند خطأ قاعدة بيانات بيبلع الخطأ بلا رسالة (B11)', () async {
      await seedGoldenDataset(sql);
      await db.close(); // DB error source
      final cubit = HomeCubit(sql: sql, now: fixedClock())..loadData();
      await Future<void>.delayed(const Duration(milliseconds: 50));
      expect(cubit.state.isLoading, isFalse);
      // B11: الخطا مضبوط، لا رسالة لا حالة error — شاشة فاضية
      expect(cubit.state.totalBalance, 0.0);
    });
  });

  group('HomeCubit — getExpensesByCategory', () {
    late HomeCubit cubit;

    setUp(() async {
      await seedGoldenDataset(sql);
      cubit = HomeCubit(sql: sql, now: fixedClock())..loadData();
      await Future<void>.delayed(const Duration(milliseconds: 50));
    });

    test('Month (تلقائي): كل الشهر بالمستقبل = 1300', () {
      final map = cubit.getExpensesByCategory();
      expect(map['Food'], closeTo(150.25, 0.001));
      expect(map['Transport'], closeTo(49.75, 0.001));
      expect(map['Bills'], closeTo(800.00, 0.001));
      expect(map['Shopping'], closeTo(300.00, 0.001));
    });

    test('Year: نفسه + Food = 250.24 (يوصل 99.99 من سبتمبر)', () {
      cubit.setChartTimeFilter('Year');
      final map = cubit.getExpensesByCategory();
      expect(map['Food'], closeTo(150.25 + 99.99, 0.001));
      expect(map['Transport'], closeTo(49.75, 0.001));
      expect(map['Bills'], closeTo(800.00, 0.001));
      expect(map['Shopping'], closeTo(300.00, 0.001));
    });

    test('All: Food 250.24، Transport 49.75، Bills 800، Shopping 300', () {
      cubit.setChartTimeFilter('All');
      final map = cubit.getExpensesByCategory();
      expect(map['Food'], closeTo(250.24, 0.001));
      expect(map.length, 4);
    });

    test('Week (آخر 7 أيام): تواريخ مستقبلية بتندخل (مشكلة B5)', () {
      cubit.setChartTimeFilter('Week');
      final map = cubit.getExpensesByCategory();
      expect(map['Food'], closeTo(150.25, 0.001));
      expect(map['Transport'], closeTo(49.75, 0.001));
      expect(map['Shopping'], closeTo(300.00, 0.001),
          reason:
              'B5: فلتر Week في Home بيدخل تواريخ مستقبلية (بعد اليوم) لأنه مقارنة isAfter بس من غير حد أعلى');
    });
  });

  group('HomeCubit — فلاتر إضافية', () {
    late HomeCubit cubit;

    setUp(() async {
      await seedGoldenDataset(sql);
      cubit = HomeCubit(sql: sql, now: fixedClock())..loadData();
      await Future<void>.delayed(const Duration(milliseconds: 50));
    });

    test('Custom (حدود شاملة): 10-01 → 10-16 = 1000 ويستبعد 9-30 والمستقبلي', () {
      cubit.setCustomDateRange(DateTime(2026, 10, 1), DateTime(2026, 10, 16));
      final map = cubit.getExpensesByCategory();
      expect(map['Bills'], closeTo(800.00, 0.001));
      expect(map['Food'], closeTo(150.25, 0.001));
      expect(map['Transport'], closeTo(49.75, 0.001));
      expect(map['Shopping'], isNull, reason: 'مستقبلي خارج المدى');
      final total = map.values.fold(0.0, (s, v) => s + v);
      expect(total, closeTo(1000.00, 0.001));
    });

    test('Custom بدون تواريخ => كل حاجة (1399.99)', () {
      cubit.setCustomDateRange(null, null);
      final map = cubit.getExpensesByCategory();
      final total = map.values.fold(0.0, (s, v) => s + v);
      expect(total, closeTo(1399.99, 0.001));
    });

    test('فلتر الفئة Food بين كل الفلاتر', () {
      cubit.setFilterCategory('Food');
      final map = cubit.getExpensesByCategory();
      expect(map.length, 1);
      expect(map['Food'], closeTo(150.25, 0.001));
    });

    test("فلتر 'All' للفئة بيرجع كل الفئات", () {
      cubit.setFilterCategory('All');
      final map = cubit.getExpensesByCategory();
      expect(map.length, 4);
    });

    test('toggleChartType: Pie → Bar → Pie', () {
      expect(cubit.state.chartType, 'Pie');
      cubit.toggleChartType();
      expect(cubit.state.chartType, 'Bar');
      cubit.toggleChartType();
      expect(cubit.state.chartType, 'Pie');
    });
  });

  group('StatisticsCubit (أسبوع تقويمي — B5)', () {
    test('اليوم/الأسبوع/الشهر على Golden Dataset + مقارنة B4', () async {
      await seedGoldenDataset(sql);
      final cubit = StatisticsCubit(sql: sql, now: fixedClock());
      await cubit.loadStatistics();

      expect(cubit.state, isA<StatisticsLoaded>());
      final loaded = cubit.state as StatisticsLoaded;
      expect(loaded.totalSpentToday, closeTo(200.00, 0.001));
      expect(loaded.totalSpentThisWeek, closeTo(200.00, 0.001),
          reason: 'أسبوع تقويمي من الاتنين 12-10 — نفس قيمة اليوم لأن 12→16 فيه 16 بس');
      expect(loaded.totalSpentThisMonth, closeTo(1000.00, 0.001));

      // B4: نفس الشهر بيرجع رقمين مختلفين في المكانين
      final home = HomeCubit(sql: sql, now: fixedClock())..loadData();
      await Future<void>.delayed(const Duration(milliseconds: 50));
      expect(home.state.monthlyExpenses, isNot(closeTo(loaded.totalSpentThisMonth, 0.5)),
          reason: 'B4: Home 1300 مقابل Statistics 1000 لنفس الشهر');
    });

    test('أول يوم في الشهر: اليوم = الأسبوع = الشهر = نفس القيمة', () async {
      await sql.insertData('expenses', {'amount': 42.50, 'category': 'Food', 'date': '2026-10-01'});
      final cubit = StatisticsCubit(sql: sql, now: () => DateTime(2026, 10, 1, 12));
      await cubit.loadStatistics();
      final loaded = cubit.state as StatisticsLoaded;
      expect(loaded.totalSpentToday, closeTo(42.50, 0.001));
      expect(loaded.totalSpentThisWeek, closeTo(42.50, 0.001));
      expect(loaded.totalSpentThisMonth, closeTo(42.50, 0.001));
    });

    test('خطأ في القاعدة => StatisticsError مش صمت', () async {
      await db.close();
      final cubit = StatisticsCubit(sql: sql, now: fixedClock());
      await cubit.loadStatistics();
      expect(cubit.state, isA<StatisticsError>());
    });
  });

  group('ثوابت لازم تتحقق دايماً (§4.5)', () {
    test('إضافة سجل ثم حذفه = الرصيد الأصلي', () async {
      await seedGoldenDataset(sql);
      final cubit = HomeCubit(sql: sql, now: fixedClock())..loadData();
      await Future<void>.delayed(const Duration(milliseconds: 50));
      final before = cubit.state.totalBalance;

      final id = await sql.insertData(
          'expenses', {'amount': 77.77, 'category': 'Food', 'date': '2026-10-16'});
      await sql.deleteData('expenses', id);

      final after = HomeCubit(sql: sql, now: fixedClock())..loadData();
      await Future<void>.delayed(const Duration(milliseconds: 50));
      expect(after.state.totalBalance, closeTo(before, 0.0001));
    });

    test('عشر عمليات متبادلة: الرصيد = مجموع الدخل − مجموع المصروف', () async {
      double incTotal = 0.0, expTotal = 0.0;
      for (var i = 0; i < 10; i++) {
        if (i.isEven) {
          final a = (i + 1) * 10.25;
          incTotal += a;
          await sql.insertData(
              'incomes', {'amount': a, 'source': 'S$i', 'date': '2026-10-1${i % 10}'});
        } else {
          final a = (i + 1) * 5.5;
          expTotal += a;
          await sql.insertData(
              'expenses', {'amount': a, 'category': 'Food', 'date': '2026-10-1${i % 10}'});
        }
      }
      final cubit = HomeCubit(sql: sql, now: fixedClock())..loadData();
      await Future<void>.delayed(const Duration(milliseconds: 50));
      expect(cubit.state.totalBalance, closeTo(incTotal - expTotal, 0.005));
    });
  });
}
