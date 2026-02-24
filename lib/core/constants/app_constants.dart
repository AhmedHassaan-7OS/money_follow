import 'package:flutter/material.dart';

/// ============================================================
/// AppConstants — Single source of truth for all static data.
///
/// SOLID:
///  • SRP  : هذا الكلاس مسئول فقط عن تعريف ثوابت التطبيق.
///  • OCP  : لإضافة فئة جديدة، عدّل هنا فقط — لا تعديل في الصفحات.
///  • DRY  : انتهى تكرار قوائم الفئات في كل ملف.
/// ============================================================
class AppConstants {
  // منع الـ instantiation
  AppConstants._();

  // ─── Expense Categories ───────────────────────────────────────────────────

  static const List<String> expenseCategories = [
    'Food',
    'Transport',
    'Shopping',
    'Entertainment',
    'Bills',
    'Healthcare',
    'Education',
    'Other',
  ];

  static const Map<String, IconData> categoryIcons = {
    'Food': Icons.restaurant,
    'Transport': Icons.directions_car,
    'Shopping': Icons.shopping_bag,
    'Entertainment': Icons.movie,
    'Bills': Icons.receipt,
    'Healthcare': Icons.local_hospital,
    'Education': Icons.school,
    'Other': Icons.category,
  };

  /// يرجع أيقونة الفئة أو أيقونة افتراضية لو مش موجودة.
  static IconData getCategoryIcon(String category) =>
      categoryIcons[category] ?? Icons.category;

  // ─── Income Sources ───────────────────────────────────────────────────────

  static const List<String> incomeSources = [
    'Salary',
    'Freelance',
    'Business',
    'Investment',
    'Gift',
    'Bonus',
    'Other',
  ];

  static const Map<String, IconData> incomeSourceIcons = {
    'Salary': Icons.work,
    'Freelance': Icons.laptop,
    'Business': Icons.business,
    'Investment': Icons.trending_up,
    'Gift': Icons.card_giftcard,
    'Bonus': Icons.star,
    'Other': Icons.attach_money,
  };

  /// يرجع أيقونة المصدر أو أيقونة افتراضية.
  static IconData getIncomeSourceIcon(String source) =>
      incomeSourceIcons[source] ?? Icons.attach_money;

  // ─── Commitment Icons (Keyword-based detection) ───────────────────────────

  /// يحدد أيقونة الالتزام تلقائياً بناءً على الكلمات المفتاحية في العنوان.
  /// لإضافة كلمة مفتاحية جديدة: عدّل هنا فقط.
  static IconData getCommitmentIcon(String title) {
    final t = title.toLowerCase();
    if (t.contains('rent')) return Icons.home;
    if (t.contains('electricity') || t.contains('electric')) return Icons.flash_on;
    if (t.contains('water')) return Icons.water_drop;
    if (t.contains('internet') || t.contains('wifi')) return Icons.wifi;
    if (t.contains('phone') || t.contains('mobile')) return Icons.phone;
    if (t.contains('car') || t.contains('loan')) return Icons.directions_car;
    if (t.contains('insurance')) return Icons.security;
    if (t.contains('gym') || t.contains('fitness')) return Icons.fitness_center;
    return Icons.schedule;
  }

  // ─── Date Formats ─────────────────────────────────────────────────────────

  /// الصيغة المستخدمة في قاعدة البيانات.
  static const String dbDateFormat = 'yyyy-MM-dd';

  /// الصيغة المعروضة للمستخدم.
  static const String displayDateFormat = 'MMM dd, yyyy';

  // ─── Misc ─────────────────────────────────────────────────────────────────

  /// الـ default category عند إنشاء مصروف جديد.
  static const String defaultExpenseCategory = 'Food';
}
