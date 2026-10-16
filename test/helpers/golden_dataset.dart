// ============================================================
// Golden Dataset — بيانات ثابتة محسوبة يدوياً (خطة الاختبار §3).
// "اليوم" ثابت = الجمعة 2026-10-16.
// ============================================================

import 'package:money_follow/control/sqlcontrol.dart';
import 'package:money_follow/models/expense_model.dart';
import 'package:money_follow/models/income_model.dart';
import 'package:money_follow/models/commitment_model.dart';

/// النقطة الزمنية الثابتة للتستات.
final DateTime goldenNow = DateTime(2026, 10, 16, 12);

DateTime Function() fixedClock() => () => goldenNow;

const String todayDate = '2026-10-16';

/// إدخال الدخل: إجمالي 6200.50
final List<IncomeModel> goldenIncomes = [
  IncomeModel(id: 1, amount: 5000.00, source: 'Salary', date: '2026-10-01'),
  IncomeModel(id: 2, amount: 1200.50, source: 'Freelance', date: '2026-10-10'),
];

/// إدخال المصروفات: إجمالي 1399.99
final List<ExpenseModel> goldenExpenses = [
  ExpenseModel(id: 1, amount: 150.25, category: 'Food', date: '2026-10-16'),
  ExpenseModel(id: 2, amount: 49.75, category: 'Transport', date: '2026-10-16'),
  ExpenseModel(id: 3, amount: 800.00, category: 'Bills', date: '2026-10-05'),
  ExpenseModel(id: 4, amount: 99.99, category: 'Food', date: '2026-09-30'),
  ExpenseModel(id: 5, amount: 300.00, category: 'Shopping', date: '2026-10-20'),
];

/// الالتزامات: Rent (pending) + Phone (completed)
final List<CommitmentModel> goldenCommitments = [
  CommitmentModel(
      id: 1, title: 'Rent', amount: 2000.00, dueDate: '2026-10-25'),
  CommitmentModel(
      id: 2, title: 'Phone', amount: 150.00, dueDate: '2026-10-01',
      isCompleted: true),
];

/// تعبئة قاعدة بيانات نظيفة بالـ Golden Dataset كامل.
Future<void> seedGoldenDataset(SqlControl sql) async {
  for (final i in goldenIncomes) {
    await sql.insertData('incomes', i.toMap());
  }
  for (final e in goldenExpenses) {
    await sql.insertData('expenses', e.toMap());
  }
  for (final c in goldenCommitments) {
    await sql.insertData('commitments', c.toMap());
  }
}
