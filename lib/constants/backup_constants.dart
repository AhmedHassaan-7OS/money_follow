/// Constants and configuration for backup operations.
/// Contains all static values used across backup functionality.
library backup_constants;

class BackupConstants {
  // Private constructor to prevent instantiation
  BackupConstants._();

  /// Backup version for compatibility checking
  static const String backupVersion = '1.0';

  /// Application name for backup validation
  static const String appName = 'Money Follow';

  /// File extensions
  static const String backupFileExtension = 'json';
  static const List<String> allowedExtensions = ['json'];

  /// File naming
  static const String backupFilePrefix = 'money_follow_backup_';
  static const String backupFileSuffix = '.json';

  /// Database table names
  static const String incomesTable = 'incomes';
  static const String expensesTable = 'expenses';
  static const String commitmentsTable = 'commitments';

  /// Error messages in Arabic
  static const String permissionDeniedMessage = 'إذن الوصول للملفات مطلوب لاستيراد النسخة الاحتياطية';
  static const String noFileSelectedMessage = 'لم يتم اختيار ملف. يرجى المحاولة مرة أخرى أو استخدام الإدخال اليدوي';
  static const String invalidFileExtensionMessage = 'يرجى اختيار ملف JSON صالح (.json)';
  static const String emptyFileMessage = 'الملف المحدد فارغ';
  static const String invalidFormatMessage = 'تنسيق الملف غير صحيح. يجب أن يكون ملف JSON صالح';
  static const String invalidBackupFormatMessage = 'تنسيق ملف النسخة الاحتياطية غير صحيح';
  static const String wrongAppMessage = 'هذا الملف ليس من تطبيق Money Follow';
  static const String emptyInputMessage = 'يرجى إدخال بيانات النسخة الاحتياطية';
  static const String noClipboardDataMessage = 'لا توجد بيانات في الحافظة';
  static const String filePickerFailedMessage = 'فشل في فتح منتقي الملفات. يرجى استخدام الإدخال اليدوي.';
  static const String backupValidatedMessage = 'تم التحقق من ملف النسخة الاحتياطية بنجاح';

  /// Success messages
  static const String exportSuccessMessage = 'تم تصدير النسخة الاحتياطية بنجاح';
  static const String importSuccessMessage = 'تم استيراد النسخة الاحتياطية بنجاح';
  static const String shareSuccessMessage = 'تم مشاركة النسخة الاحتياطية';
  static const String clipboardSuccessMessage = 'تم نسخ النسخة الاحتياطية للحافظة';

  /// File validation
  static bool isValidJsonExtension(String? extension) {
    return extension != null && extension.toLowerCase() == backupFileExtension;
  }

  /// Generate backup filename with timestamp
  static String generateBackupFileName() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return '$backupFilePrefix$timestamp$backupFileSuffix';
  }

  /// Validate JSON format
  static bool isValidJsonFormat(String content) {
    final trimmed = content.trim();
    return trimmed.startsWith('{') && trimmed.endsWith('}');
  }

  /// Check if backup contains required fields
  static bool hasRequiredBackupFields(Map<String, dynamic> backup) {
    return backup.containsKey('version') &&
           backup.containsKey('data') &&
           backup.containsKey('app_name');
  }

  /// Validate app name in backup
  static bool isValidAppName(String? backupAppName) {
    return backupAppName == appName;
  }

  /// Get all database table names
  static List<String> get allTableNames => [
    incomesTable,
    expensesTable,
    commitmentsTable,
  ];
}
