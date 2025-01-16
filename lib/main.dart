import 'package:easy_localization/easy_localization.dart';
import 'package:expenses_manager/features/account/data/account_model.dart';
import 'package:expenses_manager/features/add_expense/data/cubit/expense_cubit.dart';
import 'package:expenses_manager/features/add_expense/data/model/expense_model.dart';
import 'package:expenses_manager/features/home/data/manage_expenses_cubit.dart';
import 'package:expenses_manager/features/splash/splash_screen.dart';
import 'package:expenses_manager/features/themes/themes_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(ExpenseModelAdapter());
  Hive.registerAdapter(AccountModelAdapter());
  await Hive.openBox<ExpenseModel>('expensees');
  await Hive.openBox<AccountModel>('account_box');
  await Hive.openBox<String>('category_box');
  await initializeCategories();
  await EasyLocalization.ensureInitialized();
  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('en'), Locale('ar')],
      path: 'assets/translations', // مسار ملفات JSON
      fallbackLocale: const Locale('en'),
      child: MyApp(),
    ),
  );
}

Future<void> initializeCategories() async {
  final categoryBox = await Hive.openBox<String>('category_box');
  if (categoryBox.isEmpty) {
    categoryBox.addAll([
      'Food & Drinks',
      'Shopping',
      'Healthcare',
      'Transportation',
      'Entertainment',
      'Other',
    ]); // الفئات الأساسية
  }
  var accountBox = Hive.box<AccountModel>('account_box');
  if (accountBox.isEmpty) {
    accountBox.add(AccountModel(
      name: 'Default Account',
      type: 'Savings',
      balance: 0.0,
      transactions: [],
    ));
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => ExpensesCubit(),
        ),
        BlocProvider(
          create: (context) => ThemeCubit(),
        ),
        BlocProvider(
          create: (context) => ManageExpensesCubit(),
        ),
      ],
      child: BlocBuilder<ThemeCubit, ThemeMode>(
        builder: (context, themeMode) {
          return MaterialApp(
          localizationsDelegates: context.localizationDelegates,
              supportedLocales: context.supportedLocales,
              locale: context.locale,
              theme: ThemeData.light(),
              darkTheme: BlocProvider.of<ThemeCubit>(context).getDarkTheme(),
              themeMode: themeMode,
              home: const SplashScreen()
          );
        },
      ),
    );
  }
}

