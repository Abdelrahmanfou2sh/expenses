import 'package:expenses_manager/features/add_expense/data/cubit/expense_cubit.dart';
import 'package:expenses_manager/features/add_expense/data/model/expense_model.dart';
import 'package:expenses_manager/features/edit_expense/presentation/edit_expense.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

Widget buildExpenseTile(ExpenseModel expense, int index, BuildContext context) {
  IconData icon;
  switch (expense.category) {
    case 'Food':
      icon = Icons.fastfood;
      break;
    case 'Shopping':
      icon = Icons.shopping_cart;
      break;
    case 'Healthcare':
      icon = Icons.health_and_safety;
      break;
    default:
      icon = Icons.category;
  }

  return GestureDetector(
    onLongPress: () {
      showMenuOptions(expense, index, context);
    },
    child: Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 5,
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 25,
            backgroundColor: Colors.blue[100],
            child: Icon(icon, color: Colors.blue),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  expense.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${expense.date.day}/${expense.date.month}/${expense.date.year}',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
          ),
          Text(
            '\$${expense.amount.toStringAsFixed(2)}',
            style: const TextStyle(
              color: Colors.green,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    ),
  );
}

void showMenuOptions(ExpenseModel expense, int index, BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Options'),
        content: Text('Choose an action for "${expense.name}".'),
        actions: [
          TextButton(
            onPressed: () {
              // حذف العنصر
              context.read<ExpensesCubit>().deleteExpense(index);
              Navigator.pop(context);
            },
            child: Text('Delete', style: TextStyle(color: Colors.red)),
          ),
          TextButton(
            onPressed: () {
              // تعديل العنصر
              Navigator.pop(context);
              editExpense(expense, index, context);
            },
            child: Text('Edit'),
          ),
        ],
      );
    },
  );
}
void editExpense(ExpenseModel expense, int index, BuildContext context) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => EditExpenseScreen(
        expense: expense,
        index: index,
      ),
    ),
  );
}
