import 'package:money_follow/model/commitment_model.dart';
import 'package:money_follow/repository/base_repository.dart'
    show BaseRepository;

/// ============================================================
/// CommitmentRepository — Data access layer for commitments.
/// ============================================================
class CommitmentRepository extends BaseRepository<CommitmentModel> {
  static final CommitmentRepository _instance = CommitmentRepository._();
  factory CommitmentRepository() => _instance;
  CommitmentRepository._();

  @override
  String get tableName => 'commitments';

  @override
  CommitmentModel fromMap(Map<String, dynamic> map) =>
      CommitmentModel.fromMap(map);

  @override
  Map<String, dynamic> toMap(CommitmentModel item) => item.toMap();

  /// يرجع الالتزامات مرتبة بالأقرب للموعد.
  Future<List<CommitmentModel>> getAllSortedByDueDate() async {
    final items = await getAll();
    items.sort((a, b) => a.dueDate.compareTo(b.dueDate));
    return items;
  }
}
