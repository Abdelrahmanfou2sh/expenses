import 'package:expenses_manager/features/add_expense/data/cubit/expense_cubit.dart';
import 'package:expenses_manager/features/add_expense/data/model/expense_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class EditExpenseScreen extends StatefulWidget {
  final ExpenseModel expense;
  final int index;

  EditExpenseScreen({required this.expense, required this.index});

  @override
  _EditExpenseScreenState createState() => _EditExpenseScreenState();
}

class _EditExpenseScreenState extends State<EditExpenseScreen> {
  late TextEditingController _titleController;
  late TextEditingController _amountController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.expense.name);
    _amountController = TextEditingController(
        text: widget.expense.amount.toStringAsFixed(2));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Edit Expense')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(labelText: 'Title'),
            ),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'Amount'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                final updatedExpense = ExpenseModel(
                  name: _titleController.text,
                  category: widget.expense.category,
                  amount: double.parse(_amountController.text),
                  date: widget.expense.date,
                );

                context.read<ExpensesCubit>().editExpense(updatedExpense, widget.index);
                Navigator.pop(context);
              },
              child: Text('Save Changes'),
            ),
          ],
        ),
      ),
    );
  }
}
