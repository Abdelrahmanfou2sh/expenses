import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BudgetScreen extends StatefulWidget {
  @override
  _BudgetScreenState createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetScreen> {
  final TextEditingController _budgetController = TextEditingController();
  double currentBudget = 0.0;

  @override
  void initState() {
    super.initState();
    _loadCurrentBudget();
  }

  Future<void> _loadCurrentBudget() async {
    final prefs = await SharedPreferences.getInstance();
    currentBudget = prefs.getDouble('monthly_budget') ?? 0.0;
    setState(() {
      _budgetController.text = currentBudget.toStringAsFixed(2);
    });
  }

  Future<void> _saveBudget() async {
    final budget = double.tryParse(_budgetController.text);
    if (budget != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble('monthly_budget', budget);
      setState(() {
        currentBudget = budget;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Budget updated to \$${budget.toStringAsFixed(2)}'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid number'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Set Monthly Budget'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Enter your monthly budget:',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _budgetController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Budget Amount',
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveBudget,
              child: const Text('Save Budget'),
            ),
          ],
        ),
      ),
    );
  }
}
