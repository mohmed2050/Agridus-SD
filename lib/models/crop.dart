class Crop {
  final int id;
  final String name;
  final String nameEn;
  final String icon;
  final String description;
  final String seasonMonths;
  final String growthDays;
  final String averageYield;
  final String image;
  final String iconTheme;
  final String category;
  final String pests;
  final String diseases;
  final String season;
  final String soil;
  final String phLevel;
  final String landPrep;
  final String plantingMethod;
  final String irrigation;
  final String fertilization;
  final String harvest;
  final String profitability;

  Crop({
    required this.id,
    required this.name,
    required this.nameEn,
    required this.icon,
    required this.description,
    required this.seasonMonths,
    required this.growthDays,
    required this.averageYield,
    required this.image,
    required this.iconTheme,
    required this.category,
    required this.pests,
    required this.diseases,
    required this.season,
    required this.soil,
    required this.phLevel,
    required this.landPrep,
    required this.plantingMethod,
    required this.irrigation,
    required this.fertilization,
    required this.harvest,
    required this.profitability,
  });

  factory Crop.fromJson(Map<String, dynamic> json) {
    return Crop(
      id: json['id'],
      name: json['name'],
      nameEn: json['name_en'],
      icon: json['icon'],
      description: json['description'] ?? '',
      seasonMonths: json['season_months'] ?? '',
      growthDays: json['growth_days'] ?? '',
      averageYield: json['average_yield'] ?? '',
      image: json['image'] ?? '',
      iconTheme: json['icon_theme'] ?? 'green',
      category: json['category'] ?? '',
      pests: json['pests'],
      diseases: json['diseases'],
      season: json['season'],
      soil: json['soil'],
      phLevel: json['ph_level'],
      landPrep: json['land_prep'],
      plantingMethod: json['planting_method'],
      irrigation: json['irrigation'],
      fertilization: json['fertilization'],
      harvest: json['harvest'],
      profitability: json['profitability'],
    );
  }
}