import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import '../models/crop.dart';

class CropProvider extends ChangeNotifier {
  List<Crop> _crops = [];
  bool _isLoading = false;

  List<Crop> get crops => _crops;
  bool get isLoading => _isLoading;

  Future<void> loadCrops() async {
    _isLoading = true;
    notifyListeners();

    try {
      final jsonString = await rootBundle.loadString('assets/data/crops.json');
      final data = jsonDecode(jsonString);
      final List<dynamic> cropList = data['crops'];
      _crops = cropList.map((c) => Crop.fromJson(c)).toList();
    } catch (e) {
      debugPrint('Error loading crops: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Crop? getCropById(int id) {
    try {
      return _crops.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }
}
