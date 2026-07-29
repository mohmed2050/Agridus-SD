class MarketPrice {
  final int? id;
  final String marketName;
  final int cropId;
  final double price;
  final double? lastWeekPrice;
  final String? updatedAt;

  MarketPrice({
    this.id,
    required this.marketName,
    required this.cropId,
    required this.price,
    this.lastWeekPrice,
    this.updatedAt,
  });

  double get changePercent {
    if (lastWeekPrice == null || lastWeekPrice == 0) return 0;
    return ((price - lastWeekPrice!) / lastWeekPrice!) * 100;
  }

  bool get isUp => changePercent > 0;
  bool get isDown => changePercent < 0;

  Map<String, dynamic> toMap() => {
        'market_name': marketName,
        'crop_id': cropId,
        'price': price,
        'last_week_price': lastWeekPrice,
        'updated_at': updatedAt ?? DateTime.now().toIso8601String(),
      };

  factory MarketPrice.fromMap(Map<String, dynamic> map) => MarketPrice(
        id: map['id'],
        marketName: map['market_name'] ?? '',
        cropId: map['crop_id'] ?? 0,
        price: (map['price'] ?? 0).toDouble(),
        lastWeekPrice: map['last_week_price']?.toDouble(),
        updatedAt: map['updated_at'],
      );
}
