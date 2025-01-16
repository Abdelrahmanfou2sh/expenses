import 'package:expenses_manager/features/account/data/account_model.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:hive_flutter/hive_flutter.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late Box accountBox;

  String selectedFilter = 'All'; // فلتر الفئة الافتراضي
  String selectedDateRange = 'All'; // فلتر التاريخ الافتراضي

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    accountBox = Hive.box<AccountModel>('account_box');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Reports",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.pie_chart), text: "By Categories"),
            Tab(icon: Icon(Icons.account_balance_wallet), text: "By Accounts"),
            Tab(icon: Icon(Icons.timeline), text: "By Time"),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_alt),
            onPressed: () {
              _showFilterDialog();
            },
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildCategoryReport(),
          _buildAccountReport(),
          _buildTimeReport(),
        ],
      ),
    );
  }

  void _showFilterDialog() async {
    // افتح صندوق الفئات لجلب الفئات الموجودة
    final categoryBox = await Hive.openBox<String>('category_box');
    final categories = categoryBox.values.toList();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Filter Options"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                value: selectedFilter,
                decoration: const InputDecoration(labelText: "Filter by Category"),
                items: [
                  const DropdownMenuItem(value: 'All', child: Text('All')),
                  ...categories.map((category) => DropdownMenuItem(
                    value: category,
                    child: Text(category),
                  )),
                ],
                onChanged: (value) {
                  setState(() {
                    selectedFilter = value!;
                  });
                },
              ),
              DropdownButtonFormField<String>(
                value: selectedDateRange,
                decoration: const InputDecoration(labelText: "Filter by Date"),
                items: [
                  const DropdownMenuItem(value: 'All', child: Text('All')),
                  const DropdownMenuItem(value: 'Daily', child: Text('Daily')),
                  const DropdownMenuItem(value: 'Weekly', child: Text('Weekly')),
                  const DropdownMenuItem(value: 'Monthly', child: Text('Monthly')),
                ],
                onChanged: (value) {
                  setState(() {
                    selectedDateRange = value!;
                  });
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Apply"),
            ),
          ],
        );
      },
    );
  }


  Widget _buildCategoryReport() {
    return ValueListenableBuilder(
      valueListenable: accountBox.listenable(),
      builder: (context, Box box, _) {
        if (box.isEmpty) {
          return const Center(child: Text("No data available."));
        }

        final categoryTotals = <String, double>{};
        for (var account in box.values) {
          for (var transaction in account.transactions) {
            if (selectedFilter == 'All' || transaction.category == selectedFilter) {
              categoryTotals[transaction.category] =
                  (categoryTotals[transaction.category] ?? 0) +
                      transaction.amount;
            }
          }
        }

        return Padding(
          padding: const EdgeInsets.all(16),
          child: Card(
            elevation: 8,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: PieChart(
              PieChartData(
                sections: categoryTotals.entries.map((entry) {
                  return PieChartSectionData(
                    value: entry.value,
                    title: '${entry.key} (${entry.value.toStringAsFixed(2)})',
                    color: Colors.primaries[
                    categoryTotals.keys.toList().indexOf(entry.key) %
                        Colors.primaries.length],
                    titleStyle: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Colors.white,
                    ),
                  );
                }).toList(),
                sectionsSpace: 4,
                centerSpaceRadius: 50,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAccountReport() {
    return ValueListenableBuilder(
      valueListenable: accountBox.listenable(),
      builder: (context, Box box, _) {
        if (box.isEmpty) {
          return const Center(child: Text("No accounts available."));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: box.length,
          itemBuilder: (context, index) {
            final account = box.getAt(index);
            final totalAmount = account.transactions.fold(
              0.0,
                  (sum, transaction) =>
              sum + (selectedFilter == 'All' || transaction.category == selectedFilter
                  ? transaction.amount
                  : 0),
            );

            return Card(
              margin: const EdgeInsets.symmetric(vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.blue[100],
                  child: Icon(Icons.account_balance, color: Colors.blue),
                ),
                title: Text(account.name,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text("Type: ${account.type}"),
                trailing: Text(
                  "\$${totalAmount.toStringAsFixed(2)}",
                  style: const TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildTimeReport() {
    // تحسين المخطط الزمني لتوضيح البيانات بشكل أكثر تفاعلاً
    return const Center(child: Text("Time Report (Coming Soon)"));
  }
}
