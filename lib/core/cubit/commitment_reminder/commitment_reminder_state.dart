import 'package:equatable/equatable.dart';

class CommitmentReminderState extends Equatable {
  final bool enabled;
  final int hoursBefore;
  final bool isLoading;

  const CommitmentReminderState({
    this.enabled = false,
    this.hoursBefore = 24,
    this.isLoading = true,
  });

  CommitmentReminderState copyWith({
    bool? enabled,
    int? hoursBefore,
    bool? isLoading,
  }) {
    return CommitmentReminderState(
      enabled: enabled ?? this.enabled,
      hoursBefore: hoursBefore ?? this.hoursBefore,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  @override
  List<Object?> get props => [enabled, hoursBefore, isLoading];
}
