import 'package:expenses_manager/features/account/data/account_model.dart';
import 'package:flutter/material.dart';

class AccountTransactionsScreen extends StatelessWidget {
  final AccountModel account;

  const AccountTransactionsScreen({required this.account, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('${account.name} Transactions')),
      body: ListView.builder(
        itemCount: account.transactions.length,
        itemBuilder: (context, index) {
          final transaction = account.transactions[index];
          return ListTile(
            title: Text(transaction.name),
            subtitle: Text(transaction.category),
            trailing: Text('\$${transaction.amount.toStringAsFixed(2)}'),
          );
        },
      ),
    );
  }
}
