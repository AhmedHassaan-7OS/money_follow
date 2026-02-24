import 'package:money_follow/model/income_model.dart';
import 'package:money_follow/repository/base_repository.dart'
    show BaseRepository;

/// ============================================================
/// IncomeRepository — Data access layer for incomes.
/// ============================================================
class IncomeRepository extends BaseRepository<IncomeModel> {
  static final IncomeRepository _instance = IncomeRepository._();
  factory IncomeRepository() => _instance;
  IncomeRepository._();

  @override
  String get tableName => 'incomes';

  @override
  IncomeModel fromMap(Map<String, dynamic> map) => IncomeModel.fromMap(map);

  @override
  Map<String, dynamic> toMap(IncomeModel item) => item.toMap();

  /// يحسب مجموع الدخل الكلي.
  Future<double> getTotalIncome() async {
    final items = await getAll();
    // ✅ Fix: نحدد النوع صراحةً <double> عشان fold ميرجعش FutureOr
    return items.fold<double>(0.0, (sum, item) => sum + item.amount);
  }
}
