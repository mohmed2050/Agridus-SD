import 'dart:math';
import 'package:flutter/foundation.dart';
import '../services/database_service.dart';
import '../models/market_price.dart';

class MarketProvider extends ChangeNotifier {
  List<MarketPrice> _prices = [];
  bool _isLoading = false;
  bool _isSeeded = false;
  int? _selectedCropId;

  List<MarketPrice> get prices => _prices;
  bool get isLoading => _isLoading;
  int? get selectedCropId => _selectedCropId;

  List<String> get markets {
    final s = _prices.map((p) => p.marketName).toSet().toList();
    return s;
  }

  List<MarketPrice> get filteredPrices {
    if (_selectedCropId == null) return _prices;
    return _prices.where((p) => p.cropId == _selectedCropId).toList();
  }

  MarketPrice? bestPrice(int cropId) {
    final cropPrices = _prices.where((p) => p.cropId == cropId).toList();
    if (cropPrices.isEmpty) return null;
    cropPrices.sort((a, b) => b.price.compareTo(a.price));
    return cropPrices.first;
  }

  MarketPrice? pricesForMarketAndCrop(String market, int cropId) {
    try {
      return _prices.firstWhere(
          (p) => p.marketName == market && p.cropId == cropId);
    } catch (_) {
      return null;
    }
  }

  void selectCrop(int? cropId) {
    _selectedCropId = cropId;
    notifyListeners();
  }

  Future<void> loadData() async {
    _isLoading = true;
    notifyListeners();

    final db = DatabaseService();
    final rows = await db.query('market_prices', orderBy: 'market_name ASC');

    if (rows.isEmpty && !_isSeeded) {
      await _seedData();
      final seeded = await db.query('market_prices', orderBy: 'market_name ASC');
      _prices = seeded.map((r) => MarketPrice.fromMap(r)).toList();
      _isSeeded = true;
    } else {
      _prices = rows.map((r) => MarketPrice.fromMap(r)).toList();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> _seedData() async {
    final db = DatabaseService();
    final rng = Random(42);
    const markets = ['الخرطوم', 'ود مدني', 'بورتسودان', 'الأبيض', 'كسلا'];

    const priceData = {
      1: [85, 80, 90, 78, 82],
      2: [125, 120, 130, 115, 122],
      3: [75, 70, 80, 68, 72],
      4: [360, 350, 370, 340, 355],
      5: [16, 15, 17, 14, 15],
    };

    for (int cropId = 1; cropId <= 5; cropId++) {
      final cropPrices = priceData[cropId]!;
      for (int mi = 0; mi < markets.length; mi++) {
        final price = cropPrices[mi].toDouble();
        final variation = rng.nextInt(11) - 5;
        final lastWeek = price + variation;

        await db.insert('market_prices', {
          'market_name': markets[mi],
          'crop_id': cropId,
          'price': price,
          'last_week_price': lastWeek,
          'updated_at': DateTime.now().toIso8601String(),
        });
      }
    }
  }
}
