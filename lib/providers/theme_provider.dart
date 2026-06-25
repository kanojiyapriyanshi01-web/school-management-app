import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;
  ThemeMode get themeMode => _themeMode;
  ThemeProvider() { _load(); }
  Future<void> _load() async {
    final p = await SharedPreferences.getInstance();
    _themeMode = (p.getBool('dark') ?? false) ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }
  Future<void> toggle() async {
    _themeMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    final p = await SharedPreferences.getInstance();
    await p.setBool('dark', _themeMode == ThemeMode.dark);
    notifyListeners();
  }
}

