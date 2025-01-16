import 'package:expenses_manager/features/account/data/account_model.dart';
import 'package:flutter/material.dart';

Widget buildAccountTile(AccountModel account) {
  double totalSpent = account.transactions.fold(
    0.0,
        (sum, transaction) => sum + transaction.amount,
  );

  return Container(
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
          radius: 30,
          backgroundColor: Colors.blue[100],
          child: Icon(Icons.account_balance, color: Colors.blue),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                account.name,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: totalSpent / account.balance,
                backgroundColor: Colors.grey[300],
                valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
              ),
              const SizedBox(height: 8),
              Text(
                'Spent: \$${totalSpent.toStringAsFixed(2)} / Total: \$${account.balance.toStringAsFixed(2)}',
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
