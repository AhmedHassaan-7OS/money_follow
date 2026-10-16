class IncomeModel {
  int? id;
  double amount;
  String source;
  String date;

  IncomeModel({
    this.id,
    required this.amount,
    required this.source,
    required this.date,
  }) : assert(amount > 0, 'Amount must be greater than 0'),
       assert(source.isNotEmpty, 'Source cannot be empty'),
       assert(date.isNotEmpty, 'Date cannot be empty');

  Map<String, dynamic> toMap() {
    return {'id': id, 'amount': amount, 'source': source, 'date': date};
  }

  /// B2 fix: نفس منظرس Expense FromMap — قبول int/double وتحرير المطلوب.
  factory IncomeModel.fromMap(Map<String, dynamic> map) {
    final amountValue = map['amount'];
    if (amountValue is! num || !amountValue.isFinite || amountValue <= 0) {
      throw ArgumentError('amount is required and must be a positive number');
    }
    final sourceValue = map['source'];
    if (sourceValue is! String || sourceValue.isEmpty) {
      throw ArgumentError('source is required');
    }
    final dateValue = map['date'];
    if (dateValue is! String || dateValue.isEmpty) {
      throw ArgumentError('date is required');
    }
    return IncomeModel(
      id: map['id'] as int?,
      amount: amountValue.toDouble(),
      source: sourceValue,
      date: dateValue,
    );
  }
}
