// import 'package:flutter/material.dart';

// class LocalizationProvider with ChangeNotifier {
//   Locale _locale = const Locale('en');

//   Locale get locale => _locale;

//   void toggleLocale() {
//     _locale = _locale.languageCode == 'en' ? const Locale('te') : const Locale('en');
//     notifyListeners();
//   }
// }
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalizationProvider with ChangeNotifier {
  Locale _locale = const Locale('en');

  Locale get locale => _locale;

  LocalizationProvider() {
    _loadSavedLocale(); // Load the saved language on app start
  }

  // Load saved language
  Future<void> _loadSavedLocale() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? langCode = prefs.getString('language_code');

    if (langCode != null) {
      _locale = Locale(langCode);
      notifyListeners();
    }
  }

  // Change language and save it
  Future<void> changeLocale(String langCode) async {
    _locale = Locale(langCode);
    notifyListeners();

    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('language_code', langCode);
  }

  // Toggle button (optional)
  void toggleLanguage() {
    String newLang = _locale.languageCode == 'en' ? 'te' : 'en';
    changeLocale(newLang);
  }
}
