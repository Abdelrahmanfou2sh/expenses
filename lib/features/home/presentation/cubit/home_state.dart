part of 'home_cubit.dart';
abstract class HomeState {}

class HomeLoadingState extends HomeState {}

class HomeLoadedState extends HomeState {
  final List<ExpenseModel> allTransactions;
  final List<ExpenseModel> filteredTransactions;
  final double totalExpenses;
  final double monthlyBudget;

  HomeLoadedState(
      this.allTransactions,
      this.filteredTransactions,
      this.totalExpenses,
      this.monthlyBudget,
      );
}

class HomeFilteredState extends HomeState {
  final List<ExpenseModel> filteredTransactions;
  final double totalExpenses;
  final double monthlyBudget;

  HomeFilteredState(this.filteredTransactions, this.totalExpenses, this.monthlyBudget);
}

class HomeUpdatedState extends HomeState {
  final List<ExpenseModel> allTransactions;
  final List<ExpenseModel> filteredTransactions;
  final double totalExpenses;

  HomeUpdatedState(this.allTransactions, this.filteredTransactions, this.totalExpenses);
}
class HomeErrorState extends HomeState {
  final String errorMessage;

  HomeErrorState({required this.errorMessage});
}