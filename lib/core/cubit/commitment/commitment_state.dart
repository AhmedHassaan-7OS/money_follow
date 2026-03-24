import 'package:money_follow/models/commitment_model.dart';

enum CommitmentFilter { all, pending, completed }

class CommitmentState {
  final List<CommitmentModel> commitments;
  final CommitmentFilter filter;
  final bool isLoading;
  final String? message;
  final bool isSuccess;

  const CommitmentState({
    this.commitments = const [],
    this.filter = CommitmentFilter.pending,
    this.isLoading = true,
    this.message,
    this.isSuccess = false,
  });

  List<CommitmentModel> get filtered {
    switch (filter) {
      case CommitmentFilter.pending:
        return commitments.where((c) => !c.isCompleted).toList();
      case CommitmentFilter.completed:
        return commitments.where((c) => c.isCompleted).toList();
      case CommitmentFilter.all:
        return commitments;
    }
  }

  int get pendingCount =>
      commitments.where((c) => !c.isCompleted).length;

  int get completedCount =>
      commitments.where((c) => c.isCompleted).length;

  CommitmentState copyWith({
    List<CommitmentModel>? commitments,
    CommitmentFilter? filter,
    bool? isLoading,
    String? message,
    bool? isSuccess,
  }) {
    return CommitmentState(
      commitments: commitments ?? this.commitments,
      filter: filter ?? this.filter,
      isLoading: isLoading ?? this.isLoading,
      message: message,
      isSuccess: isSuccess ?? false,
    );
  }
}
