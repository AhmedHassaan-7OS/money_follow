import 'package:flutter_test/flutter_test.dart';
import 'package:money_follow/control/sqlcontrol.dart';
import 'package:money_follow/core/cubit/history/history_cubit.dart';
import 'package:sqflite/sqflite.dart';

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
  });

  test('HistoryCubit loads items from Golden Dataset sorted descending by date', () async {
    await seedGoldenDataset(sql);
    final cubit = HistoryCubit(sql: sql);
    await cubit.loadHistory();

    expect(cubit.state.isLoading, isFalse);
    expect(cubit.state.errorMessage, isNull);
    // Golden dataset has 5 expenses + 2 incomes + 2 commitments = 9 items
    expect(cubit.state.items.length, 9);

    // Verify descending sort by date
    for (int i = 0; i < cubit.state.items.length - 1; i++) {
      expect(
        cubit.state.items[i].date.isAfter(cubit.state.items[i + 1].date) ||
            cubit.state.items[i].date.isAtSameMomentAs(cubit.state.items[i + 1].date),
        isTrue,
      );
    }
  });

  test('HistoryCubit filters work correctly', () async {
    await seedGoldenDataset(sql);
    final cubit = HistoryCubit(sql: sql);
    await cubit.loadHistory();

    cubit.setFilter('All');
    expect(cubit.state.filtered.length, 9);

    cubit.setFilter('Expenses');
    expect(cubit.state.filtered.length, 5);
    expect(cubit.state.filtered.every((i) => i.type == 'Expense'), isTrue);

    cubit.setFilter('Income');
    expect(cubit.state.filtered.length, 2);
    expect(cubit.state.filtered.every((i) => i.type == 'Income'), isTrue);

    cubit.setFilter('Commitments');
    expect(cubit.state.filtered.length, 2);
    expect(cubit.state.filtered.every((i) => i.type == 'Commitment'), isTrue);
  });

  test('HistoryCubit skips row with malformed date gracefully', () async {
    // Add one valid expense and one invalid date expense
    await sql.insertData('expenses', {
      'amount': 50.0,
      'category': 'Food',
      'date': '2026-10-01',
      'note': 'valid',
    });
    await sql.insertData('expenses', {
      'amount': 25.0,
      'category': 'Food',
      'date': 'not-a-date',
      'note': 'invalid',
    });

    final cubit = HistoryCubit(sql: sql);
    await cubit.loadHistory();

    expect(cubit.state.isLoading, isFalse);
    expect(cubit.state.items.length, 1);
    expect(cubit.state.items.first.note, 'valid');
  });

  test('HistoryCubit sets errorMessage on database failure (B11)', () async {
    await seedGoldenDataset(sql);
    await db.close(); // cause error

    final cubit = HistoryCubit(sql: sql);
    await cubit.loadHistory();

    expect(cubit.state.isLoading, isFalse);
    expect(cubit.state.errorMessage, isNotNull);
    expect(cubit.state.errorMessage, contains('Failed to load history'));
  });

  test('HistoryCubit findById helpers return expected models', () async {
    await seedGoldenDataset(sql);
    final cubit = HistoryCubit(sql: sql);

    final expense = await cubit.getExpenseById('1');
    expect(expense, isNotNull);
    expect(expense!.category, 'Food');

    final income = await cubit.getIncomeById('1');
    expect(income, isNotNull);
    expect(income!.source, 'Salary');

    final commitment = await cubit.getCommitmentById('1');
    expect(commitment, isNotNull);
    expect(commitment!.title, 'Rent');

    final nonExistent = await cubit.getExpenseById('9999');
    expect(nonExistent, isNull);
  });
}
