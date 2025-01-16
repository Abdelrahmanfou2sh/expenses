import 'package:expenses_manager/features/add_expense/data/model/expense_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:meta/meta.dart';
part 'expense_state.dart';

class ExpensesCubit extends Cubit<ExpensesState> {
  late Box<ExpenseModel> expenseBox;

  ExpensesCubit() : super(ExpensesInitial()) {
    _openBox();
  }

  Future<void> _openBox() async {
    expenseBox = await Hive.openBox<ExpenseModel>('expensees');
    fetchExpenses();
  }

  void fetchExpenses() {
    try {
      final expenses = expenseBox.values.toList();
      emit(ExpensesLoaded(expenses,0));
    } catch (e) {
      emit(ExpensesFailure(errMsg: e.toString()));
    }
  }

  void addExpense(ExpenseModel expense) {
    try {
      expenseBox.add(expense);
      fetchExpenses(); // تحديث البيانات
    } catch (e) {
      emit(ExpensesFailure(errMsg: e.toString()));
    }
  }

  void deleteExpense(int index) {
    try {
      expenseBox.deleteAt(index);
      fetchExpenses(); // تحديث البيانات
    } catch (e) {
      emit(ExpensesFailure(errMsg: e.toString()));
    }
  }
  void editExpense(ExpenseModel expense, int index) {
    try {
      expenseBox.putAt(index, expense); // تحديث العنصر
      fetchExpenses(); // تحديث القائمة
    } catch (e) {
      emit(ExpensesFailure(errMsg: e.toString()));
    }
  }
  double calculateTotalExpenses() {
    double total = 0;
    for (var expense in expenseBox.values) {
      total += expense.amount;
    }
    emit(ExpensesLoaded(expenseBox.values.toList(), total));
    return total;
  }
}