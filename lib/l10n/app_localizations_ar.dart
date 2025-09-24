// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'متابع المال';

  @override
  String get overview => 'نظرة عامة';

  @override
  String get totalBalance => 'الرصيد الإجمالي';

  @override
  String get thisMonth => 'هذا الشهر';

  @override
  String get income => 'الدخل';

  @override
  String get expenses => 'المصروفات';

  @override
  String get commitments => 'الالتزامات';

  @override
  String get history => 'التاريخ';

  @override
  String get settings => 'الإعدادات';

  @override
  String get addIncome => 'إضافة دخل';

  @override
  String get addExpense => 'إضافة مصروف';

  @override
  String get addCommitment => 'إضافة التزام';

  @override
  String get editIncome => 'تعديل الدخل';

  @override
  String get editExpense => 'تعديل المصروف';

  @override
  String get editCommitment => 'تعديل الالتزام';

  @override
  String get amount => 'المبلغ';

  @override
  String get source => 'المصدر';

  @override
  String get category => 'الفئة';

  @override
  String get date => 'التاريخ';

  @override
  String get dueDate => 'تاريخ الاستحقاق';

  @override
  String get notes => 'الملاحظات';

  @override
  String get title => 'العنوان';

  @override
  String get quickSelect => 'اختيار سريع';

  @override
  String get save => 'حفظ';

  @override
  String get update => 'تحديث';

  @override
  String get delete => 'حذف';

  @override
  String get cancel => 'إلغاء';

  @override
  String get saveIncome => 'حفظ الدخل';

  @override
  String get saveExpense => 'حفظ المصروف';

  @override
  String get saveCommitment => 'حفظ الالتزام';

  @override
  String get updateIncome => 'تحديث الدخل';

  @override
  String get updateExpense => 'تحديث المصروف';

  @override
  String get updateCommitment => 'تحديث الالتزام';

  @override
  String get deleteIncome => 'حذف الدخل';

  @override
  String get deleteExpense => 'حذف المصروف';

  @override
  String get deleteCommitment => 'حذف الالتزام';

  @override
  String get deleteIncomeConfirm =>
      'هل أنت متأكد من حذف سجل الدخل هذا؟ لا يمكن التراجع عن هذا الإجراء.';

  @override
  String get deleteExpenseConfirm =>
      'هل أنت متأكد من حذف سجل المصروف هذا؟ لا يمكن التراجع عن هذا الإجراء.';

  @override
  String get deleteCommitmentConfirm =>
      'هل أنت متأكد من حذف هذا الالتزام؟ لا يمكن التراجع عن هذا الإجراء.';

  @override
  String get incomeUpdatedSuccess => 'تم تحديث الدخل بنجاح!';

  @override
  String get expenseUpdatedSuccess => 'تم تحديث المصروف بنجاح!';

  @override
  String get commitmentUpdatedSuccess => 'تم تحديث الالتزام بنجاح!';

  @override
  String get incomeDeletedSuccess => 'تم حذف الدخل بنجاح!';

  @override
  String get expenseDeletedSuccess => 'تم حذف المصروف بنجاح!';

  @override
  String get commitmentDeletedSuccess => 'تم حذف الالتزام بنجاح!';

  @override
  String get incomeSavedSuccess => 'تم حفظ الدخل بنجاح!';

  @override
  String get expenseSavedSuccess => 'تم حفظ المصروف بنجاح!';

  @override
  String get commitmentSavedSuccess => 'تم حفظ الالتزام بنجاح!';

  @override
  String errorUpdatingIncome(String error) {
    return 'خطأ في تحديث الدخل: $error';
  }

  @override
  String errorUpdatingExpense(String error) {
    return 'خطأ في تحديث المصروف: $error';
  }

  @override
  String errorUpdatingCommitment(String error) {
    return 'خطأ في تحديث الالتزام: $error';
  }

  @override
  String errorDeletingIncome(String error) {
    return 'خطأ في حذف الدخل: $error';
  }

  @override
  String errorDeletingExpense(String error) {
    return 'خطأ في حذف المصروف: $error';
  }

  @override
  String errorDeletingCommitment(String error) {
    return 'خطأ في حذف الالتزام: $error';
  }

  @override
  String errorSavingIncome(String error) {
    return 'خطأ في حفظ الدخل: $error';
  }

  @override
  String errorSavingExpense(String error) {
    return 'خطأ في حفظ المصروف: $error';
  }

  @override
  String errorSavingCommitment(String error) {
    return 'خطأ في حفظ الالتزام: $error';
  }

  @override
  String get transactionHistory => 'تاريخ المعاملات';

  @override
  String get noTransactionsYet => 'لا توجد معاملات بعد';

  @override
  String get startAddingTransactions =>
      'ابدأ بإضافة الدخل والمصروفات والالتزامات';

  @override
  String get noCommitmentsYet => 'لا توجد التزامات بعد';

  @override
  String get addYourBills => 'أضف فواتيرك وإيجارك والتزاماتك الأخرى';

  @override
  String get today => 'اليوم';

  @override
  String get yesterday => 'أمس';

  @override
  String get upcoming => 'قادم';

  @override
  String get overdue => 'متأخر';

  @override
  String items(int count) {
    return '$count عنصر';
  }

  @override
  String get all => 'الكل';

  @override
  String get food => 'طعام';

  @override
  String get transport => 'مواصلات';

  @override
  String get shopping => 'تسوق';

  @override
  String get entertainment => 'ترفيه';

  @override
  String get bills => 'فواتير';

  @override
  String get healthcare => 'رعاية صحية';

  @override
  String get education => 'تعليم';

  @override
  String get other => 'أخرى';

  @override
  String get salary => 'راتب';

  @override
  String get freelance => 'عمل حر';

  @override
  String get business => 'أعمال';

  @override
  String get investment => 'استثمار';

  @override
  String get gift => 'هدية';

  @override
  String get bonus => 'مكافأة';

  @override
  String get pleaseEnterAmount => 'يرجى إدخال المبلغ';

  @override
  String get pleaseEnterValidNumber => 'يرجى إدخال رقم صحيح';

  @override
  String get amountMustBeGreaterThanZero => 'يجب أن يكون المبلغ أكبر من صفر';

  @override
  String get pleaseEnterIncomeSource => 'يرجى إدخال مصدر الدخل';

  @override
  String get pleaseEnterTitle => 'يرجى إدخال العنوان';

  @override
  String get addNote => 'إضافة ملاحظة...';

  @override
  String get appearance => 'المظهر';

  @override
  String get language => 'اللغة';

  @override
  String get currency => 'العملة';

  @override
  String get darkMode => 'الوضع المظلم';

  @override
  String get darkThemeEnabled => 'تم تفعيل الوضع المظلم';

  @override
  String get lightThemeEnabled => 'تم تفعيل الوضع المضيء';

  @override
  String get about => 'حول';

  @override
  String get version => 'الإصدار';

  @override
  String get appDescription =>
      'تطبيق بسيط وأنيق لتتبع الأموال لمساعدتك في إدارة أموالك.';

  @override
  String get english => 'English';

  @override
  String get arabic => 'العربية';

  @override
  String get french => 'Français';

  @override
  String get german => 'Deutsch';

  @override
  String get japanese => '日本語';
}
