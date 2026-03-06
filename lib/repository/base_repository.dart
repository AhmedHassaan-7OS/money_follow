import 'dart:async';

import 'package:money_follow/control/sqlcontrol.dart';
import 'package:money_follow/services/home_widget_service.dart';

/// ============================================================
/// BaseRepository<T> — Abstract base for all data access.
///
/// SOLID:
///  • SRP : الـ Repository مسئول فقط عن عمليات البيانات،
///          والصفحات مسئولة فقط عن الـ UI.
///  • DIP : الصفحات تعتمد على الـ abstraction (Repository)
///          مش على SqlControl مباشرةً.
///  • DRY : الـ CRUD logic في مكان واحد بس.
///  • OCP : كل Repository بيـ extend البيس ويضيف ما يحتاجه.
///
/// الاستخدام:
///   class ExpenseRepository extends BaseRepository<ExpenseModel> {
///     @override String get tableName => 'expenses';
///     @override ExpenseModel fromMap(map) => ExpenseModel.fromMap(map);
///     @override Map<String, dynamic> toMap(item) => item.toMap();
///   }
/// ============================================================
abstract class BaseRepository<T> {
  final SqlControl _db = SqlControl();

  /// اسم الجدول في قاعدة البيانات.
  String get tableName;

  /// يحوّل Map من DB إلى model.
  T fromMap(Map<String, dynamic> map);

  /// يحوّل model إلى Map لحفظه في DB.
  Map<String, dynamic> toMap(T item);

  // ─── CRUD Operations ──────────────────────────────────────────────────────

  Future<List<T>> getAll() async {
    final data = await _db.getData(tableName);
    return data.map(fromMap).toList();
  }

  Future<int> insert(T item) async {
    final result = await _db.insertData(tableName, toMap(item));
    unawaited(HomeWidgetService.refreshWidgets());
    return result;
  }

  Future<int> update(T item, int id) async {
    final result = await _db.updateData(tableName, toMap(item), id);
    unawaited(HomeWidgetService.refreshWidgets());
    return result;
  }

  Future<int> delete(int id) async {
    final result = await _db.deleteData(tableName, id);
    unawaited(HomeWidgetService.refreshWidgets());
    return result;
  }
}
