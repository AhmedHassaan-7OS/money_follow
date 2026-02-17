// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get appTitle => 'マネーフォロー';

  @override
  String get overview => '概要';

  @override
  String get totalBalance => '総残高';

  @override
  String get thisMonth => '今月';

  @override
  String get income => '収入';

  @override
  String get expenses => '支出';

  @override
  String get commitments => 'コミットメント';

  @override
  String get history => '履歴';

  @override
  String get settings => '設定';

  @override
  String get addIncome => '収入を追加';

  @override
  String get addExpense => '支出を追加';

  @override
  String get addCommitment => 'コミットメントを追加';

  @override
  String get editIncome => '収入を編集';

  @override
  String get editExpense => '支出を編集';

  @override
  String get editCommitment => 'コミットメントを編集';

  @override
  String get amount => '金額';

  @override
  String get source => 'ソース';

  @override
  String get category => 'カテゴリ';

  @override
  String get date => '日付';

  @override
  String get dueDate => '期日';

  @override
  String get notes => 'メモ';

  @override
  String get title => 'タイトル';

  @override
  String get quickSelect => 'クイック選択';

  @override
  String get save => '保存';

  @override
  String get update => '更新';

  @override
  String get delete => '削除';

  @override
  String get cancel => 'キャンセル';

  @override
  String get saveIncome => '収入を保存';

  @override
  String get saveExpense => '支出を保存';

  @override
  String get saveCommitment => 'コミットメントを保存';

  @override
  String get updateIncome => '収入を更新';

  @override
  String get updateExpense => '支出を更新';

  @override
  String get updateCommitment => 'コミットメントを更新';

  @override
  String get deleteIncome => '収入を削除';

  @override
  String get deleteExpense => '支出を削除';

  @override
  String get deleteCommitment => 'コミットメントを削除';

  @override
  String get deleteIncomeConfirm => 'この収入記録を削除してもよろしいですか？この操作は元に戻せません。';

  @override
  String get deleteExpenseConfirm => 'この支出記録を削除してもよろしいですか？この操作は元に戻せません。';

  @override
  String get deleteCommitmentConfirm => 'このコミットメントを削除してもよろしいですか？この操作は元に戻せません。';

  @override
  String get incomeUpdatedSuccess => '収入が正常に更新されました！';

  @override
  String get expenseUpdatedSuccess => '支出が正常に更新されました！';

  @override
  String get commitmentUpdatedSuccess => 'コミットメントが正常に更新されました！';

  @override
  String get incomeDeletedSuccess => '収入が正常に削除されました！';

  @override
  String get expenseDeletedSuccess => '支出が正常に削除されました！';

  @override
  String get commitmentDeletedSuccess => 'コミットメントが正常に削除されました！';

  @override
  String get incomeSavedSuccess => '収入が正常に保存されました！';

  @override
  String get expenseSavedSuccess => '支出が正常に保存されました！';

  @override
  String get commitmentSavedSuccess => 'コミットメントが正常に保存されました！';

  @override
  String errorUpdatingIncome(String error) {
    return '収入の更新エラー：$error';
  }

  @override
  String errorUpdatingExpense(String error) {
    return '支出の更新エラー：$error';
  }

  @override
  String errorUpdatingCommitment(String error) {
    return 'コミットメントの更新エラー：$error';
  }

  @override
  String errorDeletingIncome(String error) {
    return '収入の削除エラー：$error';
  }

  @override
  String errorDeletingExpense(String error) {
    return '支出の削除エラー：$error';
  }

  @override
  String errorDeletingCommitment(String error) {
    return 'コミットメントの削除エラー：$error';
  }

  @override
  String errorSavingIncome(String error) {
    return '収入の保存エラー：$error';
  }

  @override
  String errorSavingExpense(String error) {
    return '支出の保存エラー：$error';
  }

  @override
  String errorSavingCommitment(String error) {
    return 'コミットメントの保存エラー：$error';
  }

  @override
  String get transactionHistory => '取引履歴';

  @override
  String get noTransactionsYet => 'まだ取引がありません';

  @override
  String get startAddingTransactions => '収入、支出、またはコミットメントの追加を開始してください';

  @override
  String get noCommitmentsYet => 'まだコミットメントがありません';

  @override
  String get addYourBills => '請求書、家賃、その他のコミットメントを追加してください';

  @override
  String get today => '今日';

  @override
  String get yesterday => '昨日';

  @override
  String get upcoming => '今後';

  @override
  String get overdue => '期限切れ';

  @override
  String items(int count) {
    return '$count件';
  }

  @override
  String get all => 'すべて';

  @override
  String get food => '食費';

  @override
  String get transport => '交通費';

  @override
  String get shopping => '買い物';

  @override
  String get entertainment => '娯楽';

  @override
  String get bills => '請求書';

  @override
  String get healthcare => '医療費';

  @override
  String get education => '教育費';

  @override
  String get other => 'その他';

  @override
  String get salary => '給与';

  @override
  String get freelance => 'フリーランス';

  @override
  String get business => 'ビジネス';

  @override
  String get investment => '投資';

  @override
  String get gift => 'ギフト';

  @override
  String get bonus => 'ボーナス';

  @override
  String get pleaseEnterAmount => '金額を入力してください';

  @override
  String get pleaseEnterValidNumber => '有効な数値を入力してください';

  @override
  String get amountMustBeGreaterThanZero => '金額は0より大きくなければなりません';

  @override
  String get pleaseEnterIncomeSource => '収入源を入力してください';

  @override
  String get pleaseEnterTitle => 'タイトルを入力してください';

  @override
  String get addNote => 'メモを追加...';

  @override
  String get appearance => '外観';

  @override
  String get language => '言語';

  @override
  String get currency => '通貨';

  @override
  String get darkMode => 'ダークモード';

  @override
  String get darkThemeEnabled => 'ダークテーマが有効';

  @override
  String get lightThemeEnabled => 'ライトテーマが有効';

  @override
  String get about => 'について';

  @override
  String get version => 'バージョン';

  @override
  String get appDescription => '財務管理に役立つシンプルでエレガントなマネートラッキングアプリ。';

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
  String get statistics => '統計';

  @override
  String get financialStatistics => '財務統計';

  @override
  String get quickOverview => 'クイック概要';

  @override
  String get todaySpent => '今日';

  @override
  String get thisWeekSpent => '今週';

  @override
  String get thisMonthSpent => '今月';

  @override
  String monthlyReport(Object month) {
    return '$monthレポート';
  }

  @override
  String get totalExpenses => '総支出';

  @override
  String get statisticsCalculatedFromStart => '統計は月初から今日まで計算されます';

  @override
  String get currentWeekBreakdown => '今週の内訳';

  @override
  String get weekTotal => '週合計';

  @override
  String get dailyAverage => '日平均';

  @override
  String get dailyActivity => '日次活動';

  @override
  String get noTransactionsRecorded => '記録された取引がありません';

  @override
  String netAmount(Object amount) {
    return '純額：$amount';
  }

  @override
  String spent(Object amount) {
    return '支出：$amount';
  }

  @override
  String earned(Object amount) {
    return '収入：$amount';
  }

  @override
  String get errorLoadingStatistics => '統計の読み込みエラー';

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
