part of 'expense_cubit.dart';

@immutable
abstract class ExpensesState {}
class ExpensesInitial extends ExpensesState {}

class ExpensesLoading extends ExpensesState {}

class ExpensesLoaded extends ExpensesState {
  final List<ExpenseModel> expenses;
  final double totalExpenses;

  ExpensesLoaded(this.expenses, this.totalExpenses);
}

class ExpensesFailure extends ExpensesState {
  final String errMsg;

  ExpensesFailure({required this.errMsg});
}
