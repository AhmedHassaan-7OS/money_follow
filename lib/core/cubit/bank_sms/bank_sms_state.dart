class BankSmsState {
  final bool captureEnabled;
  final bool autoRecordEnabled;
  final int pendingCount;
  final bool isLoading;
  final List<dynamic> pendingTransactions;

  const BankSmsState({
    this.captureEnabled = false,
    this.autoRecordEnabled = false,
    this.pendingCount = 0,
    this.isLoading = true,
    this.pendingTransactions = const [],
  });

  BankSmsState copyWith({
    bool? captureEnabled,
    bool? autoRecordEnabled,
    int? pendingCount,
    bool? isLoading,
    List<dynamic>? pendingTransactions,
  }) {
    return BankSmsState(
      captureEnabled: captureEnabled ?? this.captureEnabled,
      autoRecordEnabled: autoRecordEnabled ?? this.autoRecordEnabled,
      pendingCount: pendingCount ?? this.pendingCount,
      isLoading: isLoading ?? this.isLoading,
      pendingTransactions: pendingTransactions ?? this.pendingTransactions,
    );
  }
}
