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
  }) : assert(amount > 0, 'Amount must be greater than 0'),
       assert(category.isNotEmpty, 'Category cannot be empty'),
       assert(date.isNotEmpty, 'Date cannot be empty');

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'amount': amount,
      'category': category,
      'date': date,
      'note': note,
    };
  }

  /// B2 fix: القيمة ممكن تيجي int أو double (باك أب قديم من JSON) —
  /// نحوّلها بشكل صريح بدل ما التمرير المباشر يكسر الاستيراد.
  /// الحقول المطلوبة (amount/date) لازم تكون موجودة وصح —
  /// الافتراضي الفاسد بيرمي ArgumentError فالاستيراد يعدّه error بدل ما يكري غامض.
  factory ExpenseModel.fromMap(Map<String, dynamic> map) {
    final amountValue = map['amount'];
    if (amountValue is! num || !amountValue.isFinite) {
      throw ArgumentError('amount is required and must be a valid number');
    }
    final dateValue = map['date'];
    if (dateValue is! String || dateValue.isEmpty) {
      throw ArgumentError('date is required');
    }
    return ExpenseModel(
      id: map['id'] as int?,
      amount: amountValue.toDouble(),
      category: map['category'] as String? ?? '',
      date: dateValue,
      note: map['note'] as String?,
    );
  }
}
