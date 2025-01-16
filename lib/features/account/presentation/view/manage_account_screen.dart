import 'package:expenses_manager/core/functions/app_router.dart';
import 'package:expenses_manager/features/account/data/account_model.dart';
import 'package:expenses_manager/features/account/presentation/view/account_details_screen.dart';
import 'package:expenses_manager/features/account/presentation/view/account_transactions_screen.dart';
import 'package:expenses_manager/features/account/presentation/view/transfer_screen.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class ManageAccountsScreen extends StatefulWidget {
  const ManageAccountsScreen({super.key});

  @override
  State<ManageAccountsScreen> createState() => _ManageAccountsScreenState();
}

class _ManageAccountsScreenState extends State<ManageAccountsScreen> {
  late final Box accountBox;

  @override
  void initState() {
    super.initState();
    accountBox = Hive.box<AccountModel>('account_box'); // فتح صندوق الحسابات
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Manage Accounts"),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              _showAddAccountDialog();
            },
          ),
        ],
      ),
      body: ValueListenableBuilder(
        valueListenable: accountBox.listenable(),
        builder: (context, Box box, _) {
          if (box.isEmpty) {
            return const Center(
              child: Text("No accounts available."),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: box.length,
            itemBuilder: (context, index) {
              final account = box.getAt(index);
              final balance = account.balance.toStringAsFixed(2);

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: ListTile(
                  onTap: () {
                    // الانتقال إلى شاشة المعاملات الخاصة بالحساب
                    AppRouter.navigateWithSlide(context, AccountDetailsScreen(account: account));
                  },
                  leading: CircleAvatar(
                    backgroundColor: Colors.blue[100],
                    child: Icon(Icons.account_balance, color: Colors.blue),
                  ),
                  title: Text(account.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text("Type: ${account.type}\nBalance: \$${balance}"),
                  trailing: PopupMenuButton(
                    onSelected: (value) {
                      if (value == 'edit') {
                        _showEditAccountDialog(account, index);
                      } else if (value == 'delete') {
                        _deleteAccount(index);
                      }
                      else if (value == 'transfer'){
                        AppRouter.navigateWithSlide(context, TransferScreen());
                      }
                      else if (value == 'transactions'){
                        AppRouter.navigateWithSlide(context, AccountTransactionsScreen(account: account));
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Text('Edit'),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Text('Delete'),
                      ),
                      const PopupMenuItem(
                        value: 'transfer',
                        child: Text('Transfer'),
                      ),
                      const PopupMenuItem(
                        value: 'transactions',
                        child: Text('Transactions'),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showAddAccountDialog() {
    final _nameController = TextEditingController();
    final _typeController = TextEditingController();
    final _balanceController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Add Account"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: "Account Name"),
              ),
              TextField(
                controller: _typeController,
                decoration: const InputDecoration(labelText: "Account Type"),
              ),
              TextField(
                controller: _balanceController,
                decoration: const InputDecoration(labelText: "Initial Balance"),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                final newAccount = AccountModel(
                  name: _nameController.text,
                  type: _typeController.text,
                  balance: double.parse(_balanceController.text),
                  transactions: [], // Initialize with an empty list of transactions
                );
                accountBox.add(newAccount);
                Navigator.pop(context);
              },
              child: const Text("Add"),
            ),
          ],
        );
      },
    );
  }

  void _showEditAccountDialog(AccountModel account, int index) {
    final _nameController = TextEditingController(text: account.name);
    final _typeController = TextEditingController(text: account.type);
    final _balanceController = TextEditingController(text: account.balance.toString());

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Edit Account"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: "Account Name"),
              ),
              TextField(
                controller: _typeController,
                decoration: const InputDecoration(labelText: "Account Type"),
              ),
              TextField(
                controller: _balanceController,
                decoration: const InputDecoration(labelText: "Balance"),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                final updatedAccount = AccountModel(
                  name: _nameController.text,
                  type: _typeController.text,
                  balance: double.parse(_balanceController.text),
                  transactions: account.transactions, // احتفظ بالمعاملات
                );
                accountBox.putAt(index, updatedAccount);
                Navigator.pop(context);
              },
              child: const Text("Save"),
            ),
          ],
        );
      },
    );
  }


  void _deleteAccount(int index) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Delete Account"),
          content: const Text("Are you sure you want to delete this account?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                accountBox.deleteAt(index);
                Navigator.pop(context);
              },
              child: const Text("Delete", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }
}