class CommitmentModel {
  int? id;
  String title;
  double amount;
  String dueDate;
  bool isCompleted;

  CommitmentModel({
    this.id,
    required this.title,
    required this.amount,
    required this.dueDate,
    this.isCompleted = false,
  }) : assert(amount > 0, 'Amount must be greater than 0'),
       assert(title.isNotEmpty, 'Title cannot be empty'),
       assert(dueDate.isNotEmpty, 'Due date cannot be empty');

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'dueDate': dueDate,
      'isCompleted': isCompleted ? 1 : 0,
    };
  }

  /// B2 fix: نفس منظرس Expense FromMap — قبول int/double وتحرير المطلوب.
  factory CommitmentModel.fromMap(Map<String, dynamic> map) {
    final amountValue = map['amount'];
    if (amountValue is! num || !amountValue.isFinite || amountValue <= 0) {
      throw ArgumentError('amount is required and must be a positive number');
    }
    final titleValue = map['title'];
    if (titleValue is! String || titleValue.isEmpty) {
      throw ArgumentError('title is required');
    }
    final dueDateValue = map['dueDate'];
    if (dueDateValue is! String || dueDateValue.isEmpty) {
      throw ArgumentError('dueDate is required');
    }
    return CommitmentModel(
      id: map['id'] as int?,
      title: titleValue,
      amount: amountValue.toDouble(),
      dueDate: dueDateValue,
      isCompleted: (map['isCompleted'] ?? 0) == 1,
    );
  }
}
