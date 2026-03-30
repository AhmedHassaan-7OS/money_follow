import 'package:money_follow/utils/app_localizations_temp.dart';

extension AppLocalizationsX on AppLocalizations {
  String get transactionHistoryLabel {
    switch (locale.languageCode) {
      case 'ar':
        return 'سجل المعاملات';
      case 'fr':
        return 'Historique des transactions';
      case 'de':
        return 'Transaktionsverlauf';
      case 'ja':
        return '取引履歴';
      default:
        return 'Transaction History';
    }
  }

  String itemsLabel(int count) {
    switch (locale.languageCode) {
      case 'ar':
        return '$count عنصر';
      case 'fr':
        return '$count éléments';
      case 'de':
        return '$count Einträge';
      case 'ja':
        return '$count件';
      default:
        return '$count items';
    }
  }

  String get noTransactionsYetLabel {
    switch (locale.languageCode) {
      case 'ar':
        return 'لا توجد معاملات بعد';
      case 'fr':
        return 'Aucune transaction pour le moment';
      case 'de':
        return 'Noch keine Transaktionen';
      case 'ja':
        return 'まだ取引がありません';
      default:
        return 'No transactions yet';
    }
  }

  String get startAddingTransactionsLabel {
    switch (locale.languageCode) {
      case 'ar':
        return 'ابدأ بإضافة دخل أو مصروف أو التزام';
      case 'fr':
        return 'Commencez par ajouter des revenus, dépenses ou engagements';
      case 'de':
        return 'Beginnen Sie mit dem Hinzufügen von Einnahmen, Ausgaben oder Verpflichtungen';
      case 'ja':
        return '収入、支出、またはコミットメントを追加して始めましょう';
      default:
        return 'Start adding income, expenses, or commitments';
    }
  }

  String get yesterdayLabel {
    switch (locale.languageCode) {
      case 'ar':
        return 'أمس';
      case 'fr':
        return 'Hier';
      case 'de':
        return 'Gestern';
      case 'ja':
        return '昨日';
      default:
        return 'Yesterday';
    }
  }

  String get updateIncomeLabel {
    switch (locale.languageCode) {
      case 'ar':
        return 'تحديث الدخل';
      case 'fr':
        return 'Mettre à jour le revenu';
      case 'de':
        return 'Einkommen aktualisieren';
      case 'ja':
        return '収入を更新';
      default:
        return 'Update Income';
    }
  }

  String get updateCommitmentLabel {
    switch (locale.languageCode) {
      case 'ar':
        return 'تحديث الالتزام';
      case 'fr':
        return 'Mettre à jour l\'engagement';
      case 'de':
        return 'Verpflichtung aktualisieren';
      case 'ja':
        return 'コミットメントを更新';
      default:
        return 'Update Commitment';
    }
  }

  String get deleteIncomeTitleLabel {
    switch (locale.languageCode) {
      case 'ar':
        return 'حذف الدخل';
      case 'fr':
        return 'Supprimer le revenu';
      case 'de':
        return 'Einkommen löschen';
      case 'ja':
        return '収入を削除';
      default:
        return 'Delete Income';
    }
  }

  String get deleteIncomeConfirmLabel {
    switch (locale.languageCode) {
      case 'ar':
        return 'هل أنت متأكد من حذف سجل الدخل هذا؟ لا يمكن التراجع عن هذا الإجراء.';
      case 'fr':
        return 'Êtes-vous sûr de vouloir supprimer cet enregistrement de revenu ? Cette action est irréversible.';
      case 'de':
        return 'Möchten Sie diesen Einkommenseintrag wirklich löschen? Diese Aktion kann nicht rückgängig gemacht werden.';
      case 'ja':
        return 'この収入記録を削除してもよろしいですか？この操作は元に戻せません。';
      default:
        return 'Are you sure you want to delete this income record? This action cannot be undone.';
    }
  }

  String get deleteCommitmentTitleLabel {
    switch (locale.languageCode) {
      case 'ar':
        return 'حذف الالتزام';
      case 'fr':
        return 'Supprimer l\'engagement';
      case 'de':
        return 'Verpflichtung löschen';
      case 'ja':
        return 'コミットメントを削除';
      default:
        return 'Delete Commitment';
    }
  }

  String get deleteCommitmentConfirmLabel {
    switch (locale.languageCode) {
      case 'ar':
        return 'هل أنت متأكد من حذف هذا الالتزام؟ لا يمكن التراجع عن هذا الإجراء.';
      case 'fr':
        return 'Êtes-vous sûr de vouloir supprimer cet engagement ? Cette action est irréversible.';
      case 'de':
        return 'Möchten Sie diese Verpflichtung wirklich löschen? Diese Aktion kann nicht rückgängig gemacht werden.';
      case 'ja':
        return 'このコミットメントを削除してもよろしいですか？この操作は元に戻せません。';
      default:
        return 'Are you sure you want to delete this commitment? This action cannot be undone.';
    }
  }

  String get incomeDeletedSuccessLabel {
    switch (locale.languageCode) {
      case 'ar':
        return 'تم حذف الدخل بنجاح!';
      case 'fr':
        return 'Revenu supprimé avec succès !';
      case 'de':
        return 'Einkommen erfolgreich gelöscht!';
      case 'ja':
        return '収入が正常に削除されました！';
      default:
        return 'Income deleted successfully!';
    }
  }

  String get commitmentDeletedSuccessLabel {
    switch (locale.languageCode) {
      case 'ar':
        return 'تم حذف الالتزام بنجاح!';
      case 'fr':
        return 'Engagement supprimé avec succès !';
      case 'de':
        return 'Verpflichtung erfolgreich gelöscht!';
      case 'ja':
        return 'コミットメントが正常に削除されました！';
      default:
        return 'Commitment deleted successfully!';
    }
  }

  String errorUpdatingIncomeLabel(String error) {
    switch (locale.languageCode) {
      case 'ar':
        return 'خطأ في تحديث الدخل: $error';
      case 'fr':
        return 'Erreur lors de la mise à jour du revenu : $error';
      case 'de':
        return 'Fehler beim Aktualisieren des Einkommens: $error';
      case 'ja':
        return '収入の更新エラー: $error';
      default:
        return 'Error updating income: $error';
    }
  }

  String errorDeletingIncomeLabel(String error) {
    switch (locale.languageCode) {
      case 'ar':
        return 'خطأ في حذف الدخل: $error';
      case 'fr':
        return 'Erreur lors de la suppression du revenu : $error';
      case 'de':
        return 'Fehler beim Löschen des Einkommens: $error';
      case 'ja':
        return '収入の削除エラー: $error';
      default:
        return 'Error deleting income: $error';
    }
  }

  String errorDeletingCommitmentLabel(String error) {
    switch (locale.languageCode) {
      case 'ar':
        return 'خطأ في حذف الالتزام: $error';
      case 'fr':
        return 'Erreur lors de la suppression de l\'engagement : $error';
      case 'de':
        return 'Fehler beim Löschen der Verpflichtung: $error';
      case 'ja':
        return 'コミットメントの削除エラー: $error';
      default:
        return 'Error deleting commitment: $error';
    }
  }

  String get sourceHintLabel {
    switch (locale.languageCode) {
      case 'ar':
        return 'مثل: راتب، عمل حر';
      case 'fr':
        return 'Ex. : salaire, freelance';
      case 'de':
        return 'Z. B. Gehalt, Freelancer';
      case 'ja':
        return '例: 給与、フリーランス';
      default:
        return 'e.g. Salary, Freelance';
    }
  }

  String get titleHintLabel {
    switch (locale.languageCode) {
      case 'ar':
        return 'مثل: إيجار، فاتورة كهرباء';
      case 'fr':
        return 'Ex. : loyer, facture d\'électricité';
      case 'de':
        return 'Z. B. Miete, Stromrechnung';
      case 'ja':
        return '例: 家賃、電気代';
      default:
        return 'e.g. Rent, Electricity Bill';
    }
  }

  String get commitmentPreviewTitleLabel {
    switch (locale.languageCode) {
      case 'ar':
        return 'عنوان الالتزام';
      case 'fr':
        return 'Titre de l\'engagement';
      case 'de':
        return 'Titel der Verpflichtung';
      case 'ja':
        return 'コミットメントのタイトル';
      default:
        return 'Commitment Title';
    }
  }

  String dueOnLabel(String date) {
    switch (locale.languageCode) {
      case 'ar':
        return 'الاستحقاق: $date';
      case 'fr':
        return 'Échéance : $date';
      case 'de':
        return 'Fällig am: $date';
      case 'ja':
        return '期限: $date';
      default:
        return 'Due: $date';
    }
  }

  String get pleaseEnterIncomeSourceLabel {
    switch (locale.languageCode) {
      case 'ar':
        return 'يرجى إدخال مصدر الدخل';
      case 'fr':
        return 'Veuillez saisir la source de revenu';
      case 'de':
        return 'Bitte geben Sie die Einkommensquelle ein';
      case 'ja':
        return '収入源を入力してください';
      default:
        return 'Please enter income source';
    }
  }

  String get pleaseEnterTitleLabel {
    switch (locale.languageCode) {
      case 'ar':
        return 'يرجى إدخال العنوان';
      case 'fr':
        return 'Veuillez saisir un titre';
      case 'de':
        return 'Bitte geben Sie einen Titel ein';
      case 'ja':
        return 'タイトルを入力してください';
      default:
        return 'Please enter a title';
    }
  }

  String categoryLabel(String category) {
    const labels = {
      'Food': {'ar': 'طعام', 'fr': 'Nourriture', 'de': 'Nahrungsmittel', 'ja': '食べ物'},
      'Coffee': {'ar': 'قهوة', 'fr': 'Café', 'de': 'Kaffee', 'ja': 'コーヒー'},
      'Groceries': {'ar': 'بقالة', 'fr': 'Courses', 'de': 'Lebensmittel', 'ja': '食料品'},
      'Fast Food': {'ar': 'وجبات سريعة', 'fr': 'Restauration rapide', 'de': 'Fast Food', 'ja': 'ファストフード'},
      'Transport': {'ar': 'مواصلات', 'fr': 'Transport', 'de': 'Transport', 'ja': '交通'},
      'Taxi': {'ar': 'تاكسي', 'fr': 'Taxi', 'de': 'Taxi', 'ja': 'タクシー'},
      'Bus': {'ar': 'حافلة', 'fr': 'Bus', 'de': 'Bus', 'ja': 'バス'},
      'Flight': {'ar': 'رحلة طيران', 'fr': 'Vol', 'de': 'Flug', 'ja': 'フライト'},
      'Fuel': {'ar': 'وقود', 'fr': 'Carburant', 'de': 'Kraftstoff', 'ja': '燃料'},
      'Rent': {'ar': 'إيجار', 'fr': 'Loyer', 'de': 'Miete', 'ja': '家賃'},
      'Electricity': {'ar': 'كهرباء', 'fr': 'Électricité', 'de': 'Strom', 'ja': '電気'},
      'Water': {'ar': 'مياه', 'fr': 'Eau', 'de': 'Wasser', 'ja': '水道'},
      'Internet': {'ar': 'إنترنت', 'fr': 'Internet', 'de': 'Internet', 'ja': 'インターネット'},
      'Phone': {'ar': 'هاتف', 'fr': 'Téléphone', 'de': 'Telefon', 'ja': '電話'},
      'Shopping': {'ar': 'تسوق', 'fr': 'Shopping', 'de': 'Einkaufen', 'ja': 'ショッピング'},
      'Clothes': {'ar': 'ملابس', 'fr': 'Vêtements', 'de': 'Kleidung', 'ja': '衣類'},
      'Electronics': {'ar': 'إلكترونيات', 'fr': 'Électronique', 'de': 'Elektronik', 'ja': '電子機器'},
      'Gifts': {'ar': 'هدايا', 'fr': 'Cadeaux', 'de': 'Geschenke', 'ja': 'ギフト'},
      'Entertainment': {'ar': 'ترفيه', 'fr': 'Divertissement', 'de': 'Unterhaltung', 'ja': 'エンターテインメント'},
      'Movies': {'ar': 'أفلام', 'fr': 'Films', 'de': 'Filme', 'ja': '映画'},
      'Games': {'ar': 'ألعاب', 'fr': 'Jeux', 'de': 'Spiele', 'ja': 'ゲーム'},
      'Music': {'ar': 'موسيقى', 'fr': 'Musique', 'de': 'Musik', 'ja': '音楽'},
      'Subscriptions': {'ar': 'اشتراكات', 'fr': 'Abonnements', 'de': 'Abonnements', 'ja': 'サブスクリプション'},
      'Travel': {'ar': 'سفر', 'fr': 'Voyage', 'de': 'Reisen', 'ja': '旅行'},
      'Bills': {'ar': 'فواتير', 'fr': 'Factures', 'de': 'Rechnungen', 'ja': '請求書'},
      'Healthcare': {'ar': 'رعاية صحية', 'fr': 'Santé', 'de': 'Gesundheitswesen', 'ja': '医療'},
      'Medical': {'ar': 'علاج', 'fr': 'Médical', 'de': 'Medizinisch', 'ja': '医療'},
      'Pharmacy': {'ar': 'صيدلية', 'fr': 'Pharmacie', 'de': 'Apotheke', 'ja': '薬局'},
      'Fitness': {'ar': 'لياقة', 'fr': 'Fitness', 'de': 'Fitness', 'ja': 'フィットネス'},
      'Personal Care': {'ar': 'عناية شخصية', 'fr': 'Soins personnels', 'de': 'Körperpflege', 'ja': 'パーソナルケア'},
      'Education': {'ar': 'تعليم', 'fr': 'Éducation', 'de': 'Bildung', 'ja': '教育'},
      'Books': {'ar': 'كتب', 'fr': 'Livres', 'de': 'Bücher', 'ja': '本'},
      'Courses': {'ar': 'دورات', 'fr': 'Cours', 'de': 'Kurse', 'ja': '講座'},
      'Office': {'ar': 'مكتب', 'fr': 'Bureau', 'de': 'Büro', 'ja': 'オフィス'},
      'Taxes': {'ar': 'ضرائب', 'fr': 'Taxes', 'de': 'Steuern', 'ja': '税金'},
      'Insurance': {'ar': 'تأمين', 'fr': 'Assurance', 'de': 'Versicherung', 'ja': '保険'},
      'Investments': {'ar': 'استثمارات', 'fr': 'Investissements', 'de': 'Investitionen', 'ja': '投資'},
      'Fees': {'ar': 'رسوم', 'fr': 'Frais', 'de': 'Gebühren', 'ja': '手数料'},
      'Other': {'ar': 'أخرى', 'fr': 'Autre', 'de': 'Andere', 'ja': 'その他'},
    };
    return labels[category]?[locale.languageCode] ?? category;
  }

  String incomeSourceLabel(String source) {
    const labels = {
      'Salary': {'ar': 'راتب', 'fr': 'Salaire', 'de': 'Gehalt', 'ja': '給与'},
      'Freelance': {'ar': 'عمل حر', 'fr': 'Freelance', 'de': 'Freiberuflich', 'ja': 'フリーランス'},
      'Business': {'ar': 'عمل تجاري', 'fr': 'Entreprise', 'de': 'Geschäft', 'ja': '事業'},
      'Investment': {'ar': 'استثمار', 'fr': 'Investissement', 'de': 'Investition', 'ja': '投資'},
      'Gift': {'ar': 'هدية', 'fr': 'Cadeau', 'de': 'Geschenk', 'ja': 'ギフト'},
      'Bonus': {'ar': 'مكافأة', 'fr': 'Prime', 'de': 'Bonus', 'ja': 'ボーナス'},
      'Other': {'ar': 'أخرى', 'fr': 'Autre', 'de': 'Andere', 'ja': 'その他'},
    };
    return labels[source]?[locale.languageCode] ?? source;
  }

  String historyTypeLabel(String type) {
    switch (type) {
      case 'Income':
        return income;
      case 'Expense':
        return expenses;
      case 'Commitment':
        return commitments;
      default:
        return type;
    }
  }

  String spentLabel(String amount) {
    switch (locale.languageCode) {
      case 'ar':
        return 'صرفت: $amount';
      case 'fr':
        return 'Dépensé: $amount';
      case 'de':
        return 'Ausgegeben: $amount';
      case 'ja':
        return '支出: $amount';
      default:
        return 'Spent: $amount';
    }
  }

  String earnedLabel(String amount) {
    switch (locale.languageCode) {
      case 'ar':
        return 'كسبت: $amount';
      case 'fr':
        return 'Gagné: $amount';
      case 'de':
        return 'Verdient: $amount';
      case 'ja':
        return '収入: $amount';
      default:
        return 'Earned: $amount';
    }
  }

  String categoryGroupLabel(String group) {
    const labels = {
      'Food & Dining': {'ar': 'الطعام والمطاعم', 'fr': 'Cuisine et restauration', 'de': 'Essen und Gastronomie', 'ja': '食事と外食'},
      'Transport': {'ar': 'المواصلات', 'fr': 'Transport', 'de': 'Transport', 'ja': '交通'},
      'Home & Utilities': {'ar': 'المنزل والمرافق', 'fr': 'Maison et services', 'de': 'Haushalt und Nebenkosten', 'ja': '住居と公共料金'},
      'Shopping': {'ar': 'التسوق', 'fr': 'Shopping', 'de': 'Einkaufen', 'ja': 'ショッピング'},
      'Health & Wellness': {'ar': 'الصحة والعافية', 'fr': 'Santé et bien-être', 'de': 'Gesundheit und Wohlbefinden', 'ja': '健康とウェルネス'},
      'Education & Work': {'ar': 'التعليم والعمل', 'fr': 'Éducation et travail', 'de': 'Bildung und Arbeit', 'ja': '教育と仕事'},
      'Entertainment': {'ar': 'الترفيه', 'fr': 'Divertissement', 'de': 'Unterhaltung', 'ja': 'エンターテインメント'},
      'Finance': {'ar': 'الماليات', 'fr': 'Finance', 'de': 'Finanzen', 'ja': '金融'},
    };
    return labels[group]?[locale.languageCode] ?? group;
  }

  String get permissionWelcomeTitle {
    switch (locale.languageCode) {
      case 'ar':
        return 'مرحبًا بك في Money Follow';
      case 'fr':
        return 'Bienvenue dans Money Follow';
      case 'de':
        return 'Willkommen bei Money Follow';
      case 'ja':
        return 'Money Followへようこそ';
      default:
        return 'Welcome to Money Follow';
    }
  }

  String get permissionStartupExplanation {
    switch (locale.languageCode) {
      case 'ar':
        return 'لأفضل تجربة، نحتاج إذن الوصول إلى الملفات من أجل:';
      case 'fr':
        return 'Pour une meilleure expérience, nous avons besoin de l\'autorisation d\'accès aux fichiers pour :';
      case 'de':
        return 'Für ein besseres Erlebnis benötigen wir Dateizugriff für:';
      case 'ja':
        return 'より良い体験のため、次の用途でファイルへのアクセス許可が必要です:';
      default:
        return 'For the best experience, we need file access permission to:';
    }
  }

  List<String> get permissionStartupReasons {
    switch (locale.languageCode) {
      case 'ar':
        return const [
          'إنشاء نسخ احتياطية لبياناتك المالية',
          'استيراد النسخ الاحتياطية السابقة',
          'مشاركة البيانات بين الأجهزة',
        ];
      case 'fr':
        return const [
          'Créer des sauvegardes de vos données financières',
          'Importer des sauvegardes existantes',
          'Partager des données entre appareils',
        ];
      case 'de':
        return const [
          'Sicherungen Ihrer Finanzdaten erstellen',
          'Vorhandene Sicherungen importieren',
          'Daten zwischen Geräten teilen',
        ];
      case 'ja':
        return const [
          '財務データのバックアップを作成する',
          '既存のバックアップを復元する',
          'データをデバイス間で共有する',
        ];
      default:
        return const [
          'Create backups of your financial data',
          'Import previous backups',
          'Share data between devices',
        ];
    }
  }

  String get permissionStartupFooter {
    switch (locale.languageCode) {
      case 'ar':
        return 'يمكنك الرفض الآن، لكن ميزات النسخ الاحتياطي والاستيراد ستبقى محدودة.';
      case 'fr':
        return 'Vous pouvez refuser maintenant, mais les fonctions de sauvegarde et de restauration resteront limitées.';
      case 'de':
        return 'Sie können jetzt ablehnen, aber Backup- und Wiederherstellungsfunktionen bleiben eingeschränkt.';
      case 'ja':
        return '今は拒否できますが、バックアップと復元の機能は制限されます。';
      default:
        return 'You can decline for now, but backup and restore features will remain limited.';
    }
  }

  String get skipForNowLabel {
    switch (locale.languageCode) {
      case 'ar':
        return 'تخطي الآن';
      case 'fr':
        return 'Ignorer pour le moment';
      case 'de':
        return 'Jetzt überspringen';
      case 'ja':
        return '今はスキップ';
      default:
        return 'Skip for now';
    }
  }

  String get grantPermissionLabel {
    switch (locale.languageCode) {
      case 'ar':
        return 'منح الإذن';
      case 'fr':
        return 'Accorder l\'autorisation';
      case 'de':
        return 'Berechtigung erteilen';
      case 'ja':
        return '許可する';
      default:
        return 'Grant permission';
    }
  }

  String get backupPermissionTitle {
    switch (locale.languageCode) {
      case 'ar':
        return 'إذن الوصول للملفات مطلوب';
      case 'fr':
        return 'Autorisation d\'accès aux fichiers requise';
      case 'de':
        return 'Dateizugriff erforderlich';
      case 'ja':
        return 'ファイルアクセス権限が必要です';
      default:
        return 'File access permission required';
    }
  }

  String get backupPermissionExplanation {
    switch (locale.languageCode) {
      case 'ar':
        return 'لاستخدام ميزات النسخ الاحتياطي، نحتاج إلى إذن الوصول إلى ملفات الجهاز.';
      case 'fr':
        return 'Pour utiliser les fonctions de sauvegarde, nous avons besoin de l\'autorisation d\'accéder aux fichiers de l\'appareil.';
      case 'de':
        return 'Für die Nutzung der Backup-Funktionen benötigen wir Zugriff auf die Dateien Ihres Geräts.';
      case 'ja':
        return 'バックアップ機能を使うには、端末ファイルへのアクセス許可が必要です。';
      default:
        return 'To use backup features, we need permission to access files on your device.';
    }
  }

  String get permissionRequiredForLabel {
    switch (locale.languageCode) {
      case 'ar':
        return 'هذا الإذن مطلوب من أجل:';
      case 'fr':
        return 'Cette autorisation est nécessaire pour :';
      case 'de':
        return 'Diese Berechtigung wird benötigt für:';
      case 'ja':
        return 'この権限は次のために必要です:';
      default:
        return 'This permission is required to:';
    }
  }

  List<String> get backupPermissionReasons {
    switch (locale.languageCode) {
      case 'ar':
        return const [
          'حفظ ملفات النسخ الاحتياطية',
          'قراءة ملفات النسخ الاحتياطية',
          'مشاركة بياناتك',
        ];
      case 'fr':
        return const [
          'Enregistrer les fichiers de sauvegarde',
          'Lire les fichiers de sauvegarde',
          'Partager vos données',
        ];
      case 'de':
        return const [
          'Backup-Dateien speichern',
          'Backup-Dateien lesen',
          'Ihre Daten teilen',
        ];
      case 'ja':
        return const [
          'バックアップファイルを保存する',
          'バックアップファイルを読み取る',
          'データを共有する',
        ];
      default:
        return const [
          'Save backup files',
          'Read backup files',
          'Share your data',
        ];
    }
  }

  String get closeLabel {
    switch (locale.languageCode) {
      case 'ar':
        return 'إلغاء';
      case 'fr':
        return 'Annuler';
      case 'de':
        return 'Abbrechen';
      case 'ja':
        return 'キャンセル';
      default:
        return 'Cancel';
    }
  }

  String get permissionDeniedTitle {
    switch (locale.languageCode) {
      case 'ar':
        return 'تم رفض الإذن';
      case 'fr':
        return 'Autorisation refusée';
      case 'de':
        return 'Berechtigung verweigert';
      case 'ja':
        return '権限が拒否されました';
      default:
        return 'Permission denied';
    }
  }

  String get permissionDeniedMessage {
    switch (locale.languageCode) {
      case 'ar':
        return 'لاستخدام النسخ الاحتياطي والاستيراد، يرجى منح إذن الوصول إلى الملفات من إعدادات التطبيق.';
      case 'fr':
        return 'Pour utiliser la sauvegarde et la restauration, veuillez accorder l\'accès aux fichiers depuis les paramètres de l\'application.';
      case 'de':
        return 'Um Backup und Wiederherstellung zu nutzen, gewähren Sie bitte den Dateizugriff in den App-Einstellungen.';
      case 'ja':
        return 'バックアップと復元を使うには、アプリ設定からファイルアクセス権限を付与してください。';
      default:
        return 'To use backup and restore, please grant file access from the app settings.';
    }
  }

  String get permissionDeniedHint {
    switch (locale.languageCode) {
      case 'ar':
        return 'يمكنك فتح الإعدادات الآن أو المتابعة بدون هذه الميزة.';
      case 'fr':
        return 'Vous pouvez ouvrir les paramètres maintenant ou continuer sans cette fonctionnalité.';
      case 'de':
        return 'Sie können jetzt die Einstellungen öffnen oder ohne diese Funktion fortfahren.';
      case 'ja':
        return '今すぐ設定を開くか、この機能なしで続行できます。';
      default:
        return 'You can open settings now or continue without this feature.';
    }
  }

  String get continueWithoutPermissionLabel {
    switch (locale.languageCode) {
      case 'ar':
        return 'المتابعة بدون الإذن';
      case 'fr':
        return 'Continuer sans autorisation';
      case 'de':
        return 'Ohne Berechtigung fortfahren';
      case 'ja':
        return '権限なしで続行';
      default:
        return 'Continue without permission';
    }
  }

  String get openSettingsLabel {
    switch (locale.languageCode) {
      case 'ar':
        return 'فتح الإعدادات';
      case 'fr':
        return 'Ouvrir les paramètres';
      case 'de':
        return 'Einstellungen öffnen';
      case 'ja':
        return '設定を開く';
      default:
        return 'Open settings';
    }
  }

  String get permissionsGrantedTitle {
    switch (locale.languageCode) {
      case 'ar':
        return 'الصلاحيات ممنوحة';
      case 'fr':
        return 'Autorisations accordées';
      case 'de':
        return 'Berechtigungen erteilt';
      case 'ja':
        return '権限は付与されています';
      default:
        return 'Permissions granted';
    }
  }

  String get permissionsDeniedTitle {
    switch (locale.languageCode) {
      case 'ar':
        return 'الصلاحيات مرفوضة';
      case 'fr':
        return 'Autorisations refusées';
      case 'de':
        return 'Berechtigungen verweigert';
      case 'ja':
        return '権限は拒否されています';
      default:
        return 'Permissions denied';
    }
  }

  String get permissionsGrantedMessage {
    switch (locale.languageCode) {
      case 'ar':
        return 'تم منح جميع الصلاحيات المطلوبة، ويمكنك الآن استخدام ميزات النسخ الاحتياطي كاملة.';
      case 'fr':
        return 'Toutes les autorisations requises ont été accordées et vous pouvez utiliser toutes les fonctions de sauvegarde.';
      case 'de':
        return 'Alle erforderlichen Berechtigungen wurden erteilt. Sie können jetzt alle Backup-Funktionen nutzen.';
      case 'ja':
        return '必要な権限はすべて付与されています。バックアップ機能をすべて利用できます。';
      default:
        return 'All required permissions have been granted. You can now use all backup features.';
    }
  }

  String get permissionsDeniedMessage {
    switch (locale.languageCode) {
      case 'ar':
        return 'لم يتم منح صلاحيات الوصول للملفات، لذلك ستبقى ميزات النسخ الاحتياطي محدودة.';
      case 'fr':
        return 'L\'accès aux fichiers n\'a pas été accordé. Les fonctions de sauvegarde resteront limitées.';
      case 'de':
        return 'Der Dateizugriff wurde nicht gewährt. Backup-Funktionen bleiben eingeschränkt.';
      case 'ja':
        return 'ファイルアクセス権限が付与されていないため、バックアップ機能は制限されます。';
      default:
        return 'File access permissions were not granted, so backup features will remain limited.';
    }
  }

  String get permissionsDeniedHint {
    switch (locale.languageCode) {
      case 'ar':
        return 'لتفعيل كل الميزات، امنح الصلاحية من إعدادات التطبيق.';
      case 'fr':
        return 'Pour activer toutes les fonctionnalités, accordez l\'autorisation depuis les paramètres de l\'application.';
      case 'de':
        return 'Um alle Funktionen zu aktivieren, erteilen Sie die Berechtigung in den App-Einstellungen.';
      case 'ja':
        return 'すべての機能を使うには、アプリ設定から権限を付与してください。';
      default:
        return 'To unlock all features, grant permission from the app settings.';
    }
  }

  String get okLabel {
    switch (locale.languageCode) {
      case 'ar':
        return 'موافق';
      case 'fr':
        return 'OK';
      case 'de':
        return 'OK';
      case 'ja':
        return 'OK';
      default:
        return 'OK';
    }
  }
}
