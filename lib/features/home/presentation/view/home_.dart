import 'package:expenses_manager/features/account/data/account_model.dart';
import 'package:expenses_manager/features/account/presentation/view/manage_account_screen.dart';
import 'package:expenses_manager/features/add_expense/data/model/expense_model.dart';
import 'package:expenses_manager/features/add_expense/presentation/views/add_expense_screen.dart';
import 'package:expenses_manager/features/budget_screen/budget_screen.dart';
import 'package:expenses_manager/features/manage_categories/view/manage_categories_screen.dart';
import 'package:expenses_manager/features/reports/view/reports_screen.dart';
import 'package:expenses_manager/features/search_screen/search_view.dart';
import 'package:expenses_manager/features/settings_screen/setting_screen.dart';
import 'package:expenses_manager/features/themes/themes_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  late Box<AccountModel> accountBox;
  late Box<ExpenseModel> expenseBox;
  late Box<String> categoryBox;
  List<ExpenseModel> allTransactions = [];
  List<ExpenseModel> filteredTransactions = [];
  String selectedFilter = 'All';
  double totalExpenses = 0.0;
  double monthlyBudget = 0.0;

  @override
  void initState() {
    super.initState();
    accountBox = Hive.box<AccountModel>('account_box');
    expenseBox = Hive.box<ExpenseModel>('expensees');
    _loadCategories();
    _loadBudget();
    _loadAllTransactions();
  }

  Future<void> _loadCategories() async {
    categoryBox = await Hive.openBox<String>('category_box');
  }

  Future<void> _loadBudget() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      monthlyBudget = prefs.getDouble('monthly_budget') ?? 0.0;
    });
  }

  void _loadAllTransactions() {
    allTransactions = accountBox.values
        .expand((account) => account.transactions)
        .toList();

    filteredTransactions = List.from(allTransactions);
    _calculateTotalExpenses();
  }

  void _calculateTotalExpenses() {
    setState(() {
      totalExpenses = allTransactions.fold(0.0, (sum, expense) => sum + expense.amount);
    });
  }

  void _filterTransactions(String category) {
    setState(() {
      if (category == 'All') {
        filteredTransactions = List.from(allTransactions);
      } else {
        filteredTransactions = allTransactions
            .where((transaction) => transaction.category.toLowerCase() == category.toLowerCase())
            .toList();
      }
    });
  }

  void _addTransaction(ExpenseModel transaction) {
    setState(() {
      expenseBox.add(transaction).then((_) {
        allTransactions.add(transaction);
        if (selectedFilter == 'All' ||
            transaction.category.toLowerCase() == selectedFilter.toLowerCase()) {
          filteredTransactions.add(transaction);
        }
        _calculateTotalExpenses();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).brightness == Brightness.dark
            ? Colors.black
            : Colors.white,
        elevation: 0,
        title: Text(
          'Home',
          style: TextStyle(
            color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.search, color: Theme.of(context).iconTheme.color),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ExpensesSearchScreen()),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.filter_alt_outlined, color: Theme.of(context).iconTheme.color),
            onPressed: () => _showFilterDialog(context),
          ),
          IconButton(
            icon: Icon(
              Theme.of(context).brightness == Brightness.dark ? Icons.dark_mode : Icons.light_mode,
            ),
            onPressed: () => context.read<ThemeCubit>().toggleTheme(),
          ),
          IconButton(
            icon: const Icon(Icons.attach_money),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => BudgetScreen()),
              );
              _loadBudget();
            },
          ),
        ],
      ),
      drawer: _buildDrawer(context),
      body: ValueListenableBuilder(
        valueListenable: expenseBox.listenable(),
        builder: (context, Box box, _) {
          if (box.isEmpty) {
            return const Center(child: Text('No transactions available.'));
          }

          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    _buildTopBalanceCard(totalExpenses, monthlyBudget),
                    const SizedBox(height: 20),
                    _buildTopCategoriesSection(),
                    const SizedBox(height: 20),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        'Transactions',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                      (context, index) => _buildTransactionTile(filteredTransactions[index]),
                  childCount: filteredTransactions.length,
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final newTransaction = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddExpenseScreen()),
          );
          if (newTransaction != null) {
            _addTransaction(newTransaction);
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Drawer _buildDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(color: Colors.blue),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Text('Expense Manager', style: TextStyle(color: Colors.white, fontSize: 24)),
                SizedBox(height: 8),
                Text('Manage your expenses efficiently!', style: TextStyle(color: Colors.white70, fontSize: 14)),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Home'),
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            leading: const Icon(Icons.dashboard),
            title: const Text('Reports'),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => ReportsScreen())),
          ),
          ListTile(
            leading: const Icon(Icons.money),
            title: const Text('Manage Categories'),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => ManageCategoriesScreen())),
          ),
          ListTile(
            leading: const Icon(Icons.account_balance),
            title: const Text('Manage Accounts'),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => ManageAccountsScreen())),
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Settings'),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => SettingsScreen())),
          ),
        ],
      ),
    );
  }
  Widget _buildTransactionTile(ExpenseModel transaction) {
    IconData icon;
    switch (transaction.category) {
      case 'Food & Drinks':
        icon = Icons.fastfood;
        break;
      case 'Shopping':
        icon = Icons.shopping_cart;
        break;
      case 'Healthcare':
        icon = Icons.health_and_safety;
        break;
      case 'Entertainment':
        icon = Icons.sports_esports;
        break;
      case 'Transportation':
        icon = Icons.directions_car;
        break;
      case 'Bills':
        icon = Icons.payment;
        break;
      case 'Other':
        icon = Icons.question_mark_sharp;
        break;
      default:
        icon = Icons.category;
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme
            .of(context)
            .brightness == Brightness.dark
            ? Colors.grey[850]
            : Colors.white,
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
                  transaction.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${transaction.date.day}/${transaction.date
                      .month}/${transaction.date.year}',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
          ),
          Text(
            '\$${transaction.amount.toStringAsFixed(2)}',
            style: const TextStyle(
              color: Colors.green,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBalanceCard(double totalExpenses, double monthlyBudget) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.deepPurple, Colors.purpleAccent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Monthly Budget',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            '\$${monthlyBudget.toStringAsFixed(2)}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Total Expenses',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            '\$${totalExpenses.toStringAsFixed(2)}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopCategoriesSection() {
    final categoryTotals = <String, double>{};
    for (var transaction in allTransactions) {
      categoryTotals[transaction.category] =
          (categoryTotals[transaction.category] ?? 0) + transaction.amount;
    }

    final sortedCategories = categoryTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final topCategories = sortedCategories.take(3);

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Top Categories',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ...topCategories.map((entry) {
              return ListTile(
                leading: const Icon(Icons.category, color: Colors.blue),
                title: Text(entry.key),
                trailing: Text('\$${entry.value.toStringAsFixed(2)}'),
              );
            }),
          ],
        ),
      ),
    );
  }

  void _showFilterDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Filter Transactions',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedFilter,
                items: [
                  'All',
                  ...categoryBox.values.toSet().toList(),
                ].map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    _filterTransactions(value);
                  }
                },
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  labelText: 'Category',
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Apply Filter'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}