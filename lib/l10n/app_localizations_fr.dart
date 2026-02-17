// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'Suivi d\'Argent';

  @override
  String get overview => 'Aperçu';

  @override
  String get totalBalance => 'Solde Total';

  @override
  String get thisMonth => 'Ce Mois';

  @override
  String get income => 'Revenus';

  @override
  String get expenses => 'Dépenses';

  @override
  String get commitments => 'Engagements';

  @override
  String get history => 'Historique';

  @override
  String get settings => 'Paramètres';

  @override
  String get addIncome => 'Ajouter Revenu';

  @override
  String get addExpense => 'Ajouter Dépense';

  @override
  String get addCommitment => 'Ajouter Engagement';

  @override
  String get editIncome => 'Modifier Revenu';

  @override
  String get editExpense => 'Modifier Dépense';

  @override
  String get editCommitment => 'Modifier Engagement';

  @override
  String get amount => 'Montant';

  @override
  String get source => 'Source';

  @override
  String get category => 'Catégorie';

  @override
  String get date => 'Date';

  @override
  String get dueDate => 'Date d\'Échéance';

  @override
  String get notes => 'Notes';

  @override
  String get title => 'Titre';

  @override
  String get quickSelect => 'Sélection Rapide';

  @override
  String get save => 'Enregistrer';

  @override
  String get update => 'Mettre à Jour';

  @override
  String get delete => 'Supprimer';

  @override
  String get cancel => 'Annuler';

  @override
  String get saveIncome => 'Enregistrer Revenu';

  @override
  String get saveExpense => 'Enregistrer Dépense';

  @override
  String get saveCommitment => 'Enregistrer Engagement';

  @override
  String get updateIncome => 'Mettre à Jour Revenu';

  @override
  String get updateExpense => 'Mettre à Jour Dépense';

  @override
  String get updateCommitment => 'Mettre à Jour Engagement';

  @override
  String get deleteIncome => 'Supprimer Revenu';

  @override
  String get deleteExpense => 'Supprimer Dépense';

  @override
  String get deleteCommitment => 'Supprimer Engagement';

  @override
  String get deleteIncomeConfirm =>
      'Êtes-vous sûr de vouloir supprimer cet enregistrement de revenu ? Cette action ne peut pas être annulée.';

  @override
  String get deleteExpenseConfirm =>
      'Êtes-vous sûr de vouloir supprimer cet enregistrement de dépense ? Cette action ne peut pas être annulée.';

  @override
  String get deleteCommitmentConfirm =>
      'Êtes-vous sûr de vouloir supprimer cet engagement ? Cette action ne peut pas être annulée.';

  @override
  String get incomeUpdatedSuccess => 'Revenu mis à jour avec succès !';

  @override
  String get expenseUpdatedSuccess => 'Dépense mise à jour avec succès !';

  @override
  String get commitmentUpdatedSuccess => 'Engagement mis à jour avec succès !';

  @override
  String get incomeDeletedSuccess => 'Revenu supprimé avec succès !';

  @override
  String get expenseDeletedSuccess => 'Dépense supprimée avec succès !';

  @override
  String get commitmentDeletedSuccess => 'Engagement supprimé avec succès !';

  @override
  String get incomeSavedSuccess => 'Revenu enregistré avec succès !';

  @override
  String get expenseSavedSuccess => 'Dépense enregistrée avec succès !';

  @override
  String get commitmentSavedSuccess => 'Engagement enregistré avec succès !';

  @override
  String errorUpdatingIncome(String error) {
    return 'Erreur lors de la mise à jour du revenu : $error';
  }

  @override
  String errorUpdatingExpense(String error) {
    return 'Erreur lors de la mise à jour de la dépense : $error';
  }

  @override
  String errorUpdatingCommitment(String error) {
    return 'Erreur lors de la mise à jour de l\'engagement : $error';
  }

  @override
  String errorDeletingIncome(String error) {
    return 'Erreur lors de la suppression du revenu : $error';
  }

  @override
  String errorDeletingExpense(String error) {
    return 'Erreur lors de la suppression de la dépense : $error';
  }

  @override
  String errorDeletingCommitment(String error) {
    return 'Erreur lors de la suppression de l\'engagement : $error';
  }

  @override
  String errorSavingIncome(String error) {
    return 'Erreur lors de l\'enregistrement du revenu : $error';
  }

  @override
  String errorSavingExpense(String error) {
    return 'Erreur lors de l\'enregistrement de la dépense : $error';
  }

  @override
  String errorSavingCommitment(String error) {
    return 'Erreur lors de l\'enregistrement de l\'engagement : $error';
  }

  @override
  String get transactionHistory => 'Historique des Transactions';

  @override
  String get noTransactionsYet => 'Aucune transaction pour le moment';

  @override
  String get startAddingTransactions =>
      'Commencez à ajouter des revenus, dépenses ou engagements';

  @override
  String get noCommitmentsYet => 'Aucun engagement pour le moment';

  @override
  String get addYourBills =>
      'Ajoutez vos factures, loyer et autres engagements';

  @override
  String get today => 'Aujourd\'hui';

  @override
  String get yesterday => 'Hier';

  @override
  String get upcoming => 'À Venir';

  @override
  String get overdue => 'EN RETARD';

  @override
  String items(int count) {
    return '$count éléments';
  }

  @override
  String get all => 'Tout';

  @override
  String get food => 'Nourriture';

  @override
  String get transport => 'Transport';

  @override
  String get shopping => 'Shopping';

  @override
  String get entertainment => 'Divertissement';

  @override
  String get bills => 'Factures';

  @override
  String get healthcare => 'Santé';

  @override
  String get education => 'Éducation';

  @override
  String get other => 'Autre';

  @override
  String get salary => 'Salaire';

  @override
  String get freelance => 'Freelance';

  @override
  String get business => 'Entreprise';

  @override
  String get investment => 'Investissement';

  @override
  String get gift => 'Cadeau';

  @override
  String get bonus => 'Prime';

  @override
  String get pleaseEnterAmount => 'Veuillez saisir un montant';

  @override
  String get pleaseEnterValidNumber => 'Veuillez saisir un nombre valide';

  @override
  String get amountMustBeGreaterThanZero =>
      'Le montant doit être supérieur à zéro';

  @override
  String get pleaseEnterIncomeSource => 'Veuillez saisir la source de revenu';

  @override
  String get pleaseEnterTitle => 'Veuillez saisir un titre';

  @override
  String get addNote => 'Ajouter une note...';

  @override
  String get appearance => 'Apparence';

  @override
  String get language => 'Langue';

  @override
  String get currency => 'Devise';

  @override
  String get darkMode => 'Mode Sombre';

  @override
  String get darkThemeEnabled => 'Thème sombre activé';

  @override
  String get lightThemeEnabled => 'Thème clair activé';

  @override
  String get about => 'À Propos';

  @override
  String get version => 'Version';

  @override
  String get appDescription =>
      'Une application simple et élégante de suivi d\'argent pour vous aider à gérer vos finances.';

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
  String get statistics => 'Statistiques';

  @override
  String get financialStatistics => 'Statistiques Financières';

  @override
  String get quickOverview => 'Aperçu Rapide';

  @override
  String get todaySpent => 'Aujourd\'hui';

  @override
  String get thisWeekSpent => 'Cette Semaine';

  @override
  String get thisMonthSpent => 'Ce Mois';

  @override
  String monthlyReport(Object month) {
    return 'Rapport $month';
  }

  @override
  String get totalExpenses => 'Total des Dépenses';

  @override
  String get statisticsCalculatedFromStart =>
      'Les statistiques sont calculées du début du mois à aujourd\'hui';

  @override
  String get currentWeekBreakdown => 'Répartition de la Semaine Actuelle';

  @override
  String get weekTotal => 'Total de la Semaine';

  @override
  String get dailyAverage => 'Moyenne Quotidienne';

  @override
  String get dailyActivity => 'Activité Quotidienne';

  @override
  String get noTransactionsRecorded => 'Aucune transaction enregistrée';

  @override
  String netAmount(Object amount) {
    return 'Net: $amount';
  }

  @override
  String spent(Object amount) {
    return 'Dépensé: $amount';
  }

  @override
  String earned(Object amount) {
    return 'Gagné: $amount';
  }

  @override
  String get errorLoadingStatistics =>
      'Erreur lors du chargement des statistiques';

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
