/// Models for backup operations
/// Contains all data structures used in backup and restore functionality

/// Result class for backup import operations
class BackupImportResult {
  final bool success;
  final String message;
  final Map<String, dynamic>? data;
  final int itemCount;
  final String? backupDate;

  const BackupImportResult({
    required this.success,
    required this.message,
    this.data,
    this.itemCount = 0,
    this.backupDate,
  });

  /// Create a success result
  factory BackupImportResult.success({
    required String message,
    Map<String, dynamic>? data,
    int itemCount = 0,
    String? backupDate,
  }) {
    return BackupImportResult(
      success: true,
      message: message,
      data: data,
      itemCount: itemCount,
      backupDate: backupDate,
    );
  }

  /// Create a failure result
  factory BackupImportResult.failure(String message) {
    return BackupImportResult(
      success: false,
      message: message,
    );
  }

  @override
  String toString() {
    return 'BackupImportResult(success: $success, message: $message, itemCount: $itemCount)';
  }
}

/// Backup data structure
class BackupData {
  final String version;
  final String timestamp;
  final String appName;
  final Map<String, dynamic> data;

  const BackupData({
    required this.version,
    required this.timestamp,
    required this.appName,
    required this.data,
  });

  /// Create backup data from current app state
  factory BackupData.create({
    required String version,
    required String appName,
    required Map<String, dynamic> data,
  }) {
    return BackupData(
      version: version,
      timestamp: DateTime.now().toIso8601String(),
      appName: appName,
      data: data,
    );
  }

  /// Create backup data from JSON map
  factory BackupData.fromMap(Map<String, dynamic> map) {
    return BackupData(
      version: map['version'] ?? '',
      timestamp: map['timestamp'] ?? '',
      appName: map['app_name'] ?? '',
      data: map['data'] ?? {},
    );
  }

  /// Convert to JSON map
  Map<String, dynamic> toMap() {
    return {
      'version': version,
      'timestamp': timestamp,
      'app_name': appName,
      'data': data,
    };
  }

  /// Get total item count in backup
  int get itemCount {
    int total = 0;
    total += (data['incomes'] as List?)?.length ?? 0;
    total += (data['expenses'] as List?)?.length ?? 0;
    total += (data['commitments'] as List?)?.length ?? 0;
    return total;
  }

  /// Check if backup is valid
  bool get isValid {
    return version.isNotEmpty && 
           timestamp.isNotEmpty && 
           appName.isNotEmpty && 
           data.isNotEmpty;
  }

  @override
  String toString() {
    return 'BackupData(version: $version, appName: $appName, itemCount: $itemCount)';
  }
}

/// File picker result for backup operations
class BackupFileResult {
  final bool success;
  final String? filePath;
  final String? fileName;
  final String? content;
  final String? error;

  const BackupFileResult({
    required this.success,
    this.filePath,
    this.fileName,
    this.content,
    this.error,
  });

  /// Create a success result
  factory BackupFileResult.success({
    String? filePath,
    String? fileName,
    String? content,
  }) {
    return BackupFileResult(
      success: true,
      filePath: filePath,
      fileName: fileName,
      content: content,
    );
  }

  /// Create a failure result
  factory BackupFileResult.failure(String error) {
    return BackupFileResult(
      success: false,
      error: error,
    );
  }

  @override
  String toString() {
    return 'BackupFileResult(success: $success, fileName: $fileName, error: $error)';
  }
}
