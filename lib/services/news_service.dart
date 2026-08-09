import 'package:http/http.dart' as http;
import 'package:xml/xml.dart';
import 'package:flutter/foundation.dart';
import '../services/database_service.dart';

class NewsArticle {
  final String title;
  final String source;
  final String? date;
  final String summary;
  final String url;

  NewsArticle({
    required this.title,
    required this.source,
    this.date,
    required this.summary,
    required this.url,
  });

  Map<String, dynamic> toMap() => {
        'title': title,
        'source': source,
        'date': date,
        'summary': summary,
        'url': url,
        'cached_at': DateTime.now().toIso8601String(),
      };

  factory NewsArticle.fromMap(Map<String, dynamic> map) => NewsArticle(
        title: map['title'] ?? '',
        source: map['source'] ?? '',
        date: map['date'],
        summary: map['summary'] ?? '',
        url: map['url'] ?? '',
      );
}

class NewsService {
  static const List<String> _keywords = [
    'زراعة',
    'محاصيل',
    'فلاحين',
    'مزارعين',
    'تمويل زراعي',
    'أسعار المحاصيل',
    'موسم زراعي',
    'هلال',
    'زراعي',
    'محصول',
    'أسمدة',
    'ري',
    'غذاء',
    'أمن غذائي',
    'صادرات',
    'حيوان',
    'مواشي',
    'ثروة حيوانية',
    'غابات',
    'بيئة',
    'مياه',
    'سقي',
    'حصاد',
    'بذور',
    'تقاوي',
    'أرض',
    'فدان',
    'مشروع',
    'الجزيرة',
    'السودان',
    'وزارة',
    'إنتاج',
    'تمويل',
    'بنك',
    'قرض',
  ];

  static const List<String> _rssFeeds = [
    'https://www.sudanakhbar.com/rss',
    'https://suna-sd.net/rss',
    'https://www.alrakoba.net/feed',
  ];

  static List<NewsArticle> _cached = [];
  static bool _hasAttemptedFetch = false;

  static bool _matchesKeywords(String text) {
    final lower = text.toLowerCase();
    return _keywords.any((kw) => lower.contains(kw.toLowerCase()));
  }

  static List<NewsArticle> _getFallbackNews() {
    return [
      NewsArticle(
        title: 'وزارة الزراعة تؤكد جاهزية الموسم الزراعي الصيفي 2026-2027',
        source: 'سونا',
        date: 'يونيو 2026',
        summary: 'أكدت وزارة الزراعة والري جاهزيتها للموسم الزراعي الصيفي، ووضع الترتيبات اللازمة لضمان نجاح الموسم وتوفير التقاوى المحسنة للمزارعين.',
        url: 'https://www.sudanakhbar.com/1805360',
      ),
      NewsArticle(
        title: 'البنك الزراعي السوداني يمول 100 ألف فدان في الجزيرة',
        source: 'سونا',
        date: 'يوليو 2026',
        summary: 'أعلن البنك الزراعي السوداني عن خطة لتمويل زراعة 100 ألف فدان في مشروع الجزيرة لدعم الأمن الغذائي.',
        url: 'https://www.sudanakhbar.com/1813284',
      ),
      NewsArticle(
        title: 'اجتماع تنسيقي بين وزارتي الصناعة والزراعة لزيادة الصادرات الزراعية',
        source: 'سونا',
        date: 'أبريل 2026',
        summary: 'عقدت وزارتا الصناعة والتجارة والزراعة والري اجتماعاً بحثت خلاله سبل زيادة الصادرات الزراعية السودانية.',
        url: 'https://www.sudanakhbar.com/1813284',
      ),
      NewsArticle(
        title: 'السودان يخطط لزراعة مليون فدان قمح بالولاية الشمالية',
        source: 'وكالة السودان للأنباء',
        date: 'يوليو 2026',
        summary: 'كشف وزير الزراعة عن خطة لتوسيع زراعة القمح لتصل إلى مليون فدان في الولاية الشمالية لتحقيق الاكتفاء الذاتي.',
        url: 'https://www.sudanakhbar.com/1814921',
      ),
      NewsArticle(
        title: 'وزارة الإنتاج بالنيل الأبيض تعلن ترتيبات تمويل الموسم الصيفي',
        source: 'سونا',
        date: 'يوليو 2026',
        summary: 'أكدت وزارة الإنتاج والموارد الاقتصادية بالنيل الأبيض أن تمويل الموسم الزراعي الصيفي يمضي بصورة جيدة.',
        url: 'https://www.sudanakhbar.com/1813284',
      ),
      NewsArticle(
        title: 'السودان يبحث التعاون الزراعي مع سوريا',
        source: 'سونا',
        date: 'يوليو 2026',
        summary: 'بحث وزير الزراعة السوداني مع نظيره السوري سبل تعزيز التعاون الزراعي وتبادل الخبرات وتوفير تقاوي القمح.',
        url: 'https://www.sudanakhbar.com/1815917',
      ),
      NewsArticle(
        title: 'مجلس الوزراء يؤكد ضرورة نجاح الموسم الزراعي',
        source: 'سونا',
        date: 'يوليو 2026',
        summary: 'شدد مجلس الوزراء على ضرورة توفير كافة المتطلبات لضمان نجاح الموسم الزراعي الصيفي وتذليل العقبات.',
        url: 'https://www.sudanakhbar.com/1805360',
      ),
    ];
  }

  static Future<List<NewsArticle>> fetchNews() async {
    final lists = await Future.wait(
      _rssFeeds.map(_fetchAndParseFeed),
    );

    final articles = <NewsArticle>[];
    final seen = <String>{};
    for (final list in lists) {
      for (final a in list) {
        final key = a.url.isNotEmpty ? a.url : a.title;
        if (seen.add(key)) articles.add(a);
      }
    }

    if (articles.isNotEmpty) {
      _cached = articles.take(20).toList();
      await _cacheLocally(_cached);
    } else if (_cached.isEmpty) {
      _cached = _getFallbackNews();
      await _cacheLocally(_cached);
    }

    _hasAttemptedFetch = true;

    return articles.isNotEmpty ? articles : _cached;
  }

  static Future<List<NewsArticle>> _fetchAndParseFeed(String feedUrl) async {
    try {
      final response = await http
          .get(Uri.parse(feedUrl))
          .timeout(const Duration(seconds: 8));
      if (response.statusCode != 200) return const [];
      final sourceName = switch (feedUrl) {
        'https://www.sudanakhbar.com/rss' => 'اخبار السودان',
        'https://suna-sd.net/rss' => 'سونا',
        'https://www.alrakoba.net/feed' => 'الراكوبة',
        _ => 'مصدر إخباري',
      };
      return await compute(
        _parseFeedXml,
        {'xml': response.body, 'source': sourceName},
      );
    } catch (_) {
      return const [];
    }
  }

  static Future<List<NewsArticle>> getCachedNews() async {
    if (_cached.isNotEmpty) return _cached;
    try {
      final db = DatabaseService();
      final rows = await db.query('news', orderBy: 'cached_at DESC');
      _cached = rows.map((r) => NewsArticle.fromMap(r)).toList();
    } catch (_) {}
    if (_cached.isEmpty && !_hasAttemptedFetch) {
      _cached = _getFallbackNews();
    }
    return _cached;
  }

  static Future<void> _cacheLocally(List<NewsArticle> articles) async {
    try {
      final db = DatabaseService();
      await db.delete('news', where: '1=1');
      for (final article in articles.take(20)) {
        await db.insert('news', article.toMap());
      }
    } catch (_) {}
  }

  static String _cleanHtml(String text) {
    return text
        .replaceAll(RegExp(r'<[^>]*>'), '')
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&quot;', '"')
        .replaceAll('&#039;', "'")
        .replaceAll('&nbsp;', ' ')
        .trim();
  }
}

List<NewsArticle> _parseFeedXml(Map<String, String> input) {
  final doc = XmlDocument.parse(input['xml'] ?? '');
  final source = input['source'] ?? 'مصدر إخباري';
  final out = <NewsArticle>[];
  for (final item in doc.findAllElements('item')) {
    final title = item.findElements('title').firstOrNull?.innerText ?? '';
    final description =
        item.findElements('description').firstOrNull?.innerText ?? '';
    final link = item.findElements('link').firstOrNull?.innerText ?? '';
    final pubDate = item.findElements('pubDate').firstOrNull?.innerText;

    final combined = '$title $description';
    if (NewsService._matchesKeywords(combined)) {
      out.add(NewsArticle(
        title: NewsService._cleanHtml(title),
        source: source,
        date: pubDate,
        summary: NewsService._cleanHtml(
            description.replaceAll(RegExp(r'<[^>]*>'), '').trim()),
        url: link,
      ));
    }
  }
  return out;
}
