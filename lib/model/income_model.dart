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
  });

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
