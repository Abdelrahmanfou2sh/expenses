import 'package:expenses_manager/features/account/data/account_model.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class TransferScreen extends StatelessWidget {
  void transferBetweenAccounts(
      AccountModel sourceAccount,
      AccountModel destinationAccount,
      double amount,
      ) {
    if (sourceAccount.balance >= amount) {
      sourceAccount.updateBalance(sourceAccount.balance - amount);
      destinationAccount.updateBalance(destinationAccount.balance + amount);
    } else {
      throw Exception('Insufficient funds in the source account.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final accountBox = Hive.box<AccountModel>('account_box');
    AccountModel? sourceAccount;
    AccountModel? destinationAccount;
    double? amount;

    return Scaffold(
      appBar: AppBar(title: Text('Transfer Funds')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            DropdownButton<AccountModel>(
              hint: Text('Select Source Account'),
              items: accountBox.values.map((account) {
                return DropdownMenuItem(
                  value: account,
                  child: Text(account.name),
                );
              }).toList(),
              onChanged: (value) {
                sourceAccount = value;
              },
            ),
            const SizedBox(height: 16),
            DropdownButton<AccountModel>(
              hint: Text('Select Destination Account'),
              items: accountBox.values.map((account) {
                return DropdownMenuItem(
                  value: account,
                  child: Text(account.name),
                );
              }).toList(),
              onChanged: (value) {
                destinationAccount = value;
              },
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(labelText: 'Amount'),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                amount = double.tryParse(value);
              },
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                if (sourceAccount != null &&
                    destinationAccount != null &&
                    amount != null) {
                  try {
                    transferBetweenAccounts(
                      sourceAccount!,
                      destinationAccount!,
                      amount!,
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Transfer successful!')),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(e.toString())),
                    );
                  }
                }
              },
              child: Text('Transfer'),
            ),
          ],
        ),
      ),
    );
  }
}
