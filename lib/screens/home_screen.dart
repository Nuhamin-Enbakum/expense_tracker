import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/expense.dart';
import '../services/expense_service.dart';
import 'login_screen.dart';
import 'add_expense_screen.dart';

class HomeScreen extends StatelessWidget {
  final String userId;
  final String firstName;

  const HomeScreen({
    super.key,
    required this.userId,
    required this.firstName,
  });

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final ExpenseService expenseService = ExpenseService();

    return Scaffold(
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFF121212),
            borderRadius: BorderRadius.circular(20),
            boxShadow: const [
              BoxShadow(
                color: Colors.grey,
                spreadRadius: 5,
                blurRadius: 7,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Hi, $firstName!',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.add, color: Colors.white),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AddExpenseScreen(userId: userId),
                            ),
                          );
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.logout, color: Colors.white),
                        onPressed: () async {
                          await FirebaseAuth.instance.signOut();
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const Scaffold(
                                body: Center(
                                  child: LoginScreen(),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: StreamBuilder<List<Expense>>(
                  stream: expenseService.getExpenses(userId),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return Center(
                        child: Text(
                          'Error: ${snapshot.error}',
                          style: const TextStyle(color: Colors.white),
                        ),
                      );
                    }
                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(
                        child: Text(
                          'No expenses yet. Add one!',
                          style: TextStyle(color: Colors.white),
                        ),
                      );
                    }
                    List<Expense> expenses = snapshot.data!;
                    return Material(
                      color: Colors.transparent,
                      child: ListView.builder(
                      itemCount: expenses.length,
                      itemBuilder: (context, index) {
                        Expense expense = expenses[index];
                        return ListTile(
                          title: Text(
                            expense.category,
                            style: const TextStyle(color: Colors.white),
                          ),
                          subtitle: Text(
                            '${expense.note}\n${_formatDate(expense.date)}',
                            style: const TextStyle(color: Colors.grey),
                          ),
                          isThreeLine: true,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AddExpenseScreen(
                                  userId: userId,
                                  existingExpense: expense,
                                )
                              )
                            );
                          },
                          trailing: Row (
                            mainAxisSize: MainAxisSize.min,
                            children: [
                            Text(
                            'ETB ${expense.amount.toStringAsFixed(2)}',
                            style: const TextStyle(color: Colors.white),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color:  Colors.red, size: 20),
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Delete Expense?'),
                                  content: const Text('This action cannot be undone.'),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: const Text('Cancel'),
                                    ),
                                    TextButton(
                                      onPressed: () async {
                                        try{
                                        await expenseService.deleteExpense(expense.id);
                                        } catch (e) {
                                          if(context.mounted) {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(content: Text('Failed to delete: $e')),

                                            );
                                          }
                                        }
                                        if (context.mounted) {
                                          Navigator.pop(context);
                                        }
                                      },
                                      child: const Text('Delete', style: TextStyle(color: Colors.red)),
                                    ),
                                  ],
                                ),
                              );
                            }
                          ),
                            ]
                          ),
                        );
                      },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}