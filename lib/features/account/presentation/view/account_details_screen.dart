import 'package:expenses_manager/features/account/data/account_model.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class AccountDetailsScreen extends StatelessWidget {
  final AccountModel account;

  const AccountDetailsScreen({super.key, required this.account});

  @override
  Widget build(BuildContext context) {
    final categoryTotals = <String, double>{};

    for (var transaction in account.transactions) {
      categoryTotals[transaction.category] =
          (categoryTotals[transaction.category] ?? 0.0) + transaction.amount;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(account.name),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Account Type: ${account.type}',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              'Total Expenses: \$${account.transactions.fold(0.0, (sum, t) => sum + t.amount).toStringAsFixed(2)}',
              style: TextStyle(fontSize: 16, color: Colors.red),
            ),
            const SizedBox(height: 20),
            Text(
              'Expenses by Category:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: PieChart(
                PieChartData(
                  sections: categoryTotals.entries.map((entry) {
                    return PieChartSectionData(
                      value: entry.value,
                      title: '${entry.key} (${entry.value.toStringAsFixed(2)})',
                      color: Colors.primaries[
                      categoryTotals.keys.toList().indexOf(entry.key) %
                          Colors.primaries.length],
                    );
                  }).toList(),
                  sectionsSpace: 4,
                  centerSpaceRadius: 50,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Expenses Over Time:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: BarChart(
                BarChartData(
                  barGroups: account.transactions.map((transaction) {
                    final index = account.transactions.indexOf(transaction);
                    return BarChartGroupData(
                      x: index,
                      barRods: [
                        BarChartRodData(
                          toY: transaction.amount,
                          color: Colors.blue,
                        ),
                      ],
                    );
                  }).toList(),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: true),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final index = value.toInt();
                          if (index < account.transactions.length) {
                            return Text(
                              account.transactions[index].date.day.toString(),
                            );
                          }
                          return Text('');
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
