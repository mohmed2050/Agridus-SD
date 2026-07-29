import 'package:flutter/foundation.dart';
import '../services/database_service.dart';
import '../models/pesticide.dart';

class GuideProvider extends ChangeNotifier {
  List<Pesticide> _pesticides = [];
  List<Fertilizer> _fertilizers = [];
  bool _isLoading = false;
  bool _isSeeded = false;
  String _searchQuery = '';
  int? _filterCropId;

  List<Pesticide> get pesticides => _pesticides;
  List<Fertilizer> get fertilizers => _fertilizers;
  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;
  int? get filterCropId => _filterCropId;

  List<Pesticide> get filteredPesticides {
    var result = _pesticides;
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      result = result.where((p) =>
          p.tradeName.toLowerCase().contains(q) ||
          p.activeIngredient.toLowerCase().contains(q) ||
          p.targets.contains(_searchQuery)).toList();
    }
    if (_filterCropId != null) {
      result = result
          .where((p) => p.cropIds.split(',').contains(_filterCropId.toString()))
          .toList();
    }
    return result;
  }

  List<Fertilizer> get filteredFertilizers {
    var result = _fertilizers;
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      result = result.where((f) =>
          f.tradeName.toLowerCase().contains(q) ||
          f.npk.toLowerCase().contains(q) ||
          f.targetCrops.contains(_searchQuery)).toList();
    }
    if (_filterCropId != null) {
      result = result
          .where((f) => f.cropIds.split(',').contains(_filterCropId.toString()))
          .toList();
    }
    return result;
  }

  Future<void> loadData() async {
    _isLoading = true;
    notifyListeners();

    final db = DatabaseService();
    final pRows = await db.query('pesticides', orderBy: 'trade_name ASC');
    if (pRows.isEmpty && !_isSeeded) {
      await _seedData();
      final p2 = await db.query('pesticides', orderBy: 'trade_name ASC');
      final f2 = await db.query('fertilizers', orderBy: 'trade_name ASC');
      _pesticides = p2.map((r) => Pesticide.fromMap(r)).toList();
      _fertilizers = f2.map((r) => Fertilizer.fromMap(r)).toList();
      _isSeeded = true;
    } else {
      _pesticides = pRows.map((r) => Pesticide.fromMap(r)).toList();
      final fRows = await db.query('fertilizers', orderBy: 'trade_name ASC');
      _fertilizers = fRows.map((r) => Fertilizer.fromMap(r)).toList();
    }

    _isLoading = false;
    notifyListeners();
  }

  void search(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void filterByCrop(int? cropId) {
    _filterCropId = cropId;
    notifyListeners();
  }

  Future<void> _seedData() async {
    final db = DatabaseService();
    for (final p in _pesticideSeedData) {
      await db.insert('pesticides', p);
    }
    for (final f in _fertilizerSeedData) {
      await db.insert('fertilizers', f);
    }
  }

  static const List<Map<String, dynamic>> _pesticideSeedData = [
    {
      'trade_name': 'دايمثويت 40% EC',
      'active_ingredient': 'Dimethoate 40%',
      'targets': 'المن، الجاسيد، التربس، حشرات ثاقبة ماصة',
      'crops': 'جميع المحاصيل الحقلية',
      'dosage': '1.5 لتر/فدان',
      'usage_method': 'رش ورقي بعد تخفيف بالماء',
      'safety_period': '14 يوماً',
      'warnings': 'سام للنحل، لا ترش أثناء التزهير',
      'crop_ids': '1,2,3,4,5',
    },
    {
      'trade_name': 'سايبرمثرين 25% EC',
      'active_ingredient': 'Cypermethrin 25%',
      'targets': 'دودة الحشد، دودة ورق القطن، حفار الساق',
      'crops': 'الذرة، القطن، الفول السوداني',
      'dosage': '0.5 لتر/فدان',
      'usage_method': 'رش ورقي',
      'safety_period': '7 أيام',
      'warnings': 'سام للأسماك، يمنع الرش قرب مصادر المياه',
      'crop_ids': '1,2,3',
    },
    {
      'trade_name': 'لمدا-سيهالوثرين 5% EC',
      'active_ingredient': 'Lambda-cyhalothrin 5%',
      'targets': 'دودة القرن في السمسم، المن، العنكبوت الأحمر',
      'crops': 'السمسم، الفول السوداني، الخضروات',
      'dosage': '0.3 لتر/فدان',
      'usage_method': 'رش ورقي عند ظهور الإصابة',
      'safety_period': '7 أيام',
      'warnings': 'شديد السمية للكائنات المائية',
      'crop_ids': '2,4',
    },
    {
      'trade_name': 'مانكوزيب 80% WP',
      'active_ingredient': 'Mancozeb 80%',
      'targets': 'التبقع السركوسبوري، الصدأ، البياض الدقيقي',
      'crops': 'الفول السوداني، القمح، الخضروات',
      'dosage': '2 كجم/فدان',
      'usage_method': 'رش وقائي كل 10-14 يوماً',
      'safety_period': '14 يوماً',
      'warnings': 'يرتدى قناع وقفازات أثناء الرش',
      'crop_ids': '2,3',
    },
    {
      'trade_name': 'أوكسي كلوريد النحاس 50% WP',
      'active_ingredient': 'Copper Oxychloride 50%',
      'targets': 'الأمراض الفطرية والبكتيرية، تبقع الأوراق',
      'crops': 'جميع المحاصيل',
      'dosage': '2 كجم/فدان',
      'usage_method': 'رش ورقي أو تعفير',
      'safety_period': '7 أيام',
      'warnings': 'يخزن في مكان جاف بعيداً عن الرطوبة',
      'crop_ids': '1,2,3,4,5',
    },
    {
      'trade_name': 'كلوربيريفوس 48% EC',
      'active_ingredient': 'Chlorpyrifos 48%',
      'targets': 'حشرة الدوبان، دودة الحشد، النمل الأبيض',
      'crops': 'جميع المحاصيل الحقلية',
      'dosage': '1 لتر/فدان',
      'usage_method': 'حقن في التربة أو رش ورقي',
      'safety_period': '21 يوماً',
      'warnings': 'شديد السمية، يمنع استخدامه على الخضروات الورقية',
      'crop_ids': '1,2,3,4,5',
    },
    {
      'trade_name': 'إيمامكتين بنزوات 1.9% EC',
      'active_ingredient': 'Emamectin benzoate 1.9%',
      'targets': 'دودة الحشد الخريفية، دودة ورق القطن',
      'crops': 'الذرة، القطن',
      'dosage': '0.4 لتر/فدان',
      'usage_method': 'رش ورقي عند ظهور الأطوار الصغيرة',
      'safety_period': '7 أيام',
      'warnings': 'سام للأسماك، يمنع الرش أيام الرياح',
      'crop_ids': '1',
    },
    {
      'trade_name': 'بروبيكونازول 25% EC',
      'active_ingredient': 'Propiconazole 25%',
      'targets': 'الصدأ الأصفر في القمح، البياض الدقيقي',
      'crops': 'القمح، الفول السوداني',
      'dosage': '0.5 لتر/فدان',
      'usage_method': 'رش ورقي عند ظهور الأعراض الأولى',
      'safety_period': '21 يوماً',
      'warnings': 'يستخدم بالتناوب مع مبيدات أخرى لمنع المقاومة',
      'crop_ids': '2,3',
    },
    {
      'trade_name': 'غلوفوسينات أمونيوم 20% SL',
      'active_ingredient': 'Glufosinate ammonium 20%',
      'targets': 'الحشائش الموسمية والحولية',
      'crops': 'جميع المحاصيل (مكافحة غير انتقائية)',
      'dosage': '2.5 لتر/فدان',
      'usage_method': 'رش على الحشائش النامية قبل الزراعة أو بعدها',
      'safety_period': 'لا يوجد',
      'warnings': 'مبيد غير انتقائي، تجنب وصوله للمحصول',
      'crop_ids': '1,2,3,4,5',
    },
    {
      'trade_name': 'أبامكتين 1.8% EC',
      'active_ingredient': 'Abamectin 1.8%',
      'targets': 'العنكبوت الأحمر، حفار الأوراق، التربس',
      'crops': 'المحاصيل الحقلية والخضروات',
      'dosage': '0.4 لتر/فدان',
      'usage_method': 'رش ورقي مع تركيز على السطح السفلي للأوراق',
      'safety_period': '7 أيام',
      'warnings': 'سام جداً للأسماك واللافقاريات المائية',
      'crop_ids': '1,2,3,4,5',
    },
    {
      'trade_name': 'داينيفيوران 50% SG',
      'active_ingredient': 'Dinotefuran 50%',
      'targets': 'المن، الجاسيد، الذبابة البيضاء',
      'crops': 'المحاصيل الحقلية',
      'dosage': '0.3 كجم/فدان',
      'usage_method': 'رش ورقي',
      'safety_period': '10 أيام',
      'warnings': 'سام للنحل لمدة 48 ساعة بعد الرش',
      'crop_ids': '1,2,3,4,5',
    },
    {
      'trade_name': 'كاربندازيم 50% SC',
      'active_ingredient': 'Carbendazim 50%',
      'targets': 'تعفن الجذور، الذبول، تبقع الأوراق',
      'crops': 'جميع المحاصيل',
      'dosage': '1 لتر/فدان',
      'usage_method': 'معاملة البذور أو رش ورقي',
      'safety_period': '14 يوماً',
      'warnings': 'يستخدم بحذر على بعض أصناف الخضروات',
      'crop_ids': '1,2,3,4,5',
    },
  ];

  static const List<Map<String, dynamic>> _fertilizerSeedData = [
    {
      'trade_name': 'يوريا 46% N',
      'fertilizer_type': 'كيميائي - نيتروجيني',
      'npk': '46-0-0',
      'target_crops': 'جميع المحاصيل الحقلية',
      'dosage': '2-3 شيكارة/فدان (50 كجم للشيكارة)',
      'application_time': 'بعد 21 يوماً من الزراعة (دفعة أولى) وبعد 45 يوماً (دفعة ثانية)',
      'application_method': 'نثر على الخطوط ثم الري مباشرة',
      'crop_ids': '1,2,3,4,5',
    },
    {
      'trade_name': 'سوبر فوسفات 48% P2O5',
      'fertilizer_type': 'كيميائي - فوسفاتي',
      'npk': '0-48-0',
      'target_crops': 'جميع المحاصيل، ضروري للبقوليات',
      'dosage': '2-3 شيكارة/فدان',
      'application_time': 'مع الزراعة أو قبلها',
      'application_method': 'نثر في التربة قبل الحرثة الأخيرة',
      'crop_ids': '1,2,3,4,5',
    },
    {
      'trade_name': 'سلفات البوتاسيوم 50% K2O',
      'fertilizer_type': 'كيميائي - بوتاسي',
      'npk': '0-0-50',
      'target_crops': 'جميع المحاصيل، أساسي للمحاصيل الزيتية',
      'dosage': '1-1.5 شيكارة/فدان',
      'application_time': 'عند بداية التزهير وعقد الثمار',
      'application_method': 'نثر أو إذابة في مياه الري',
      'crop_ids': '2,4',
    },
    {
      'trade_name': 'سماد مركب NPK 15-15-15',
      'fertilizer_type': 'كيميائي - مركب',
      'npk': '15-15-15',
      'target_crops': 'جميع المحاصيل',
      'dosage': '2-3 شيكارة/فدان',
      'application_time': 'مع الزراعة أو بعد 15 يوماً',
      'application_method': 'نثر في التربة',
      'crop_ids': '1,2,3,4,5',
    },
    {
      'trade_name': 'سلفات الزنك 35% Zn',
      'fertilizer_type': 'كيميائي - عناصر صغرى',
      'npk': 'Zn 35%',
      'target_crops': 'القمح، الذرة، الأرز',
      'dosage': '1 كجم/فدان',
      'application_time': 'قبل الزراعة أو مع مياه الري',
      'application_method': 'إضافة للتربة أو رش ورقي',
      'crop_ids': '1,3',
    },
    {
      'trade_name': 'سماد بلدي (متحلل)',
      'fertilizer_type': 'عضوي',
      'npk': 'محتوى متغير (0.5-1% N, 0.3-0.6% P, 0.5-1% K)',
      'target_crops': 'جميع المحاصيل',
      'dosage': '5-10 طن/فدان',
      'application_time': 'قبل الزراعة بأسبوعين على الأقل',
      'application_method': 'نشر على سطح التربة ثم حرث',
      'crop_ids': '1,2,3,4,5',
    },
    {
      'trade_name': 'نترات الأمونيوم 33.5% N',
      'fertilizer_type': 'كيميائي - نيتروجيني',
      'npk': '33.5-0-0',
      'target_crops': 'القمح، الخضروات، الأعلاف',
      'dosage': '1.5-2 شيكارة/فدان',
      'application_time': 'بعد الزراعة وقبل الري',
      'application_method': 'نثر على سطح التربة',
      'crop_ids': '3,5',
    },
    {
      'trade_name': 'كبريت زراعي 99%',
      'fertilizer_type': 'كيميائي - محسن تربة',
      'npk': 'S 99%',
      'target_crops': 'جميع المحاصيل في الأراضي القلوية',
      'dosage': '10-15 كجم/فدان',
      'application_time': 'قبل الزراعة بشهر',
      'application_method': 'نثر في التربة وحرث',
      'crop_ids': '1,2,3,4,5',
    },
    {
      'trade_name': 'سلفات الماغنسيوم 16% MgO',
      'fertilizer_type': 'كيميائي - عناصر صغرى',
      'npk': 'MgO 16% + S 13%',
      'target_crops': 'البرسيم، البطاطس، المحاصيل الورقية',
      'dosage': '5 كجم/فدان',
      'application_time': 'عند ظهور أعراض نقص الماغنسيوم',
      'application_method': 'إضافة للتربة أو رش ورقي',
      'crop_ids': '5',
    },
    {
      'trade_name': 'حمض الهيوميك 85%',
      'fertilizer_type': 'عضوي - محسن تربة',
      'npk': 'Humic Acid 85%',
      'target_crops': 'جميع المحاصيل',
      'dosage': '2-4 كجم/فدان',
      'application_time': 'مع الزراعة أو بداية الري',
      'application_method': 'إضافة مع مياه الري',
      'crop_ids': '1,2,3,4,5',
    },
  ];
}
