import 'package:expenses_manager/features/add_expense/data/model/expense_model.dart';
import 'package:hive_flutter/hive_flutter.dart';

part 'account_model.g.dart';
@HiveType(typeId: 1)
class AccountModel extends HiveObject {
  @HiveField(0)
  final String name;

  @HiveField(1)
  double balance;

  @HiveField(2)
  final String type;

  @HiveField(3)
  final List<ExpenseModel> transactions; // إضافة قائمة للمعاملات

  AccountModel({
    required this.name,
    required this.balance,
    required this.type,
    required this.transactions,
  });
  void addTransactionToAccount(AccountModel account, ExpenseModel transaction) {
    account.transactions.add(transaction);
    account.save(); // حفظ التحديثات في Hive
  }
  void updateBalance(double newBalance) {
    balance = newBalance;
    save(); // حفظ التغيير في Hive
  }
}
