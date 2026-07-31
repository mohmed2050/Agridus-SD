import 'package:flutter/foundation.dart';
import 'package:location/location.dart';
import '../services/weather_service.dart';

class WeatherProvider extends ChangeNotifier {
  WeatherData? _weather;
  PrayerTimeData? _prayerTimes;
  bool _isLoading = false;
  bool _hasLocation = false;
  String? _error;
  double _lat = 15.5007;
  double _lon = 32.5599;

  WeatherData? get weather => _weather;
  PrayerTimeData? get prayerTimes => _prayerTimes;
  bool get isLoading => _isLoading;
  bool get hasLocation => _hasLocation;
  String? get error => _error;

  Future<void> loadData() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await Future.any([
        _doLoad(),
        Future.delayed(const Duration(seconds: 25)),
      ]);
    } catch (_) {}

    _isLoading = false;
    notifyListeners();
  }

  Future<void> _doLoad() async {
    try {
      await _requestLocation().timeout(const Duration(seconds: 8));
    } catch (_) {}

    try {
      _weather = await WeatherService
          .fetchWeather(lat: _lat, lon: _lon)
          .timeout(const Duration(seconds: 12));
    } catch (_) {}

    try {
      _prayerTimes = WeatherService.calculatePrayerTimes(lat: _lat, lon: _lon);
    } catch (_) {}

    try {
      await WeatherService
          .schedulePrayerNotifications(lat: _lat, lon: _lon)
          .timeout(const Duration(seconds: 8));
    } catch (_) {}
  }

  Future<void> _requestLocation() async {
    try {
      final location = Location();
      bool serviceEnabled = await location.serviceEnabled();
      if (!serviceEnabled) {
        serviceEnabled = await location.requestService();
      }

      PermissionStatus permission = await location.hasPermission();
      if (permission == PermissionStatus.denied) {
        permission = await location.requestPermission();
      }

      if (permission == PermissionStatus.granted) {
        final locData = await location.getLocation();
        if (locData.latitude != null && locData.longitude != null) {
          _lat = locData.latitude!;
          _lon = locData.longitude!;
          _hasLocation = true;
        }
      }
    } catch (_) {}
  }

  String get locationName {
    if (_hasLocation) {
      return 'موقعك الحالي';
    }
    return 'الخرطوم (افتراضي)';
  }
}
