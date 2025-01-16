import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:easy_localization/easy_localization.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  List<String> currencies = ['USD', 'EUR', 'GBP', 'EGP', 'SAR'];
  List<String> languages = ['English', 'العربية'];

  String? selectedCurrency;
  String? selectedLanguage;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      selectedCurrency = prefs.getString('selected_currency') ?? 'USD';
      selectedLanguage = prefs.getString('selected_language') ?? 'English';
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selected_currency', selectedCurrency!);
    await prefs.setString('selected_language', selectedLanguage!);

    // تغيير اللغة إذا تم تحديثها
    if (selectedLanguage == 'العربية') {
      context.setLocale(const Locale('ar'));
    } else if (selectedLanguage == 'English') {
      context.setLocale(const Locale('en'));
    } else {
      throw Exception('Unsupported language');
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Settings saved successfully!'.tr()),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'.tr()),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Currency'.tr(), style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            DropdownButton<String>(
              value: selectedCurrency,
              onChanged: (value) {
                setState(() {
                  selectedCurrency = value;
                });
              },
              items: currencies.map((currency) {
                return DropdownMenuItem(value: currency, child: Text(currency));
              }).toList(),
            ),
            const SizedBox(height: 20),
            Text('Language'.tr(), style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            DropdownButton<String>(
              value: selectedLanguage,
              onChanged: (value) {
                setState(() {
                  selectedLanguage = value;
                });
              },
              items: languages.map((language) {
                return DropdownMenuItem(value: language, child: Text(language));
              }).toList(),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: _saveSettings,
              child: Text('Save Settings'.tr()),
            ),
          ],
        ),
      ),
    );
  }
}
