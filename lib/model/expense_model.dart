class ExpenseModel {
  int? id;
  double amount;
  String category;
  String date;
  String? note;

  ExpenseModel({
    this.id,
    required this.amount,
    required this.category,
    required this.date,
    this.note,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'amount': amount,
      'category': category,
      'date': date,
      'note': note,
    };
  }

  factory ExpenseModel.fromMap(Map<String, dynamic> map) {
    return ExpenseModel(
      id: map['id'],
      amount: map['amount'],
      category: map['category'],
      date: map['date'],
      note: map['note'],
    );
  }
}
