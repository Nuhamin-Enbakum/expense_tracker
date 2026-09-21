import 'package:flutter/material.dart';
import '../models/expense.dart';
import '../services/expense_service.dart';

class AddExpenseScreen extends StatefulWidget {
  final String userId;
  final Expense? existingExpense;
  const AddExpenseScreen({
    super.key, 
    required this.userId,
    this.existingExpense,
    });

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {

  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final List<String> _categories = ['Food', 'Transport', 'Shopping', 'Bills', 'Entertainment', 'Health', 'Other'];
  String? _selectedCategory;
 
  final _noteController = TextEditingController();
  DateTime _selectedDate = DateTime.now();

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }
  @override
  void initState() {
    super.initState();
    if (widget.existingExpense != null) {
      _amountController.text = widget.existingExpense!.amount.toString();
      _selectedCategory = widget.existingExpense!.category;
      _noteController.text = widget.existingExpense!.note;
      _selectedDate = widget.existingExpense!.date;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
  @override
  Widget build(BuildContext context) {
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
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                spacing: 16,
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Navigator.pop(context),

                        
                      ),
                      Text(
                        widget.existingExpense != null ? 'Edit Expense' : 'Add Expense',
                        style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  TextFormField(
                    controller: _amountController,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Amount',
                      labelStyle: const TextStyle(color: Colors.grey),
                      filled: true,
                      fillColor: Colors.black,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Colors.grey),
                      ),

                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty){
                        return 'Please enter an amount';
                      }
                      final parsedValue = double.tryParse(value);
                      if (parsedValue == null){
                        return 'Please enter a valid number';
                      }
                      if (parsedValue <= 0) {
                        return 'Amount must be greater than zero';
                      }
                      return null;
                    }
                  ),
                  DropdownButtonFormField<String>(
                    value: _selectedCategory,
                    dropdownColor: const Color(0xFF121212),
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Category',
                      labelStyle: const TextStyle(color: Colors.grey),
                      filled: true,
                      fillColor: Colors.black,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Colors.grey),
                      ),
                    ),
                    items: _categories.map((category) {
                      return DropdownMenuItem(
                        value: category,
                        child: Text(category),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedCategory = value;
                      });
                    },
                    validator: (value) {
                      if (value == null) {
                        return 'Please select a category';
                      }
                      return null;
                    },

                  ),
                  TextFormField(
                    controller: _noteController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Note',
                      labelStyle: const TextStyle(color: Colors.grey),
                      filled: true,
                      fillColor: Colors.black,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Colors.grey),
                      ),
                    ),

                  ),
                  MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(
                     onTap: () async {
                      DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: _selectedDate,
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );
                      if (pickedDate != null) {
                        setState(() {
                          _selectedDate = pickedDate;
                        });
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.grey),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _formatDate(_selectedDate),
                            style: TextStyle(color: Colors.white),
                          ),
                          const Icon(Icons.calendar_today, color: Colors.grey, size: 18),
                        ],
                      ),
                      
                    ),
                  ),
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          try{
                          if (widget.existingExpense != null) {
                            final updatedExpense = Expense(
                              id: widget.existingExpense!.id,
                            amount: double.parse(_amountController.text),
                            category: _selectedCategory!,
                            note: _noteController.text.trim(),
                            date: _selectedDate,
                            userId: widget.userId,
                          );
                          await ExpenseService().updateExpense(updatedExpense);
                          } else {
                            final newExpense = Expense(
                              id: '',
                              amount: double.parse(_amountController.text),
                              category: _selectedCategory!,
                              note: _noteController.text.trim(),
                              date: _selectedDate,
                              userId: widget.userId,
                            );
                            await ExpenseService().addExpense(newExpense);
                          
                          }
                          if (context.mounted) {
                            Navigator.pop(context);
                        }
                        } catch (e){
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Something went wrong: $e')),
                            );
                          }
                        }
                        }
                      },

                      
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 171, 226, 7),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child:  Text(
                        widget.existingExpense != null ? 'Update Expense' : 'Save Expense',
                        style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ]
              )
            )
          )
        )
      )
    );
    

  }

}