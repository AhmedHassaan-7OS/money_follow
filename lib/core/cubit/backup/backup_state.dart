class BackupState {
  final bool isLoading;
  final double backupSize;
  final String? message;
  final bool isSuccess;

  const BackupState({
    this.isLoading = false,
    this.backupSize = 0.0,
    this.message,
    this.isSuccess = false,
  });

  BackupState copyWith({
    bool? isLoading,
    double? backupSize,
    String? message,
    bool? isSuccess,
  }) {
    return BackupState(
      isLoading: isLoading ?? this.isLoading,
      backupSize: backupSize ?? this.backupSize,
      message: message,
      isSuccess: isSuccess ?? false,
    );
  }
}
