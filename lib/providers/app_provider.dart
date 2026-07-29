import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppProvider extends ChangeNotifier {
  int _currentTabIndex = 0;
  bool _isDarkMode = false;

  int get currentTabIndex => _currentTabIndex;
  bool get isDarkMode => _isDarkMode;

  void setTabIndex(int index) {
    _currentTabIndex = index;
    notifyListeners();
  }

  Future<void> loadDarkMode() async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool('dark_mode') ?? false;
    notifyListeners();
  }

  Future<void> toggleDarkMode() async {
    _isDarkMode = !_isDarkMode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('dark_mode', _isDarkMode);
    notifyListeners();
  }
}
