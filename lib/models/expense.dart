import 'package:cloud_firestore/cloud_firestore.dart';
class Expense{
  final String id;
  final double amount;
  final String category;
  final String note;
  final DateTime date;
  final String userId;

  Expense({
  required this.id,
  required this.amount,
  required this.category,
  required this.note,
  required this.date,
  required this.userId

});

Map<String, dynamic> toMap() {
  return{
    'amount': amount,
    'category': category,
    'note': note,
    'date': date,
    'userId': userId
  };
}

factory Expense.fromMap(String id, Map<String, dynamic> map) {
  return Expense(
    id: id,
    amount: map['amount'],
    category: map['category'],
    note: map['note'],
    date: (map['date'] as Timestamp).toDate(),
    userId: map['userId']

  );
}

}



