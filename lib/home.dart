import 'package:expenses_manager/features/account/presentation/view/manage_account_screen.dart';
import 'package:expenses_manager/features/add_expense/data/model/expense_model.dart';
import 'package:expenses_manager/features/add_expense/presentation/views/add_expense_screen.dart';
import 'package:expenses_manager/features/budget_screen/budget_screen.dart';
import 'package:expenses_manager/features/home/presentation/cubit/home_cubit.dart';
import 'package:expenses_manager/features/manage_categories/view/manage_categories_screen.dart';
import 'package:expenses_manager/features/reports/view/reports_screen.dart';
import 'package:expenses_manager/features/search_screen/search_view.dart';
import 'package:expenses_manager/features/settings_screen/setting_screen.dart';
import 'package:expenses_manager/features/themes/themes_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';


class HomeeScreen extends StatelessWidget {
  const HomeeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => HomeCubit()..initialize(),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).brightness == Brightness.dark ? Colors.black : Colors.white,
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
              icon: const Icon(Icons.search),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ExpensesSearchScreen(),
                  ),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.filter_alt_outlined),
              onPressed: () => _showFilterDialog(context),
            ),
            IconButton(
              icon: Icon(
                Theme.of(context).brightness == Brightness.dark ? Icons.dark_mode : Icons.light_mode,
              ),
              onPressed: () {
                context.read<ThemeCubit>().toggleTheme();
              },
            ),
            IconButton(
              icon: const Icon(Icons.attach_money),
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => BudgetScreen()),
                );
                context.read<HomeCubit>().reloadBudget();
              },
            ),
          ],
        ),
        drawer: _buildDrawer(context),
        body: BlocBuilder<HomeCubit, HomeState>(
          builder: (context, state) {
            if (state is HomeLoadingState) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is HomeLoadedState || state is HomeFilteredState) {
              final transactions = state is HomeLoadedState
                  ? state.filteredTransactions
                  : (state as HomeFilteredState).filteredTransactions;

              final totalExpenses = state is HomeLoadedState
                  ? state.totalExpenses
                  : (state as HomeFilteredState).totalExpenses;

              final monthlyBudget = state is HomeLoadedState
                  ? state.monthlyBudget
                  : (state as HomeFilteredState).monthlyBudget;
              return CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 20),
                        _buildTopBalanceCard(totalExpenses, monthlyBudget),
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
                          (context, index) => _buildTransactionTile(transactions[index], context),
                      childCount: transactions.length,
                    ),
                  ),
                ],
              );
            } else {
              return const Center(child: Text('Failed to load data.'));
            }
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            final newTransaction = await Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => AddExpenseScreen()),
            );
            if (newTransaction != null) {
              context.read<HomeCubit>().addTransaction(newTransaction);
            }
          },
          child: const Icon(Icons.add),
        ),
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

  Widget _buildTransactionTile(ExpenseModel transaction,context) {
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

    return Dismissible(
      key: UniqueKey(),
      onDismissed: (direction) {
        context.read<HomeCubit>().deleteTransaction(transaction);
      },
      child: Container(
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
      ),
    );
  }

  void _showFilterDialog(BuildContext context) {
    final cubit = context.read<HomeCubit>();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Filter Transactions'),
          content: DropdownButtonFormField<String>(
            items: ['All', ...cubit.allTransactions.map((e) => e.category).toSet()]
                .map((category) => DropdownMenuItem(
              value: category,
              child: Text(category),
            ))
                .toList(),
            onChanged: (value) {
              if (value != null) {
                cubit.filterTransactions(value);
                Navigator.pop(context);
              }
            },
          ),
        );
      },
    );
  }
}
