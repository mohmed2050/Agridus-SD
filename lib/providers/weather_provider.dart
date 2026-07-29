import 'package:flutter/foundation.dart';
import 'package:location/location.dart';
import '../services/weather_service.dart';

class WeatherProvider extends ChangeNotifier {
  WeatherData? _weather;
  PrayerTimeData? _prayerTimes;
  bool _isLoading = false;
  bool _hasLocation = false;
  double _lat = 15.5007;
  double _lon = 32.5599;

  WeatherData? get weather => _weather;
  PrayerTimeData? get prayerTimes => _prayerTimes;
  bool get isLoading => _isLoading;
  bool get hasLocation => _hasLocation;

  Future<void> loadData() async {
    _isLoading = true;
    notifyListeners();

    await _requestLocation();

    _weather = await WeatherService.fetchWeather(lat: _lat, lon: _lon);
    _prayerTimes = WeatherService.calculatePrayerTimes(lat: _lat, lon: _lon);

    if (_weather != null) {
      await WeatherService.checkWeatherAlert(_weather!);
    }

    await WeatherService.schedulePrayerNotifications(lat: _lat, lon: _lon);

    _isLoading = false;
    notifyListeners();
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
