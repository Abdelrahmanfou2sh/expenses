import 'package:expenses_manager/features/account/data/account_model.dart';
import 'package:expenses_manager/features/add_expense/data/model/expense_model.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class AddExpenseScreen extends StatefulWidget {
  const AddExpenseScreen({super.key});

  @override
  _AddExpenseScreenState createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  late Box<String> categoryBox;
  late Box<AccountModel> accountBox;
  String? selectedCategory;
  AccountModel? selectedAccount;
  bool isLoading = true;

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();

  @override
  void initState() {
    super.initState();
    openBoxes();
  }

  Future<void> openBoxes() async {
    categoryBox = await Hive.openBox<String>('category_box');
    if (categoryBox.isEmpty) {
      categoryBox.addAll([
        'Food & Drinks',
        'Shopping',
        'Healthcare',
        'Transportation',
        'Entertainment',
        'Bills',
        'Other',
      ]);
    }
    accountBox = await Hive.openBox<AccountModel>('account_box');
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text('Add Transaction')),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        title: Text('Add Expense'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // اختيار الحساب
              DropdownButton<AccountModel>(
                value: selectedAccount,
                hint: Text('Select Account'),
                items: accountBox.values.map((account) {
                  return DropdownMenuItem(
                    value: account,
                    child: Text(account.name),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedAccount = value;
                  });
                },
              ),
              const SizedBox(height: 20),
              // اختيار الفئة
              DropdownButton<String>(
                value: selectedCategory,
                hint: Text('Select Category'),
                items: categoryBox.values.map((category) {
                  return DropdownMenuItem(value: category, child: Text(category));
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedCategory = value;
                  });
                },
              ),
              const SizedBox(height: 20),
              // إدخال اسم المعاملة
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Expense Name',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              // إدخال المبلغ
              TextFormField(
                controller: _amountController,
                decoration: InputDecoration(
                  labelText: 'Amount',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an amount';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 40),
              // زر إضافة المعاملة
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _addExpense,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.all(15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    backgroundColor: Colors.deepPurple,
                  ),
                  child: Text(
                    'Add Expense',
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _addExpense() {
    if (_formKey.currentState!.validate()) {
      if (selectedAccount == null || selectedCategory == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Please select an account and category'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final String name = _nameController.text;
      final double amount = double.parse(_amountController.text);
      final String category = selectedCategory!;

      final expense = ExpenseModel(
        name: name,
        amount: amount,
        category: category,
        date: DateTime.now(),
      );

      // إضافة المعاملة إلى الحساب المختار
      selectedAccount!.transactions.add(expense);
      selectedAccount!.save();

      // عرض SnackBar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Expense "$name" added to ${selectedAccount!.name}!'),
          backgroundColor: Colors.green,
        ),
      );

      // الرجوع إلى الشاشة السابقة
      Navigator.pop(context);
    }
  }
}
