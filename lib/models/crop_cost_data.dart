class CropCostData {
  final int id;
  final String name;
  final String icon;
  final double seedCost;
  final double fertilizerCost;
  final double irrigationCost;
  final double laborCost;
  final double pesticideCost;
  final double expectedProductionKg;
  final double pricePerKg;

  const CropCostData({
    required this.id,
    required this.name,
    required this.icon,
    required this.seedCost,
    required this.fertilizerCost,
    required this.irrigationCost,
    required this.laborCost,
    required this.pesticideCost,
    required this.expectedProductionKg,
    required this.pricePerKg,
  });

  double get totalCostPerFeddan =>
      seedCost + fertilizerCost + irrigationCost + laborCost + pesticideCost;

  double get revenuePerFeddan => expectedProductionKg * pricePerKg;

  double get netProfitPerFeddan => revenuePerFeddan - totalCostPerFeddan;

  static const List<CropCostData> all = [
    CropCostData(
      id: 1,
      name: 'أبو سبعين',
      icon: '🌾',
      seedCost: 35000,
      fertilizerCost: 50000,
      irrigationCost: 25000,
      laborCost: 35000,
      pesticideCost: 20000,
      expectedProductionKg: 1500,
      pricePerKg: 130,
    ),
    CropCostData(
      id: 2,
      name: 'الفول السوداني',
      icon: '🥜',
      seedCost: 28000,
      fertilizerCost: 40000,
      irrigationCost: 20000,
      laborCost: 30000,
      pesticideCost: 15000,
      expectedProductionKg: 1000,
      pricePerKg: 180,
    ),
    CropCostData(
      id: 3,
      name: 'القمح',
      icon: '🌾',
      seedCost: 45000,
      fertilizerCost: 55000,
      irrigationCost: 30000,
      laborCost: 40000,
      pesticideCost: 25000,
      expectedProductionKg: 1800,
      pricePerKg: 140,
    ),
    CropCostData(
      id: 4,
      name: 'السمسم',
      icon: '🌱',
      seedCost: 25000,
      fertilizerCost: 35000,
      irrigationCost: 20000,
      laborCost: 30000,
      pesticideCost: 15000,
      expectedProductionKg: 800,
      pricePerKg: 350,
    ),
    CropCostData(
      id: 5,
      name: 'البرسيم',
      icon: '🌿',
      seedCost: 15000,
      fertilizerCost: 35000,
      irrigationCost: 20000,
      laborCost: 20000,
      pesticideCost: 15000,
      expectedProductionKg: 8000,
      pricePerKg: 20,
    ),
  ];

  static const CropCostData? mostProfitable = null;
}
