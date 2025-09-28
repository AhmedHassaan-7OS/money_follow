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

  factory IncomeModel.fromMap(Map<String, dynamic> map) {
    return IncomeModel(
      id: map['id'],
      amount: map['amount'],
      source: map['source'],
      date: map['date'],
    );
  }
}
