import 'package:flutter_test/flutter_test.dart';
import 'package:money_follow/models/expense_model.dart';
import 'package:money_follow/models/income_model.dart';
import 'package:money_follow/models/commitment_model.dart';

void main() {
  group('ExpenseModel', () {
    test('B2: fromMap accepts integer amount (Common JSON wallets)', () {
      // باك أب قديم ممكن يكون فيه "amount": 100 (int) مش 100.0
      // لازم من non-Map ينفجر. دهcce (double)map['amount'] هيضرب.
      final m = ExpenseModel.fromMap({
        'id': 1,
        'amount': 100, // int مش double
        'category': 'Food',
        'date': '2026-10-01',
      });
      expect(m.amount, 100.0);
      expect(m.id, 1);
      expect(m.category, 'Food');
    });

    test('toMap/fromMap round trip keeps all fields', () {
      final m = ExpenseModel(
          id: 7, amount: 12.34, category: 'Food', date: '2026-10-16',
          note: 'lunch');
      final back = ExpenseModel.fromMap(m.toMap());
      expect(back.id, 7);
      expect(back.amount, 12.34);
      expect(back.category, 'Food');
      expect(back.date, '2026-10-16');
      expect(back.note, 'lunch');
    });

    test('null note stays null', () {
      final m = ExpenseModel(
          id: 1, amount: 5.0, category: 'Food', date: '2026-10-16', note: null);
      expect(m.toMap()['note'], isNull);
      expect(ExpenseModel.fromMap(m.toMap()).note, isNull);
    });

    test('assertions fire in debug: non-positive amount', () {
      expect(
        () => ExpenseModel(amount: 0, category: 'Food', date: '2026-10-16'),
        throwsAssertionError,
      );
      expect(
        () => ExpenseModel(amount: -1, category: 'Food', date: '2026-10-16'),
        throwsAssertionError,
      );
    });

    test('assertions fire in debug: empty category/date', () {
      expect(
        () => ExpenseModel(amount: 5, category: '', date: '2026-10-16'),
        throwsAssertionError,
      );
      expect(
        () => ExpenseModel(amount: 5, category: 'Food', date: ''),
        throwsAssertionError,
      );
    });
  });

  group('IncomeModel', () {
    test('round trip', () {
      final m = IncomeModel(id: 3, amount: 1200.50, source: 'Freelance',
          date: '2026-10-10');
      final back = IncomeModel.fromMap(m.toMap());
      expect(back.amount, 1200.50);
      expect(back.source, 'Freelance');
      expect(back.date, '2026-10-10');
    });

    test('assertions: empty source', () {
      expect(
        () => IncomeModel(amount: 5, source: '', date: '2026-10-01'),
        throwsAssertionError,
      );
    });
  });

  group('CommitmentModel', () {
    test('isCompleted from 1/0/null', () {
      expect(CommitmentModel.fromMap({
                'id': 1, 'title': 'Rent', 'amount': 2000.0,
                'dueDate': '2026-10-25', 'isCompleted': 1,
              }).isCompleted, isTrue);
      expect(CommitmentModel.fromMap({
                'id': 1, 'title': 'Rent', 'amount': 2000.0,
                'dueDate': '2026-10-25', 'isCompleted': 0,
              }).isCompleted, isFalse);
      // قيمة отсутствية => false (default 0 في قاعدة البيانات)
      expect(CommitmentModel.fromMap({
                'id': 1, 'title': 'Rent', 'amount': 2000.0,
                'dueDate': '2026-10-25',
              }).isCompleted, isFalse);
    });

    test('round trip keeps completion flag', () {
      final m = CommitmentModel(
          id: 2, title: 'Phone', amount: 150.0, dueDate: '2026-10-01',
          isCompleted: true);
      final back = CommitmentModel.fromMap(m.toMap());
      expect(back.isCompleted, isTrue);
      expect(back.title, 'Phone');
      expect(back.dueDate, '2026-10-01');
    });
  });
}
