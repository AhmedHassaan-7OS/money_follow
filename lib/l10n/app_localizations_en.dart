// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Money Follow';

  @override
  String get overview => 'Overview';

  @override
  String get totalBalance => 'Total Balance';

  @override
  String get thisMonth => 'This Month';

  @override
  String get income => 'Income';

  @override
  String get expenses => 'Expenses';

  @override
  String get commitments => 'Commitments';

  @override
  String get history => 'History';

  @override
  String get settings => 'Settings';

  @override
  String get addIncome => 'Add Income';

  @override
  String get addExpense => 'Add Expense';

  @override
  String get addCommitment => 'Add Commitment';

  @override
  String get editIncome => 'Edit Income';

  @override
  String get editExpense => 'Edit Expense';

  @override
  String get editCommitment => 'Edit Commitment';

  @override
  String get amount => 'Amount';

  @override
  String get source => 'Source';

  @override
  String get category => 'Category';

  @override
  String get date => 'Date';

  @override
  String get dueDate => 'Due Date';

  @override
  String get notes => 'Notes';

  @override
  String get title => 'Title';

  @override
  String get quickSelect => 'Quick Select';

  @override
  String get save => 'Save';

  @override
  String get update => 'Update';

  @override
  String get delete => 'Delete';

  @override
  String get cancel => 'Cancel';

  @override
  String get saveIncome => 'Save Income';

  @override
  String get saveExpense => 'Save Expense';

  @override
  String get saveCommitment => 'Save Commitment';

  @override
  String get updateIncome => 'Update Income';

  @override
  String get updateExpense => 'Update Expense';

  @override
  String get updateCommitment => 'Update Commitment';

  @override
  String get deleteIncome => 'Delete Income';

  @override
  String get deleteExpense => 'Delete Expense';

  @override
  String get deleteCommitment => 'Delete Commitment';

  @override
  String get deleteIncomeConfirm =>
      'Are you sure you want to delete this income record? This action cannot be undone.';

  @override
  String get deleteExpenseConfirm =>
      'Are you sure you want to delete this expense record? This action cannot be undone.';

  @override
  String get deleteCommitmentConfirm =>
      'Are you sure you want to delete this commitment? This action cannot be undone.';

  @override
  String get incomeUpdatedSuccess => 'Income updated successfully!';

  @override
  String get expenseUpdatedSuccess => 'Expense updated successfully!';

  @override
  String get commitmentUpdatedSuccess => 'Commitment updated successfully!';

  @override
  String get incomeDeletedSuccess => 'Income deleted successfully!';

  @override
  String get expenseDeletedSuccess => 'Expense deleted successfully!';

  @override
  String get commitmentDeletedSuccess => 'Commitment deleted successfully!';

  @override
  String get incomeSavedSuccess => 'Income saved successfully!';

  @override
  String get expenseSavedSuccess => 'Expense saved successfully!';

  @override
  String get commitmentSavedSuccess => 'Commitment saved successfully!';

  @override
  String errorUpdatingIncome(String error) {
    return 'Error updating income: $error';
  }

  @override
  String errorUpdatingExpense(String error) {
    return 'Error updating expense: $error';
  }

  @override
  String errorUpdatingCommitment(String error) {
    return 'Error updating commitment: $error';
  }

  @override
  String errorDeletingIncome(String error) {
    return 'Error deleting income: $error';
  }

  @override
  String errorDeletingExpense(String error) {
    return 'Error deleting expense: $error';
  }

  @override
  String errorDeletingCommitment(String error) {
    return 'Error deleting commitment: $error';
  }

  @override
  String errorSavingIncome(String error) {
    return 'Error saving income: $error';
  }

  @override
  String errorSavingExpense(String error) {
    return 'Error saving expense: $error';
  }

  @override
  String errorSavingCommitment(String error) {
    return 'Error saving commitment: $error';
  }

  @override
  String get transactionHistory => 'Transaction History';

  @override
  String get noTransactionsYet => 'No transactions yet';

  @override
  String get startAddingTransactions =>
      'Start adding income, expenses, or commitments';

  @override
  String get noCommitmentsYet => 'No commitments yet';

  @override
  String get addYourBills => 'Add your bills, rent, and other commitments';

  @override
  String get today => 'Today';

  @override
  String get yesterday => 'Yesterday';

  @override
  String get upcoming => 'Upcoming';

  @override
  String get overdue => 'OVERDUE';

  @override
  String items(int count) {
    return '$count items';
  }

  @override
  String get all => 'All';

  @override
  String get food => 'Food';

  @override
  String get transport => 'Transport';

  @override
  String get shopping => 'Shopping';

  @override
  String get entertainment => 'Entertainment';

  @override
  String get bills => 'Bills';

  @override
  String get healthcare => 'Healthcare';

  @override
  String get education => 'Education';

  @override
  String get other => 'Other';

  @override
  String get salary => 'Salary';

  @override
  String get freelance => 'Freelance';

  @override
  String get business => 'Business';

  @override
  String get investment => 'Investment';

  @override
  String get gift => 'Gift';

  @override
  String get bonus => 'Bonus';

  @override
  String get pleaseEnterAmount => 'Please enter an amount';

  @override
  String get pleaseEnterValidNumber => 'Please enter a valid number';

  @override
  String get amountMustBeGreaterThanZero => 'Amount must be greater than 0';

  @override
  String get pleaseEnterIncomeSource => 'Please enter income source';

  @override
  String get pleaseEnterTitle => 'Please enter a title';

  @override
  String get addNote => 'Add a note...';

  @override
  String get appearance => 'Appearance';

  @override
  String get language => 'Language';

  @override
  String get currency => 'Currency';

  @override
  String get darkMode => 'Dark Mode';

  @override
  String get darkThemeEnabled => 'Dark theme enabled';

  @override
  String get lightThemeEnabled => 'Light theme enabled';

  @override
  String get about => 'About';

  @override
  String get version => 'Version';

  @override
  String get appDescription =>
      'A simple and elegant money tracking app to help you manage your finances.';

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
