import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import '../models/crop.dart';

class CropProvider extends ChangeNotifier {
  List<Crop> _crops = [];
  bool _isLoading = false;
  String _searchQuery = '';
  String _filterCategory = '';

  List<Crop> get crops => _crops;
  bool get isLoading => _isLoading;
  String get filterCategory => _filterCategory;

  List<Crop> get filteredCrops {
    var list = _crops;
    final q = _searchQuery.trim();
    if (q.isNotEmpty) {
      list = list.where((c) {
        return c.name.contains(q) ||
            c.nameEn.toLowerCase().contains(q.toLowerCase()) ||
            c.description.contains(q);
      }).toList();
    }
    if (_filterCategory.isNotEmpty) {
      list = list.where((c) => c.category == _filterCategory).toList();
    }
    return list;
  }

  void search(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setFilterCategory(String category) {
    _filterCategory = category;
    notifyListeners();
  }

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
