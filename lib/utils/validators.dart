/// ============================================================
/// AppValidators — Centralized form validation logic.
///
/// SOLID:
///  • SRP : هذا الكلاس مسئول فقط عن التحقق من صحة المدخلات.
///  • DRY : نهاية تكرار نفس الـ validator في كل صفحة.
///  • OCP : لإضافة validator جديد، أضفه هنا فقط.
/// ============================================================
class AppValidators {
  AppValidators._();

  /// يتحقق من صحة حقل المبلغ — يُستخدم في كل الفورمات.
  static String? amount(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter an amount';
    }
    final parsed = double.tryParse(value.trim());
    if (parsed == null) {
      return 'Please enter a valid number';
    }
    if (parsed <= 0) {
      return 'Amount must be greater than 0';
    }
    return null;
  }

  /// يتحقق من أن الحقل مش فاضي.
  static String? required(String? value, {String fieldName = 'This field'}) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  /// يتحقق من صحة المصدر في إدخال الدخل.
  static String? incomeSource(String? value) =>
      required(value, fieldName: 'Income source');

  /// يتحقق من صحة عنوان الالتزام.
  static String? commitmentTitle(String? value) =>
      required(value, fieldName: 'Title');
}
