import 'package:bloc/bloc.dart';
import 'package:expenses_manager/features/add_expense/data/model/expense_model.dart';
import 'package:hive/hive.dart';

class ManageExpensesCubit extends Cubit<List<ExpenseModel>> {
  ManageExpensesCubit() : super([]);

  void loadExpenses() {
    final transactionBox = Hive.box<ExpenseModel>('expensees');
    emit(transactionBox.values.toList());
  }

  void addExpense(ExpenseModel expense) {
    final transactionBox = Hive.box<ExpenseModel>('expensees');
    transactionBox.add(expense);
    loadExpenses(); // إعادة تحميل المعاملات
  }

  void filterExpenses(String category) {
    final transactionBox = Hive.box<ExpenseModel>('expensees');
    if (category == 'All') {
      emit(transactionBox.values.toList());
    } else {
      emit(transactionBox.values
          .where((transaction) =>
      transaction.category.toLowerCase() == category.toLowerCase())
          .toList());
    }
  }
}
