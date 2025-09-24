import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations) ??
        AppLocalizations(const Locale('en'));
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  // App strings based on locale
  Map<String, String> get _localizedStrings {
    switch (locale.languageCode) {
      case 'ar':
        return _arabicStrings;
      case 'fr':
        return _frenchStrings;
      case 'de':
        return _germanStrings;
      case 'ja':
        return _japaneseStrings;
      default:
        return _englishStrings;
    }
  }

  // Getters for all strings
  String get appTitle => _localizedStrings['appTitle'] ?? 'Money Follow';
  String get overview => _localizedStrings['overview'] ?? 'Overview';
  String get totalBalance => _localizedStrings['totalBalance'] ?? 'Total Balance';
  String get thisMonth => _localizedStrings['thisMonth'] ?? 'This Month';
  String get income => _localizedStrings['income'] ?? 'Income';
  String get expenses => _localizedStrings['expenses'] ?? 'Expenses';
  String get commitments => _localizedStrings['commitments'] ?? 'Commitments';
  String get history => _localizedStrings['history'] ?? 'History';
  String get settings => _localizedStrings['settings'] ?? 'Settings';
  String get category => _localizedStrings['category'] ?? 'Category';
  String get upcoming => _localizedStrings['upcoming'] ?? 'Upcoming';
  String get noCommitmentsYet => _localizedStrings['noCommitmentsYet'] ?? 'No commitments yet';
  String get language => _localizedStrings['language'] ?? 'Language';
  String get currency => _localizedStrings['currency'] ?? 'Currency';
  String get darkMode => _localizedStrings['darkMode'] ?? 'Dark Mode';
  String get darkThemeEnabled => _localizedStrings['darkThemeEnabled'] ?? 'Dark theme enabled';
  String get lightThemeEnabled => _localizedStrings['lightThemeEnabled'] ?? 'Light theme enabled';
  String get appearance => _localizedStrings['appearance'] ?? 'Appearance';
  String get about => _localizedStrings['about'] ?? 'About';
  String get version => _localizedStrings['version'] ?? 'Version';
  String get appDescription => _localizedStrings['appDescription'] ?? 'A simple and elegant money tracking app to help you manage your finances.';
  String get backupRestore => _localizedStrings['backupRestore'] ?? 'Backup & Restore';
  String get dataManagement => _localizedStrings['dataManagement'] ?? 'Data Management';
  String get exportImportData => _localizedStrings['exportImportData'] ?? 'Export and import your data';
  String get amount => _localizedStrings['amount'] ?? 'Amount';
  String get source => _localizedStrings['source'] ?? 'Source';
  String get quickSelect => _localizedStrings['quickSelect'] ?? 'Quick Select';
  String get date => _localizedStrings['date'] ?? 'Date';
  String get save => _localizedStrings['save'] ?? 'Save';
  String get title => _localizedStrings['title'] ?? 'Title';
  String get notes => _localizedStrings['notes'] ?? 'Notes';
  String get addNote => _localizedStrings['addNote'] ?? 'Add a note...';
  String get dueDate => _localizedStrings['dueDate'] ?? 'Due Date';
  String get add => _localizedStrings['add'] ?? 'Add';
  String get edit => _localizedStrings['edit'] ?? 'Edit';
  String get delete => _localizedStrings['delete'] ?? 'Delete';
  String get cancel => _localizedStrings['cancel'] ?? 'Cancel';
  String get confirm => _localizedStrings['confirm'] ?? 'Confirm';
  String get food => _localizedStrings['food'] ?? 'Food';
  String get transport => _localizedStrings['transport'] ?? 'Transport';
  String get shopping => _localizedStrings['shopping'] ?? 'Shopping';
  String get entertainment => _localizedStrings['entertainment'] ?? 'Entertainment';
  String get bills => _localizedStrings['bills'] ?? 'Bills';
  String get healthcare => _localizedStrings['healthcare'] ?? 'Healthcare';
  String get education => _localizedStrings['education'] ?? 'Education';
  String get other => _localizedStrings['other'] ?? 'Other';
  String get expenseUpdatedSuccess => _localizedStrings['expenseUpdatedSuccess'] ?? 'Expense updated successfully!';
  String get expenseDeletedSuccess => _localizedStrings['expenseDeletedSuccess'] ?? 'Expense deleted successfully!';
  String get deleteExpenseConfirm => _localizedStrings['deleteExpenseConfirm'] ?? 'Are you sure you want to delete this expense record? This action cannot be undone.';
  String get errorUpdatingExpense => _localizedStrings['errorUpdatingExpense'] ?? 'Error updating expense';
  String get errorDeletingExpense => _localizedStrings['errorDeletingExpense'] ?? 'Error deleting expense';
  String get pleaseEnterAmount => _localizedStrings['pleaseEnterAmount'] ?? 'Please enter an amount';
  String get pleaseEnterValidNumber => _localizedStrings['pleaseEnterValidNumber'] ?? 'Please enter a valid number';
  String get amountMustBeGreaterThanZero => _localizedStrings['amountMustBeGreaterThanZero'] ?? 'Amount must be greater than 0';
  String get pleaseEnterTitle => _localizedStrings['pleaseEnterTitle'] ?? 'Please enter a title';
  String get pleaseEnterSource => _localizedStrings['pleaseEnterSource'] ?? 'Please enter income source';

  // English strings
  static const Map<String, String> _englishStrings = {
    'appTitle': 'Money Follow',
    'overview': 'Overview',
    'totalBalance': 'Total Balance',
    'thisMonth': 'This Month',
    'income': 'Income',
    'expenses': 'Expenses',
    'commitments': 'Commitments',
    'history': 'History',
    'settings': 'Settings',
    'category': 'Category',
    'upcoming': 'Upcoming',
    'noCommitmentsYet': 'No commitments yet',
    'language': 'Language',
    'currency': 'Currency',
    'darkMode': 'Dark Mode',
    'darkThemeEnabled': 'Dark theme enabled',
    'lightThemeEnabled': 'Light theme enabled',
    'appearance': 'Appearance',
    'about': 'About',
    'version': 'Version',
    'appDescription': 'A simple and elegant money tracking app to help you manage your finances.',
    'backupRestore': 'Backup & Restore',
    'dataManagement': 'Data Management',
    'exportImportData': 'Export and import your data',
    'amount': 'Amount',
    'source': 'Source',
    'quickSelect': 'Quick Select',
    'date': 'Date',
    'save': 'Save',
    'title': 'Title',
    'notes': 'Notes',
    'addNote': 'Add a note...',
    'dueDate': 'Due Date',
    'add': 'Add',
    'edit': 'Edit',
    'delete': 'Delete',
    'cancel': 'Cancel',
    'confirm': 'Confirm',
    'food': 'Food',
    'transport': 'Transport',
    'shopping': 'Shopping',
    'entertainment': 'Entertainment',
    'bills': 'Bills',
    'healthcare': 'Healthcare',
    'education': 'Education',
    'other': 'Other',
    'expenseUpdatedSuccess': 'Expense updated successfully!',
    'expenseDeletedSuccess': 'Expense deleted successfully!',
    'deleteExpenseConfirm': 'Are you sure you want to delete this expense record? This action cannot be undone.',
    'errorUpdatingExpense': 'Error updating expense',
    'errorDeletingExpense': 'Error deleting expense',
    'pleaseEnterAmount': 'Please enter an amount',
    'pleaseEnterValidNumber': 'Please enter a valid number',
    'amountMustBeGreaterThanZero': 'Amount must be greater than 0',
    'pleaseEnterTitle': 'Please enter a title',
    'pleaseEnterSource': 'Please enter income source',
  };

  // Arabic strings
  static const Map<String, String> _arabicStrings = {
    'appTitle': 'متابع المال',
    'overview': 'نظرة عامة',
    'totalBalance': 'الرصيد الإجمالي',
    'thisMonth': 'هذا الشهر',
    'income': 'الدخل',
    'expenses': 'المصروفات',
    'commitments': 'الالتزامات',
    'history': 'التاريخ',
    'settings': 'الإعدادات',
    'category': 'الفئة',
    'upcoming': 'قادم',
    'noCommitmentsYet': 'لا توجد التزامات بعد',
    'language': 'اللغة',
    'currency': 'العملة',
    'darkMode': 'الوضع المظلم',
    'darkThemeEnabled': 'تم تفعيل الوضع المظلم',
    'lightThemeEnabled': 'تم تفعيل الوضع المضيء',
    'appearance': 'المظهر',
    'about': 'حول',
    'version': 'الإصدار',
    'appDescription': 'تطبيق بسيط وأنيق لتتبع الأموال لمساعدتك في إدارة أموالك.',
    'backupRestore': 'نسخ احتياطي واستعادة',
    'dataManagement': 'إدارة البيانات',
    'exportImportData': 'تصدير واستيراد بياناتك',
    'amount': 'المبلغ',
    'source': 'المصدر',
    'quickSelect': 'اختيار سريع',
    'date': 'التاريخ',
    'save': 'حفظ',
    'title': 'العنوان',
    'notes': 'ملاحظات',
    'addNote': 'إضافة ملاحظة...',
    'dueDate': 'تاريخ الاستحقاق',
    'add': 'إضافة',
    'edit': 'تعديل',
    'delete': 'حذف',
    'cancel': 'إلغاء',
    'confirm': 'تأكيد',
    'food': 'طعام',
    'transport': 'مواصلات',
    'shopping': 'تسوق',
    'entertainment': 'ترفيه',
    'bills': 'فواتير',
    'healthcare': 'رعاية صحية',
    'education': 'تعليم',
    'other': 'أخرى',
    'expenseUpdatedSuccess': 'تم تحديث المصروف بنجاح!',
    'expenseDeletedSuccess': 'تم حذف المصروف بنجاح!',
    'deleteExpenseConfirm': 'هل أنت متأكد من حذف سجل المصروف هذا؟ لا يمكن التراجع عن هذا الإجراء.',
    'errorUpdatingExpense': 'خطأ في تحديث المصروف',
    'errorDeletingExpense': 'خطأ في حذف المصروف',
    'pleaseEnterAmount': 'يرجى إدخال المبلغ',
    'pleaseEnterValidNumber': 'يرجى إدخال رقم صحيح',
    'amountMustBeGreaterThanZero': 'يجب أن يكون المبلغ أكبر من صفر',
    'pleaseEnterTitle': 'يرجى إدخال العنوان',
    'pleaseEnterSource': 'يرجى إدخال مصدر الدخل',
  };

  // French strings
  static const Map<String, String> _frenchStrings = {
    'appTitle': 'Suivi d\'Argent',
    'overview': 'Aperçu',
    'totalBalance': 'Solde Total',
    'thisMonth': 'Ce Mois',
    'income': 'Revenus',
    'expenses': 'Dépenses',
    'commitments': 'Engagements',
    'history': 'Historique',
    'settings': 'Paramètres',
    'category': 'Catégorie',
    'upcoming': 'À Venir',
    'noCommitmentsYet': 'Aucun engagement pour le moment',
    'language': 'Langue',
    'currency': 'Devise',
    'darkMode': 'Mode Sombre',
    'darkThemeEnabled': 'Thème sombre activé',
    'lightThemeEnabled': 'Thème clair activé',
    'appearance': 'Apparence',
    'about': 'À Propos',
    'version': 'Version',
    'appDescription': 'Une application simple et élégante de suivi d\'argent pour vous aider à gérer vos finances.',
    'backupRestore': 'Sauvegarde et Restauration',
    'dataManagement': 'Gestion des Données',
    'exportImportData': 'Exportez et importez vos données',
    'amount': 'Montant',
    'source': 'Source',
    'quickSelect': 'Sélection Rapide',
    'date': 'Date',
    'save': 'Enregistrer',
    'title': 'Titre',
    'notes': 'Notes',
    'addNote': 'Ajouter une note...',
    'dueDate': 'Date d\'Échéance',
    'add': 'Ajouter',
    'edit': 'Modifier',
    'delete': 'Supprimer',
    'cancel': 'Annuler',
    'confirm': 'Confirmer',
    'food': 'Nourriture',
    'transport': 'Transport',
    'shopping': 'Shopping',
    'entertainment': 'Divertissement',
    'bills': 'Factures',
    'healthcare': 'Santé',
    'education': 'Éducation',
    'other': 'Autre',
    'expenseUpdatedSuccess': 'Dépense mise à jour avec succès !',
    'expenseDeletedSuccess': 'Dépense supprimée avec succès !',
    'deleteExpenseConfirm': 'Êtes-vous sûr de vouloir supprimer cet enregistrement de dépense ? Cette action ne peut pas être annulée.',
    'errorUpdatingExpense': 'Erreur lors de la mise à jour de la dépense',
    'errorDeletingExpense': 'Erreur lors de la suppression de la dépense',
  };

  // German strings
  static const Map<String, String> _germanStrings = {
    'appTitle': 'Geld Verfolgen',
    'overview': 'Übersicht',
    'totalBalance': 'Gesamtsaldo',
    'thisMonth': 'Dieser Monat',
    'income': 'Einkommen',
    'expenses': 'Ausgaben',
    'commitments': 'Verpflichtungen',
    'history': 'Verlauf',
    'settings': 'Einstellungen',
    'category': 'Kategorie',
    'upcoming': 'Bevorstehend',
    'noCommitmentsYet': 'Noch keine Verpflichtungen',
    'language': 'Sprache',
    'currency': 'Währung',
    'darkMode': 'Dunkler Modus',
    'darkThemeEnabled': 'Dunkles Design aktiviert',
    'lightThemeEnabled': 'Helles Design aktiviert',
    'appearance': 'Erscheinungsbild',
    'about': 'Über',
    'version': 'Version',
    'appDescription': 'Eine einfache und elegante Geld-Tracking-App, die Ihnen bei der Verwaltung Ihrer Finanzen hilft.',
    'backupRestore': 'Sichern & Wiederherstellen',
    'dataManagement': 'Datenverwaltung',
    'exportImportData': 'Exportieren und importieren Sie Ihre Daten',
    'amount': 'Betrag',
    'source': 'Quelle',
    'quickSelect': 'Schnellauswahl',
    'date': 'Datum',
    'save': 'Speichern',
    'title': 'Titel',
    'notes': 'Notizen',
    'addNote': 'Eine Notiz hinzufügen...',
    'dueDate': 'Fälligkeitsdatum',
    'add': 'Hinzufügen',
    'edit': 'Bearbeiten',
    'delete': 'Löschen',
    'cancel': 'Abbrechen',
    'confirm': 'Bestätigen',
    'food': 'Nahrungsmittel',
    'transport': 'Transport',
    'shopping': 'Einkaufen',
    'entertainment': 'Unterhaltung',
    'bills': 'Rechnungen',
    'healthcare': 'Gesundheitswesen',
    'education': 'Bildung',
    'other': 'Andere',
    'expenseUpdatedSuccess': 'Ausgabe erfolgreich aktualisiert!',
    'expenseDeletedSuccess': 'Ausgabe erfolgreich gelöscht!',
    'deleteExpenseConfirm': 'Sind Sie sicher, dass Sie diesen Ausgabenposten löschen möchten? Diese Aktion kann nicht rückgängig gemacht werden.',
    'errorUpdatingExpense': 'Fehler beim Aktualisieren der Ausgabe',
    'errorDeletingExpense': 'Fehler beim Löschen der Ausgabe',
  };

  // Japanese strings
  static const Map<String, String> _japaneseStrings = {
    'appTitle': 'マネーフォロー',
    'overview': '概要',
    'totalBalance': '総残高',
    'thisMonth': '今月',
    'income': '収入',
    'expenses': '支出',
    'commitments': 'コミットメント',
    'history': '履歴',
    'settings': '設定',
    'category': 'カテゴリ',
    'upcoming': '今後',
    'noCommitmentsYet': 'まだコミットメントがありません',
    'language': '言語',
    'currency': '通貨',
    'darkMode': 'ダークモード',
    'darkThemeEnabled': 'ダークテーマが有効',
    'lightThemeEnabled': 'ライトテーマが有効',
    'appearance': '外観',
    'about': 'について',
    'version': 'バージョン',
    'appDescription': '財務管理に役立つシンプルでエレガントなマネートラッキングアプリ。',
    'backupRestore': 'バックアップと復元',
    'dataManagement': 'データ管理',
    'exportImportData': 'データのエクスポートとインポート',
    'amount': '金額',
    'source': 'ソース',
    'quickSelect': 'クイック選択',
    'date': '日付',
    'save': '保存',
    'title': 'タイトル',
    'notes': 'メモ',
    'addNote': 'メモを追加...',
    'dueDate': '期日',
    'add': '追加',
    'edit': '編集',
    'delete': '削除',
    'cancel': 'キャンセル',
    'confirm': '確認',
    'food': '食べ物',
    'transport': '交通',
    'shopping': 'ショッピング',
    'entertainment': 'エンターテインメント',
    'bills': '請求書',
    'healthcare': '医療',
    'education': '教育',
    'other': 'その他',
    'expenseUpdatedSuccess': '支出が正常に更新されました！',
    'expenseDeletedSuccess': '支出が正常に削除されました！',
    'deleteExpenseConfirm': 'この支出の記録を削除してもよろしいですか？ この操作は元に戻せません。',
    'errorUpdatingExpense': '支出の更新エラー',
    'errorDeletingExpense': '支出の削除エラー',
  };
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'ar', 'fr', 'de', 'ja'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
