import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/notification_service.dart';

class AppProvider extends ChangeNotifier {
  int _currentTabIndex = 0;
  bool _isDarkMode = false;
  bool _notificationsEnabled = true;
  bool _prayerAlertsEnabled = true;
  bool _weatherAlertsEnabled = true;
  bool _taskAlertsEnabled = true;
  bool _calendarAlertsEnabled = true;
  int _selectedSoundIndex = 0;
  int _vibrationIntensity = 2;
  double _fontScale = 1.0;

  int get currentTabIndex => _currentTabIndex;
  bool get isDarkMode => _isDarkMode;
  bool get notificationsEnabled => _notificationsEnabled;
  bool get prayerAlertsEnabled => _prayerAlertsEnabled;
  bool get weatherAlertsEnabled => _weatherAlertsEnabled;
  bool get taskAlertsEnabled => _taskAlertsEnabled;
  bool get calendarAlertsEnabled => _calendarAlertsEnabled;
  int get selectedSoundIndex => _selectedSoundIndex;
  int get vibrationIntensity => _vibrationIntensity;
  double get fontScale => _fontScale;

  String get selectedSoundName {
    switch (_selectedSoundIndex) {
      case 0: return 'صوت افتراضي';
      case 1: return 'أذان الفجر';
      case 2: return 'أذان عادي';
      case 3: return 'صوت إسلامي';
      case 4: return 'صامت';
      default: return 'صوت افتراضي';
    }
  }

  String get selectedSoundFile {
    switch (_selectedSoundIndex) {
      case 1: return 'azan_fajr.mp3';
      case 2: return 'azan_normal.mp3';
      case 3: return 'notification_islamic.mp3';
      default: return '';
    }
  }

  String get vibrationLabel {
    switch (_vibrationIntensity) {
      case 0: return 'بدون اهتزاز';
      case 1: return 'خفيف';
      case 2: return 'متوسط';
      case 3: return 'قوي';
      default: return 'متوسط';
    }
  }

  void setTabIndex(int index) {
    _currentTabIndex = index;
    notifyListeners();
  }

  Future<void> loadAll() async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool('dark_mode') ?? false;
    _notificationsEnabled = prefs.getBool('notifications_enabled') ?? true;
    _prayerAlertsEnabled = prefs.getBool('prayer_alerts_enabled') ?? true;
    _weatherAlertsEnabled = prefs.getBool('weather_alerts_enabled') ?? true;
    _taskAlertsEnabled = prefs.getBool('task_alerts_enabled') ?? true;
    _calendarAlertsEnabled = prefs.getBool('calendar_alerts_enabled') ?? true;
    _selectedSoundIndex = prefs.getInt('selected_sound') ?? 0;
    _vibrationIntensity = prefs.getInt('vibration_intensity') ?? 2;
    _fontScale = prefs.getDouble('font_scale') ?? 1.0;
    NotificationService().setSelectedSound(_selectedSoundIndex);
    notifyListeners();
  }

  Future<void> toggleDarkMode() async {
    _isDarkMode = !_isDarkMode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('dark_mode', _isDarkMode);
    notifyListeners();
  }

  Future<void> setNotificationsEnabled(bool v) async {
    _notificationsEnabled = v;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications_enabled', v);
    notifyListeners();
  }

  Future<void> setPrayerAlertsEnabled(bool v) async {
    _prayerAlertsEnabled = v;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('prayer_alerts_enabled', v);
    notifyListeners();
  }

  Future<void> setWeatherAlertsEnabled(bool v) async {
    _weatherAlertsEnabled = v;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('weather_alerts_enabled', v);
    notifyListeners();
  }

  Future<void> setTaskAlertsEnabled(bool v) async {
    _taskAlertsEnabled = v;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('task_alerts_enabled', v);
    notifyListeners();
  }

  Future<void> setCalendarAlertsEnabled(bool v) async {
    _calendarAlertsEnabled = v;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('calendar_alerts_enabled', v);
    notifyListeners();
  }

  Future<void> setSelectedSound(int index) async {
    _selectedSoundIndex = index;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('selected_sound', index);
    NotificationService().setSelectedSound(index);
    notifyListeners();
  }

  Future<void> setVibrationIntensity(int v) async {
    _vibrationIntensity = v;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('vibration_intensity', v);
    notifyListeners();
  }

  Future<void> setFontScale(double v) async {
    _fontScale = v;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('font_scale', v);
    notifyListeners();
  }
}
