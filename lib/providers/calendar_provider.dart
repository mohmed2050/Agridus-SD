import 'package:flutter/foundation.dart';
import '../services/database_service.dart';
import '../services/notification_service.dart';
import '../models/calendar_entry.dart';

class CalendarProvider extends ChangeNotifier {
  List<CalendarEntry> _entries = [];
  List<CalendarAlert> _alerts = [];
  String _selectedState = 'الجزيرة';
  int? _selectedCropId;
  bool _isLoading = false;
  bool _isSeeded = false;

  List<CalendarEntry> get entries => _entries;
  List<CalendarAlert> get alerts => _alerts;
  String get selectedState => _selectedState;
  int? get selectedCropId => _selectedCropId;
  bool get isLoading => _isLoading;

  List<CalendarEntry> get filteredEntries {
    var result = _entries.where((e) => e.state == _selectedState);
    if (_selectedCropId != null) {
      result = result.where((e) => e.cropId == _selectedCropId);
    }
    return result.toList();
  }

  List<String> get states {
    final s = _entries.map((e) => e.state).toSet().toList();
    s.sort();
    return s;
  }

  String get cropName {
    switch (_selectedCropId) {
      case 1: return 'أبو سبعين';
      case 2: return 'الفول السوداني';
      case 3: return 'القمح';
      case 4: return 'السمسم';
      case 5: return 'البرسيم';
      default: return 'الكل';
    }
  }

  Future<void> loadData() async {
    _isLoading = true;
    notifyListeners();

    final db = DatabaseService();
    final rows = await db.query('calendar', orderBy: 'crop_id ASC');
    if (rows.isEmpty && !_isSeeded) {
      await _seedData();
      final seeded = await db.query('calendar', orderBy: 'crop_id ASC');
      _entries = seeded.map((r) => CalendarEntry.fromMap(r)).toList();
      _isSeeded = true;
    } else {
      _entries = rows.map((r) => CalendarEntry.fromMap(r)).toList();
    }

    final alertRows = await db.query('calendar_alerts', orderBy: 'crop_id ASC');
    _alerts = alertRows.map((r) => CalendarAlert.fromMap(r)).toList();

    _isLoading = false;
    notifyListeners();
  }

  void setState(String state) {
    _selectedState = state;
    notifyListeners();
  }

  void setCrop(int? cropId) {
    _selectedCropId = cropId;
    notifyListeners();
  }

  void toggleAlert(int alertId) async {
    final db = DatabaseService();
    final index = _alerts.indexWhere((a) => a.id == alertId);
    if (index == -1) return;

    final alert = _alerts[index];
    final newStatus = !alert.enabled;
    await db.update('calendar_alerts', {'enabled': newStatus ? 1 : 0},
        where: 'id = ?', whereArgs: [alertId]);

    _alerts[index] = alert.copyWith(enabled: newStatus);

    if (!newStatus && alert.taskId != null) {
      await NotificationService().cancelNotification(alert.taskId!);
    }

    notifyListeners();
  }

  Future<void> generateAlertsForCrop(int cropId) async {
    final db = DatabaseService();
    final entriesForCrop = _entries.where((e) =>
        e.cropId == cropId && e.state == _selectedState);

    for (final entry in entriesForCrop) {
      final plantingMonth = _monthToNumber(entry.plantingStart);
      final year = DateTime.now().year;
      final baseDate = DateTime(year, plantingMonth, 15);

      final alertsToCreate = [
        {'type': 'planting', 'offset': 0, 'title': 'موعد زراعة ${_cropName(cropId)} في $_selectedState'},
        {'type': 'irrigation1', 'offset': entry.firstIrrigationDays, 'title': 'موعد أول ري لـ ${_cropName(cropId)}'},
        {'type': 'fertilizer1', 'offset': entry.firstFertilizerDays, 'title': 'موعد التسميد الأول لـ ${_cropName(cropId)}'},
        {'type': 'fertilizer2', 'offset': entry.secondFertilizerDays, 'title': 'موعد التسميد الثاني لـ ${_cropName(cropId)}'},
        {'type': 'harvest', 'offset': entry.harvestDays, 'title': 'موعد حصاد ${_cropName(cropId)}'},
      ];

      for (final a in alertsToCreate) {
        final existing = _alerts.where((x) =>
            x.cropId == cropId &&
            x.state == _selectedState &&
            x.alertType == a['type']).toList();

        if (existing.isNotEmpty) continue;

        final alertDate = baseDate.add(Duration(days: a['offset'] as int));
        final taskId = await db.insert('tasks', {
          'title': a['title'],
          'alert_time': alertDate.toIso8601String(),
          'recurrence': 'once',
          'is_completed': 0,
          'created_at': DateTime.now().toIso8601String(),
        });

        if (alertDate.isAfter(DateTime.now())) {
          NotificationService().scheduleTaskNotification(taskId, a['title'] as String, alertDate);
        }

        final alert = CalendarAlert(
          cropId: cropId,
          state: _selectedState,
          alertType: a['type'] as String,
          daysOffset: a['offset'] as int,
          taskId: taskId,
        );
        final alertId = await db.insert('calendar_alerts', alert.toMap());
        _alerts.add(CalendarAlert.fromMap({...alert.toMap(), 'id': alertId}));
      }
    }
    notifyListeners();
  }

  Future<void> deleteAlertsForCrop(int cropId) async {
    final db = DatabaseService();
    final toDelete = _alerts.where((a) =>
        a.cropId == cropId && a.state == _selectedState).toList();

    for (final alert in toDelete) {
      if (alert.taskId != null) {
        await db.delete('tasks', where: 'id = ?', whereArgs: [alert.taskId]);
        await NotificationService().cancelNotification(alert.taskId!);
      }
      await db.delete('calendar_alerts', where: 'id = ?', whereArgs: [alert.id]);
    }

    _alerts.removeWhere((a) =>
        a.cropId == cropId && a.state == _selectedState);
    notifyListeners();
  }

  List<CalendarAlert> getAlertsForCrop(int cropId) {
    return _alerts.where((a) =>
        a.cropId == cropId && a.state == _selectedState).toList();
  }

  String _cropName(int id) {
    switch (id) {
      case 1: return 'أبو سبعين';
      case 2: return 'الفول السوداني';
      case 3: return 'القمح';
      case 4: return 'السمسم';
      case 5: return 'البرسيم';
      default: return '';
    }
  }

  int _monthToNumber(String month) {
    switch (month) {
      case 'يناير': return 1;
      case 'فبراير': return 2;
      case 'مارس': return 3;
      case 'أبريل': return 4;
      case 'مايو': return 5;
      case 'يونيو': return 6;
      case 'يوليو': return 7;
      case 'أغسطس': return 8;
      case 'سبتمبر': return 9;
      case 'أكتوبر': return 10;
      case 'نوفمبر': return 11;
      case 'ديسمبر': return 12;
      default: return 6;
    }
  }

  Future<void> _seedData() async {
    final db = DatabaseService();
    final data = _getSeedData();
    for (final entry in data) {
      await db.insert('calendar', entry);
    }
  }

  List<Map<String, dynamic>> _getSeedData() {
    const crops = [
      {'id': 1, 'irr': 8, 'fer1': 21, 'fer2': 45, 'harv': 75},
      {'id': 2, 'irr': 6, 'fer1': 30, 'fer2': 60, 'harv': 135},
      {'id': 3, 'irr': 12, 'fer1': 21, 'fer2': 50, 'harv': 140},
      {'id': 4, 'irr': 8, 'fer1': 25, 'fer2': 55, 'harv': 105},
      {'id': 5, 'irr': 8, 'fer1': 15, 'fer2': 35, 'harv': 65},
    ];

    final states = [
      'الخرطوم', 'الجزيرة', 'نهر النيل', 'البحر الأحمر',
      'القضارف', 'كسلا', 'سنار', 'النيل الأبيض',
      'شمال كردفان', 'جنوب كردفان', 'شمال دارفور', 'جنوب دارفور',
      'غرب دارفور', 'شرق دارفور', 'وسط دارفور', 'الشمالية',
      'النيل الأزرق', 'غرب كردفان',
    ];

    const cropMonths = {
      1: {'start': 'يونيو', 'end': 'يوليو'},
      2: {'start': 'يونيو', 'end': 'يوليو'},
      3: {'start': 'نوفمبر', 'end': 'ديسمبر'},
      4: {'start': 'يوليو', 'end': 'أغسطس'},
      5: {'start': 'أكتوبر', 'end': 'نوفمبر'},
    };

    final List<Map<String, dynamic>> result = [];

    for (final crop in crops) {
      for (final state in states) {
        final months = cropMonths[crop['id']]!;
        result.add({
          'crop_id': crop['id'],
          'state': state,
          'planting_start': months['start'],
          'planting_end': months['end'],
          'first_irrigation_days': crop['irr'],
          'first_fertilizer_days': crop['fer1'],
          'second_fertilizer_days': crop['fer2'],
          'harvest_days': crop['harv'],
        });
      }
    }

    return result;
  }
}
