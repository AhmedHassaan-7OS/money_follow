import 'package:money_follow/model/expense_model.dart';
import 'package:money_follow/repository/base_repository.dart'
    show BaseRepository;

/// ============================================================
/// ExpenseRepository — Data access layer for expenses.
///
/// الصفحات والـ BLoC يستخدموا هذا الـ Repository بدل SqlControl.
/// ============================================================
class ExpenseRepository extends BaseRepository<ExpenseModel> {
  // Singleton — مش محتاج أكتر من instance واحدة.
  static final ExpenseRepository _instance = ExpenseRepository._();
  factory ExpenseRepository() => _instance;
  ExpenseRepository._();

  @override
  String get tableName => 'expenses';

  @override
  ExpenseModel fromMap(Map<String, dynamic> map) => ExpenseModel.fromMap(map);

  @override
  Map<String, dynamic> toMap(ExpenseModel item) => item.toMap();

  /// يرجع المصاريف مرتبة من الأحدث للأقدم.
  Future<List<ExpenseModel>> getAllSorted() async {
    final items = await getAll();
    items.sort((a, b) => b.date.compareTo(a.date));
    return items;
  }
}
