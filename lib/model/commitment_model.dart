class CommitmentModel {
  int? id;
  String title;
  double amount;
  String dueDate;

  CommitmentModel({
    this.id,
    required this.title,
    required this.amount,
    required this.dueDate,
  }) : assert(amount > 0, 'Amount must be greater than 0'),
       assert(title.isNotEmpty, 'Title cannot be empty'),
       assert(dueDate.isNotEmpty, 'Due date cannot be empty');

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'dueDate': dueDate,
    };
  }

  factory CommitmentModel.fromMap(Map<String, dynamic> map) {
    return CommitmentModel(
      id: map['id'],
      title: map['title'],
      amount: map['amount'],
      dueDate: map['dueDate'],
    );
  }
}
