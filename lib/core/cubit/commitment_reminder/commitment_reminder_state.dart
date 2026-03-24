class CommitmentReminderState {
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
}
