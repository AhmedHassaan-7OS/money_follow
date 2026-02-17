// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appTitle => 'Geld Verfolgen';

  @override
  String get overview => 'Übersicht';

  @override
  String get totalBalance => 'Gesamtsaldo';

  @override
  String get thisMonth => 'Dieser Monat';

  @override
  String get income => 'Einkommen';

  @override
  String get expenses => 'Ausgaben';

  @override
  String get commitments => 'Verpflichtungen';

  @override
  String get history => 'Verlauf';

  @override
  String get settings => 'Einstellungen';

  @override
  String get addIncome => 'Einkommen Hinzufügen';

  @override
  String get addExpense => 'Ausgabe Hinzufügen';

  @override
  String get addCommitment => 'Verpflichtung Hinzufügen';

  @override
  String get editIncome => 'Einkommen Bearbeiten';

  @override
  String get editExpense => 'Ausgabe Bearbeiten';

  @override
  String get editCommitment => 'Verpflichtung Bearbeiten';

  @override
  String get amount => 'Betrag';

  @override
  String get source => 'Quelle';

  @override
  String get category => 'Kategorie';

  @override
  String get date => 'Datum';

  @override
  String get dueDate => 'Fälligkeitsdatum';

  @override
  String get notes => 'Notizen';

  @override
  String get title => 'Titel';

  @override
  String get quickSelect => 'Schnellauswahl';

  @override
  String get save => 'Speichern';

  @override
  String get update => 'Aktualisieren';

  @override
  String get delete => 'Löschen';

  @override
  String get cancel => 'Abbrechen';

  @override
  String get saveIncome => 'Einkommen Speichern';

  @override
  String get saveExpense => 'Ausgabe Speichern';

  @override
  String get saveCommitment => 'Verpflichtung Speichern';

  @override
  String get updateIncome => 'Einkommen Aktualisieren';

  @override
  String get updateExpense => 'Ausgabe Aktualisieren';

  @override
  String get updateCommitment => 'Verpflichtung Aktualisieren';

  @override
  String get deleteIncome => 'Einkommen Löschen';

  @override
  String get deleteExpense => 'Ausgabe Löschen';

  @override
  String get deleteCommitment => 'Verpflichtung Löschen';

  @override
  String get deleteIncomeConfirm =>
      'Sind Sie sicher, dass Sie diesen Einkommensdatensatz löschen möchten? Diese Aktion kann nicht rückgängig gemacht werden.';

  @override
  String get deleteExpenseConfirm =>
      'Sind Sie sicher, dass Sie diesen Ausgabendatensatz löschen möchten? Diese Aktion kann nicht rückgängig gemacht werden.';

  @override
  String get deleteCommitmentConfirm =>
      'Sind Sie sicher, dass Sie diese Verpflichtung löschen möchten? Diese Aktion kann nicht rückgängig gemacht werden.';

  @override
  String get incomeUpdatedSuccess => 'Einkommen erfolgreich aktualisiert!';

  @override
  String get expenseUpdatedSuccess => 'Ausgabe erfolgreich aktualisiert!';

  @override
  String get commitmentUpdatedSuccess =>
      'Verpflichtung erfolgreich aktualisiert!';

  @override
  String get incomeDeletedSuccess => 'Einkommen erfolgreich gelöscht!';

  @override
  String get expenseDeletedSuccess => 'Ausgabe erfolgreich gelöscht!';

  @override
  String get commitmentDeletedSuccess => 'Verpflichtung erfolgreich gelöscht!';

  @override
  String get incomeSavedSuccess => 'Einkommen erfolgreich gespeichert!';

  @override
  String get expenseSavedSuccess => 'Ausgabe erfolgreich gespeichert!';

  @override
  String get commitmentSavedSuccess => 'Verpflichtung erfolgreich gespeichert!';

  @override
  String errorUpdatingIncome(String error) {
    return 'Fehler beim Aktualisieren des Einkommens: $error';
  }

  @override
  String errorUpdatingExpense(String error) {
    return 'Fehler beim Aktualisieren der Ausgabe: $error';
  }

  @override
  String errorUpdatingCommitment(String error) {
    return 'Fehler beim Aktualisieren der Verpflichtung: $error';
  }

  @override
  String errorDeletingIncome(String error) {
    return 'Fehler beim Löschen des Einkommens: $error';
  }

  @override
  String errorDeletingExpense(String error) {
    return 'Fehler beim Löschen der Ausgabe: $error';
  }

  @override
  String errorDeletingCommitment(String error) {
    return 'Fehler beim Löschen der Verpflichtung: $error';
  }

  @override
  String errorSavingIncome(String error) {
    return 'Fehler beim Speichern des Einkommens: $error';
  }

  @override
  String errorSavingExpense(String error) {
    return 'Fehler beim Speichern der Ausgabe: $error';
  }

  @override
  String errorSavingCommitment(String error) {
    return 'Fehler beim Speichern der Verpflichtung: $error';
  }

  @override
  String get transactionHistory => 'Transaktionsverlauf';

  @override
  String get noTransactionsYet => 'Noch keine Transaktionen';

  @override
  String get startAddingTransactions =>
      'Beginnen Sie mit dem Hinzufügen von Einkommen, Ausgaben oder Verpflichtungen';

  @override
  String get noCommitmentsYet => 'Noch keine Verpflichtungen';

  @override
  String get addYourBills =>
      'Fügen Sie Ihre Rechnungen, Miete und andere Verpflichtungen hinzu';

  @override
  String get today => 'Heute';

  @override
  String get yesterday => 'Gestern';

  @override
  String get upcoming => 'Bevorstehend';

  @override
  String get overdue => 'ÜBERFÄLLIG';

  @override
  String items(int count) {
    return '$count Artikel';
  }

  @override
  String get all => 'Alle';

  @override
  String get food => 'Essen';

  @override
  String get transport => 'Transport';

  @override
  String get shopping => 'Einkaufen';

  @override
  String get entertainment => 'Unterhaltung';

  @override
  String get bills => 'Rechnungen';

  @override
  String get healthcare => 'Gesundheitswesen';

  @override
  String get education => 'Bildung';

  @override
  String get other => 'Andere';

  @override
  String get salary => 'Gehalt';

  @override
  String get freelance => 'Freiberuflich';

  @override
  String get business => 'Geschäft';

  @override
  String get investment => 'Investition';

  @override
  String get gift => 'Geschenk';

  @override
  String get bonus => 'Bonus';

  @override
  String get pleaseEnterAmount => 'Bitte geben Sie einen Betrag ein';

  @override
  String get pleaseEnterValidNumber => 'Bitte geben Sie eine gültige Zahl ein';

  @override
  String get amountMustBeGreaterThanZero =>
      'Der Betrag muss größer als null sein';

  @override
  String get pleaseEnterIncomeSource =>
      'Bitte geben Sie die Einkommensquelle ein';

  @override
  String get pleaseEnterTitle => 'Bitte geben Sie einen Titel ein';

  @override
  String get addNote => 'Notiz hinzufügen...';

  @override
  String get appearance => 'Erscheinungsbild';

  @override
  String get language => 'Sprache';

  @override
  String get currency => 'Währung';

  @override
  String get darkMode => 'Dunkler Modus';

  @override
  String get darkThemeEnabled => 'Dunkles Design aktiviert';

  @override
  String get lightThemeEnabled => 'Helles Design aktiviert';

  @override
  String get about => 'Über';

  @override
  String get version => 'Version';

  @override
  String get appDescription =>
      'Eine einfache und elegante Geld-Tracking-App, die Ihnen bei der Verwaltung Ihrer Finanzen hilft.';

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

  @override
  String get statistics => 'Statistiken';

  @override
  String get financialStatistics => 'Finanzstatistiken';

  @override
  String get quickOverview => 'Schnellübersicht';

  @override
  String get todaySpent => 'Heute';

  @override
  String get thisWeekSpent => 'Diese Woche';

  @override
  String get thisMonthSpent => 'Dieser Monat';

  @override
  String monthlyReport(Object month) {
    return '$month Bericht';
  }

  @override
  String get totalExpenses => 'Gesamtausgaben';

  @override
  String get statisticsCalculatedFromStart =>
      'Statistiken werden vom Monatsanfang bis heute berechnet';

  @override
  String get currentWeekBreakdown => 'Aufschlüsselung der aktuellen Woche';

  @override
  String get weekTotal => 'Wochensumme';

  @override
  String get dailyAverage => 'Tagesdurchschnitt';

  @override
  String get dailyActivity => 'Tägliche Aktivität';

  @override
  String get noTransactionsRecorded => 'Keine Transaktionen aufgezeichnet';

  @override
  String netAmount(Object amount) {
    return 'Netto: $amount';
  }

  @override
  String spent(Object amount) {
    return 'Ausgegeben: $amount';
  }

  @override
  String earned(Object amount) {
    return 'Verdient: $amount';
  }

  @override
  String get errorLoadingStatistics => 'Fehler beim Laden der Statistiken';

  @override
  String get markAsCompleted => 'Mark as Completed';

  @override
  String get markAsPending => 'Mark as Pending';

  @override
  String get commitmentCompleted => 'Commitment marked as completed!';

  @override
  String get commitmentPending => 'Commitment marked as pending!';

  @override
  String get undo => 'Undo';
}
