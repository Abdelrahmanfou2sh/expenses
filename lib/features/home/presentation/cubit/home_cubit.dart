import 'package:expenses_manager/features/account/data/account_model.dart';
import 'package:expenses_manager/features/add_expense/data/model/expense_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';


part 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  HomeCubit() : super(HomeLoadingState());

  late Box<AccountModel> accountBox;
  late List<ExpenseModel> allTransactions = [];
  late List<ExpenseModel> filteredTransactions = [];
  late double totalExpenses = 0.0;
  late double monthlyBudget = 0.0;

  void initialize() async {
    emit(HomeLoadingState());
    accountBox = Hive.box<AccountModel>('account_box');
    _loadAllTransactions();
    _calculateTotalExpenses();
    emit(HomeLoadedState(
      allTransactions,
      filteredTransactions,
      totalExpenses,
      monthlyBudget,
    ));
  }

  void reloadBudget() {
    monthlyBudget = Hive.box('settings_box').get('monthly_budget', defaultValue: 0.0);
    emit(HomeLoadedState(
      allTransactions,
      filteredTransactions,
      totalExpenses,
      monthlyBudget,
    ));

  }

  void _loadAllTransactions() {
    allTransactions = accountBox.values.expand((account) => account.transactions).toList();
    filteredTransactions = List.from(allTransactions);
  }

  void _calculateTotalExpenses() {
    totalExpenses = allTransactions.fold(0.0, (sum, expense) => sum + expense.amount);
  }

  void filterTransactions(String category) {
    if (category == 'All') {
      filteredTransactions = List.from(allTransactions);
    } else {
      filteredTransactions = allTransactions
          .where((transaction) => transaction.category.toLowerCase() == category.toLowerCase())
          .toList();
    }
    emit(HomeFilteredState(filteredTransactions,totalExpenses,monthlyBudget));
  }

  void addTransaction(ExpenseModel transaction) {
    allTransactions.add(transaction);
    if (transaction.category.toLowerCase() == 'All' ||
        transaction.category.toLowerCase() == filteredTransactions.toString().toLowerCase()) {
      filteredTransactions.add(transaction);
    }
    _calculateTotalExpenses();
    emit(HomeUpdatedState(allTransactions, filteredTransactions, totalExpenses));
  }
}