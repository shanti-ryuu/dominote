import 'package:flutter/material.dart';
import '../services/theme_service.dart';

class ThemeProvider with ChangeNotifier {
  final ThemeService _themeService = ThemeService();
  
  bool get isDarkMode => _themeService.isDarkMode;
  ThemeData get currentTheme => _themeService.currentTheme;
  
  Future<void> toggleTheme() async {
    await _themeService.toggleTheme();
    notifyListeners();
  }
  
  Future<void> setDarkMode(bool value) async {
    await _themeService.setDarkMode(value);
    notifyListeners();
  }
}
