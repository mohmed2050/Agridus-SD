import 'package:flutter/foundation.dart';
import '../services/database_service.dart';
import '../models/extension_office.dart';
import '../models/extension_company.dart';

class ExtensionProvider extends ChangeNotifier {
  List<ExtensionOffice> _offices = [];
  List<ExtensionCompany> _companies = [];
  bool _isLoading = false;
  bool _isSeeded = false;
  String _searchQuery = '';
  Future<void>? _seedFuture;

  List<ExtensionOffice> get offices => _offices;
  List<ExtensionCompany> get companies => _companies;
  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;

  List<String> get states {
    final s = _offices.map((o) => o.state).toSet().toList();
    s.sort((a, b) => a.compareTo(b));
    return s;
  }

  List<ExtensionOffice> officesForState(String state) {
    return _offices.where((o) => o.state == state).toList();
  }

  List<ExtensionCompany> get filteredCompanies {
    if (_searchQuery.isEmpty) return _companies;
    final q = _searchQuery.toLowerCase();
    return _companies.where((c) =>
        c.companyName.toLowerCase().contains(q) ||
        c.products.contains(_searchQuery) ||
        c.location.contains(_searchQuery)).toList();
  }

  Future<void> loadData() async {
    _isLoading = true;
    notifyListeners();

    try {
      final db = DatabaseService();
      final oRows = await db.query('extension_offices', orderBy: 'state ASC');
      final cRows =
          await db.query('extension_companies', orderBy: 'company_name ASC');
      if (oRows.isEmpty && cRows.isEmpty && !_isSeeded) {
        await _seedData();
        _isSeeded = true;
      }
      final o2 = await db.query('extension_offices', orderBy: 'state ASC');
      final c2 =
          await db.query('extension_companies', orderBy: 'company_name ASC');
      _offices = o2.map((r) => ExtensionOffice.fromMap(r)).toList();
      _companies = c2.map((r) => ExtensionCompany.fromMap(r)).toList();
    } catch (e) {
      debugPrint('ExtensionProvider: فشل تحميل البيانات - $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  void search(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  Future<void> _seedData() {
    return _seedFuture ??= _doSeed();
  }

  void resetSeedState() {
    _seedFuture = null;
    _isSeeded = false;
  }

  Future<void> _doSeed() async {
    final db = DatabaseService();
    for (final o in _officeSeedData) {
      await db.insert('extension_offices', o);
    }
    for (final c in _companySeedData) {
      await db.insert('extension_companies', c);
    }
  }

  static const List<Map<String, dynamic>> _officeSeedData = [
    {
      'state': 'الخرطوم',
      'address': 'الإدارة العامة لوقاية النباتات، شارع النيل، الخرطوم',
      'phone': '0183745678',
      'engineer_name': 'م. عبد الرحمن خليل',
      'working_hours': 'الأحد - الخميس 8ص - 3م',
    },
    {
      'state': 'الجزيرة',
      'address': 'مديرية الزراعة ولاية الجزيرة، ود مدني، شارع المك نمر',
      'phone': '0511832233',
      'engineer_name': 'م. الصادق محمد أحمد',
      'working_hours': 'الأحد - الخميس 8ص - 3م',
    },
    {
      'state': 'نهر النيل',
      'address': 'مديرية الزراعة ولاية نهر النيل، الدامر',
      'phone': '0211823322',
      'engineer_name': 'م. حاتم علي بشير',
      'working_hours': 'الأحد - الخميس 8ص - 3م',
    },
    {
      'state': 'البحر الأحمر',
      'address': 'مديرية الزراعة ولاية البحر الأحمر، بورتسودان',
      'phone': '0311824455',
      'engineer_name': 'م. أمل حسن عثمان',
      'working_hours': 'الأحد - الخميس 8ص - 3م',
    },
    {
      'state': 'القضارف',
      'address': 'مديرية الزراعة ولاية القضارف، القضارف، حي الستين',
      'phone': '0441823355',
      'engineer_name': 'م. عثمان بابكر',
      'working_hours': 'الأحد - الخميس 8ص - 3م',
    },
    {
      'state': 'كسلا',
      'address': 'مديرية الزراعة ولاية كسلا، كسلا، شارع الجمهورية',
      'phone': '0441824466',
      'engineer_name': 'م. يوسف إدريس',
      'working_hours': 'الأحد - الخميس 8ص - 3م',
    },
    {
      'state': 'سنار',
      'address': 'مديرية الزراعة ولاية سنار، سنار',
      'phone': '0541825577',
      'engineer_name': 'م. فيصل محجوب',
      'working_hours': 'الأحد - الخميس 8ص - 3م',
    },
    {
      'state': 'النيل الأبيض',
      'address': 'مديرية الزراعة ولاية النيل الأبيض، ربك',
      'phone': '0571824467',
      'engineer_name': 'م. هدى محمد علي',
      'working_hours': 'الأحد - الخميس 8ص - 3م',
    },
    {
      'state': 'شمال كردفان',
      'address': 'مديرية الزراعة شمال كردفان، الأبيض',
      'phone': '0611825577',
      'engineer_name': 'م. إبراهيم عبد الله',
      'working_hours': 'الأحد - الخميس 8ص - 3م',
    },
    {
      'state': 'جنوب كردفان',
      'address': 'مديرية الزراعة جنوب كردفان، كادوقلي',
      'phone': '0611826688',
      'engineer_name': 'م. آدم كوكو',
      'working_hours': 'الأحد - الخميس 8ص - 3م',
    },
    {
      'state': 'شمال دارفور',
      'address': 'مديرية الزراعة شمال دارفور، الفاشر',
      'phone': '0711826688',
      'engineer_name': 'م. محمد نور الدين',
      'working_hours': 'الأحد - الخميس 8ص - 3م',
    },
    {
      'state': 'جنوب دارفور',
      'address': 'مديرية الزراعة جنوب دارفور، نيالا',
      'phone': '0711827799',
      'engineer_name': 'م. آمنة يوسف',
      'working_hours': 'الأحد - الخميس 8ص - 3م',
    },
    {
      'state': 'غرب دارفور',
      'address': 'مديرية الزراعة غرب دارفور، الجنينه',
      'phone': '0711828800',
      'engineer_name': 'م. عبد القادر سليمان',
      'working_hours': 'الأحد - الخميس 8ص - 3م',
    },
    {
      'state': 'شرق دارفور',
      'address': 'مديرية الزراعة شرق دارفور، الضعين',
      'phone': '0711829911',
      'engineer_name': 'م. خديجة أحمد',
      'working_hours': 'الأحد - الخميس 8ص - 3م',
    },
    {
      'state': 'وسط دارفور',
      'address': 'مديرية الزراعة وسط دارفور، زالنجي',
      'phone': '0711820022',
      'engineer_name': 'م. سعيد هارون',
      'working_hours': 'الأحد - الخميس 8ص - 3م',
    },
    {
      'state': 'الشمالية',
      'address': 'مديرية الزراعة الولاية الشمالية، دنقلا',
      'phone': '0241823355',
      'engineer_name': 'م. الطاهر وداعة الله',
      'working_hours': 'الأحد - الخميس 8ص - 3م',
    },
    {
      'state': 'النيل الأزرق',
      'address': 'مديرية الزراعة ولاية النيل الأزرق، الدمازين',
      'phone': '0541826688',
      'engineer_name': 'م. بكري الحاج',
      'working_hours': 'الأحد - الخميس 8ص - 3م',
    },
    {
      'state': 'غرب كردفان',
      'address': 'مديرية الزراعة غرب كردفان، الفولة',
      'phone': '0611820033',
      'engineer_name': 'م. نصر الدين محمد',
      'working_hours': 'الأحد - الخميس 8ص - 3م',
    },
  ];

  static const List<Map<String, dynamic>> _companySeedData = [
    {
      'company_name': 'شركة الجودة للكيماويات والمبيدات',
      'products': 'مبيدات حشرية وفطرية، منظمات نمو',
      'phone': '0912345670',
      'location': 'الخرطوم - سوق السجانة',
      'description': 'مورد رئيسي للمبيدات الزراعية المسجلة في السودان.',
    },
    {
      'company_name': 'الشركة السودانية للمبيدات والأسمدة',
      'products': 'مبيدات، أسمدة كيماوية وعضوية',
      'phone': '0912345671',
      'location': 'الخرطوم - الخرطوم 2',
      'description': 'شركة وطنية تعمل في استيراد وتوزيع مستلزمات الإنتاج الزراعي.',
    },
    {
      'company_name': 'شركة النيل الأزرق الزراعية',
      'products': 'أسمدة NPK، يوريا، مبيدات الحشائش',
      'phone': '0912345672',
      'location': 'ود مدني - مشروع الجزيرة',
      'description': 'تقدم مستلزمات زراعية لمزارعي مشروع الجزيرة.',
    },
    {
      'company_name': 'شركة أجريكو سودان',
      'products': 'مبيدات حشرية، سوبر فوسفات، بذور محسنة',
      'phone': '0912345673',
      'location': 'الخرطوم - أفريقيا',
      'description': 'شركة متخصصة في الإرشاد الزراعي ومستلزمات الإنتاج.',
    },
    {
      'company_name': 'شركة سودان كيم للمبيدات',
      'products': 'مبيدات الجراد والآفات الجائحة',
      'phone': '0912345674',
      'location': 'بورتسودان - المنطقة الصناعية',
      'description': 'مورد مبيدات الجراد الصحراوي والطوارئ الزراعية.',
    },
    {
      'company_name': 'شركة الساحل للمبيدات والأسمدة',
      'products': 'مبيدات فطرية، أسمدة حيوية',
      'phone': '0912345675',
      'location': 'القضارف - السوق الكبير',
      'description': 'تخدم مزارعي الحبوب الزيتية والحبوب الغذائية في الشرق.',
    },
    {
      'company_name': 'شركة النيل للتنمية الزراعية',
      'products': 'أنظمة ري، أسمدة، معدات زراعية',
      'phone': '0912345676',
      'location': 'الخرطوم - شارع الجامعة',
      'description': 'توفر أنظمة الري الحديثة ومستلزمات التحديث الزراعي.',
    },
  ];
}
