class CalendarEntry {
  final int? id;
  final int cropId;
  final String state;
  final String plantingStart;
  final String plantingEnd;
  final int firstIrrigationDays;
  final int firstFertilizerDays;
  final int secondFertilizerDays;
  final int harvestDays;

  CalendarEntry({
    this.id,
    required this.cropId,
    required this.state,
    required this.plantingStart,
    required this.plantingEnd,
    this.firstIrrigationDays = 7,
    this.firstFertilizerDays = 21,
    this.secondFertilizerDays = 45,
    this.harvestDays = 105,
  });

  Map<String, dynamic> toMap() => {
        'crop_id': cropId,
        'state': state,
        'planting_start': plantingStart,
        'planting_end': plantingEnd,
        'first_irrigation_days': firstIrrigationDays,
        'first_fertilizer_days': firstFertilizerDays,
        'second_fertilizer_days': secondFertilizerDays,
        'harvest_days': harvestDays,
      };

  factory CalendarEntry.fromMap(Map<String, dynamic> map) => CalendarEntry(
        id: map['id'],
        cropId: map['crop_id'] ?? 0,
        state: map['state'] ?? '',
        plantingStart: map['planting_start'] ?? '',
        plantingEnd: map['planting_end'] ?? '',
        firstIrrigationDays: map['first_irrigation_days'] ?? 7,
        firstFertilizerDays: map['first_fertilizer_days'] ?? 21,
        secondFertilizerDays: map['second_fertilizer_days'] ?? 45,
        harvestDays: map['harvest_days'] ?? 105,
      );
}

class CalendarAlert {
  final int? id;
  final int cropId;
  final String state;
  final String alertType;
  final int daysOffset;
  final bool enabled;
  final int? taskId;
  final String? createdAt;

  CalendarAlert({
    this.id,
    required this.cropId,
    required this.state,
    required this.alertType,
    this.daysOffset = 0,
    this.enabled = true,
    this.taskId,
    this.createdAt,
  });

  Map<String, dynamic> toMap() => {
        'crop_id': cropId,
        'state': state,
        'alert_type': alertType,
        'days_offset': daysOffset,
        'enabled': enabled ? 1 : 0,
        'task_id': taskId,
        'created_at': createdAt ?? DateTime.now().toIso8601String(),
      };

  factory CalendarAlert.fromMap(Map<String, dynamic> map) => CalendarAlert(
        id: map['id'],
        cropId: map['crop_id'] ?? 0,
        state: map['state'] ?? '',
        alertType: map['alert_type'] ?? '',
        daysOffset: map['days_offset'] ?? 0,
        enabled: (map['enabled'] ?? 1) == 1,
        taskId: map['task_id'],
        createdAt: map['created_at'],
      );

  CalendarAlert copyWith({
    int? id,
    int? cropId,
    String? state,
    String? alertType,
    int? daysOffset,
    bool? enabled,
    int? taskId,
    String? createdAt,
  }) {
    return CalendarAlert(
      id: id ?? this.id,
      cropId: cropId ?? this.cropId,
      state: state ?? this.state,
      alertType: alertType ?? this.alertType,
      daysOffset: daysOffset ?? this.daysOffset,
      enabled: enabled ?? this.enabled,
      taskId: taskId ?? this.taskId,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
