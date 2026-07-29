class Pesticide {
  final int? id;
  final String tradeName;
  final String activeIngredient;
  final String targets;
  final String crops;
  final String dosage;
  final String usageMethod;
  final String safetyPeriod;
  final String warnings;
  final String cropIds;

  Pesticide({
    this.id,
    required this.tradeName,
    required this.activeIngredient,
    required this.targets,
    required this.crops,
    required this.dosage,
    required this.usageMethod,
    required this.safetyPeriod,
    required this.warnings,
    required this.cropIds,
  });

  Map<String, dynamic> toMap() => {
        'trade_name': tradeName,
        'active_ingredient': activeIngredient,
        'targets': targets,
        'crops': crops,
        'dosage': dosage,
        'usage_method': usageMethod,
        'safety_period': safetyPeriod,
        'warnings': warnings,
        'crop_ids': cropIds,
      };

  factory Pesticide.fromMap(Map<String, dynamic> map) => Pesticide(
        id: map['id'],
        tradeName: map['trade_name'] ?? '',
        activeIngredient: map['active_ingredient'] ?? '',
        targets: map['targets'] ?? '',
        crops: map['crops'] ?? '',
        dosage: map['dosage'] ?? '',
        usageMethod: map['usage_method'] ?? '',
        safetyPeriod: map['safety_period'] ?? '',
        warnings: map['warnings'] ?? '',
        cropIds: map['crop_ids'] ?? '',
      );
}

class Fertilizer {
  final int? id;
  final String tradeName;
  final String fertilizerType;
  final String npk;
  final String targetCrops;
  final String dosage;
  final String applicationTime;
  final String applicationMethod;
  final String cropIds;

  Fertilizer({
    this.id,
    required this.tradeName,
    required this.fertilizerType,
    required this.npk,
    required this.targetCrops,
    required this.dosage,
    required this.applicationTime,
    required this.applicationMethod,
    required this.cropIds,
  });

  Map<String, dynamic> toMap() => {
        'trade_name': tradeName,
        'fertilizer_type': fertilizerType,
        'npk': npk,
        'target_crops': targetCrops,
        'dosage': dosage,
        'application_time': applicationTime,
        'application_method': applicationMethod,
        'crop_ids': cropIds,
      };

  factory Fertilizer.fromMap(Map<String, dynamic> map) => Fertilizer(
        id: map['id'],
        tradeName: map['trade_name'] ?? '',
        fertilizerType: map['fertilizer_type'] ?? '',
        npk: map['npk'] ?? '',
        targetCrops: map['target_crops'] ?? '',
        dosage: map['dosage'] ?? '',
        applicationTime: map['application_time'] ?? '',
        applicationMethod: map['application_method'] ?? '',
        cropIds: map['crop_ids'] ?? '',
      );
}
