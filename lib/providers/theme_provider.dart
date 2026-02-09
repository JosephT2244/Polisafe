/*══════════════════════════════════════════════
 Un código de: Joseph Ubaldo Trejo Hernandez
══════════════════════════════════════════════*/

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/*══════════════════════════════════════════════*/

class ThemeProvider extends ChangeNotifier {

  bool _darkMode = false;

  bool get darkMode => _darkMode;

  /*══════════════════════════════════════════════*/

  ThemeProvider() {
    _loadTheme();
  }

  /*══════════════════════════════════════════════*/

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();

    _darkMode = prefs.getBool("dark") ?? false;

    notifyListeners();
  }

  /*══════════════════════════════════════════════*/

  Future<void> setDarkMode(bool value) async {

    _darkMode = value;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool("dark", value);
  }

  /*══════════════════════════════════════════════*/

  Future<void> toggleTheme() async {

    _darkMode = !_darkMode;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool("dark", _darkMode);
  }
}

/*══════════════════════════════════════════════
 Un código de: Joseph Ubaldo Trejo Hernandez
══════════════════════════════════════════════*/
