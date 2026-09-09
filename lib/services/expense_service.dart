import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/expense.dart';

class ExpenseService {
  final CollectionReference _expenseCollection = 
  FirebaseFirestore.instance.collection('expenses');

  Future<void> addExpense(Expense expense) async {
    await _expenseCollection.add(expense.toMap());
  }

  Stream<List<Expense>> getExpenses(String userId) {
    return _expenseCollection
        .where('userId', isEqualTo: userId)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Expense.fromMap(doc.id, doc.data() as Map<String, dynamic>))
            .toList());
  }

  Future<void> updateExpense(Expense expense) async {
    await _expenseCollection.doc(expense.id).update(expense.toMap());
  }

  Future<void> deleteExpense(String expenseId) async {
    await _expenseCollection.doc(expenseId).delete();
  }
}