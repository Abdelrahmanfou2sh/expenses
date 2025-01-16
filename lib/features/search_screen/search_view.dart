import 'package:expenses_manager/features/add_expense/data/model/expense_model.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class ExpensesSearchScreen extends StatefulWidget {
  const ExpensesSearchScreen({super.key});

  @override
  _ExpensesSearchScreenState createState() => _ExpensesSearchScreenState();
}

class _ExpensesSearchScreenState extends State<ExpensesSearchScreen> {
  late List<ExpenseModel> allTransactions; // جميع المعاملات
  List<ExpenseModel> searchResults = []; // نتائج البحث
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    allTransactions = loadExpenses(); // تحميل البيانات من Hive
    // filteredTransactions = List.from(allTransactions); // نسخ البيانات إلى القائمة المفلترة
  }


  void searchTransactions(String query) {
    setState(() {
      if (query.isEmpty) {
        searchResults = List.from(allTransactions);
      } else {
        searchResults = allTransactions
            .where((transaction) =>
            transaction.name.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Search Transactions"),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: searchController,
              onChanged: searchTransactions,
              decoration: InputDecoration(
                hintText: "Search by name...",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
          Expanded(
            child: searchResults.isEmpty
                ? const Center(child: Text("No transactions found."))
                : ListView.builder(
              itemCount: searchResults.length,
              itemBuilder: (context, index) {
                return buildTransactionTile(
                    searchResults[index], context);
              },
            ),
          ),
        ],
      ),
    );
  }
  List<ExpenseModel> loadExpenses() {
    if (Hive.isBoxOpen('expensees')) {
      final box = Hive.box<ExpenseModel>('expensees');
      return box.values.toList();
    }
    return []; // إعادة قائمة فارغة إذا لم يكن الصندوق مفتوحًا
  }
  Widget buildTransactionTile(transaction, BuildContext context) {
    IconData icon;
    Color iconColor;
    switch (transaction.category) {
      case 'Food & Drinks':
        icon = Icons.fastfood;
        iconColor = Colors.orange;
        break;
      case 'Shopping':
        icon = Icons.shopping_cart;
        iconColor = Colors.pink;
        break;
      case 'Healthcare':
        icon = Icons.health_and_safety;
        iconColor = Colors.redAccent;
        break;
      case 'Entertainment':
        icon = Icons.sports_esports;
        iconColor = Colors.purple;
        break;
      case 'Transportation':
        icon = Icons.directions_car;
        iconColor = Colors.blue;
        break;
      case 'Bills':
        icon = Icons.payment;
        iconColor = Colors.green;
        break;
      case 'Other':
        icon = Icons.question_mark_sharp;
        iconColor = Colors.grey;
        break;
      default:
        icon = Icons.category;
        iconColor = Colors.blueGrey;
    }

    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey[850] : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: isDarkMode
            ? null
            : [
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
            backgroundColor: iconColor.withOpacity(0.2),
            child: Icon(icon, color: iconColor),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.name,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: isDarkMode ? Colors.white : Colors.black,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${transaction.date.day}/${transaction.date.month}/${transaction.date.year}',
                  style: TextStyle(
                    color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '\$${transaction.amount.toStringAsFixed(2)}',
            style: TextStyle(
              color: isDarkMode ? Colors.greenAccent : Colors.green,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

}
