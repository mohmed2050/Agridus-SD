import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:xml/xml.dart';
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
    'حاصيل',
  ];

  static const List<String> _rssFeeds = [
    'https://www.suna-sd.net/rss',
    'https://www.alrakoba.net/feed',
    'https://www.sudaress.com/sdn/feed',
  ];

  static List<NewsArticle> _cached = [];

  static bool _matchesKeywords(String text) {
    final lower = text.toLowerCase();
    return _keywords.any((kw) => lower.contains(kw.toLowerCase()));
  }

  static Future<List<NewsArticle>> fetchNews() async {
    final articles = <NewsArticle>[];

    for (final feedUrl in _rssFeeds) {
      try {
        final response = await http
            .get(Uri.parse(feedUrl))
            .timeout(const Duration(seconds: 10));
        if (response.statusCode == 200) {
          final doc = XmlDocument.parse(response.body);
          final items = doc.findAllElements('item');
          for (final item in items) {
            final title =
                item.findElements('title').firstOrNull?.innerText ?? '';
            final description =
                item.findElements('description').firstOrNull?.innerText ?? '';
            final link =
                item.findElements('link').firstOrNull?.innerText ?? '';
            final pubDate =
                item.findElements('pubDate').firstOrNull?.innerText;

            final combined = '$title $description';
            if (_matchesKeywords(combined)) {
              final sourceName = switch (feedUrl) {
                'https://www.suna-sd.net/rss' => 'SUNA',
                'https://www.alrakoba.net/feed' => 'الراكوبة',
                'https://www.sudaress.com/sdn/feed' => 'سوداريس',
                _ => 'مصدر إخباري',
              };

              articles.add(NewsArticle(
                title: _cleanHtml(title),
                source: sourceName,
                date: pubDate,
                summary: _cleanHtml(
                    description.replaceAll(RegExp(r'<[^>]*>'), '')),
                url: link,
              ));
            }
          }
        }
      } catch (_) {}
    }

    if (articles.isNotEmpty) {
      _cached = articles.take(20).toList();
      await _cacheLocally(_cached);
    }

    return articles.isNotEmpty ? articles : _cached;
  }

  static Future<List<NewsArticle>> getCachedNews() async {
    if (_cached.isNotEmpty) return _cached;
    try {
      final db = DatabaseService();
      final rows = await db.query('news', orderBy: 'cached_at DESC');
      _cached = rows.map((r) => NewsArticle.fromMap(r)).toList();
    } catch (_) {}
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
        .trim();
  }
}
