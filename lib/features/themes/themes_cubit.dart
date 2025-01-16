import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeCubit extends Cubit<ThemeMode> {
  ThemeCubit() : super(ThemeMode.light) {
    _loadTheme();
  }

  void toggleTheme() async {
    final newTheme = state == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    emit(newTheme);
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('isDarkMode', newTheme == ThemeMode.dark);
  }

  void _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final isDarkMode = prefs.getBool('isDarkMode') ?? false;
    emit(isDarkMode ? ThemeMode.dark : ThemeMode.light);
  }
  ThemeData getDarkTheme() {
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: Colors.deepPurple,
      scaffoldBackgroundColor: Colors.black,
      cardColor: Colors.grey[900],
      colorScheme: const ColorScheme.dark(
        primary: Colors.deepPurple,
        secondary: Colors.amber, // بديل لـ accentColor
      ),
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: Colors.white), // بديل لـ bodyText1
        bodyMedium: TextStyle(color: Colors.grey), // بديل لـ bodyText2
        titleLarge: TextStyle(color: Colors.white, fontWeight: FontWeight.bold), // بديل لـ headline6
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.deepPurple,
        titleTextStyle: TextStyle(color: Colors.white, fontSize: 20),
        iconTheme: IconThemeData(color: Colors.white),
      ),
    );
  }

}
