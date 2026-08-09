import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../services/news_service.dart';

class NewsProvider extends ChangeNotifier {
  List<NewsArticle> _articles = [];
  bool _isLoading = false;
  bool _isOffline = false;
  StreamSubscription<List<ConnectivityResult>>? _sub;

  List<NewsArticle> get articles => _articles;
  bool get isLoading => _isLoading;
  bool get isOffline => _isOffline;

  NewsProvider() {
    _sub = Connectivity().onConnectivityChanged.listen((results) async {
      final hasInternet = results.any((r) =>
          r == ConnectivityResult.wifi ||
          r == ConnectivityResult.mobile ||
          r == ConnectivityResult.ethernet);
      if (hasInternet && _isOffline) {
        await loadNews();
      }
    });
  }

  Future<void> loadNews() async {
    _isLoading = true;
    notifyListeners();

    _articles = await NewsService.getCachedNews();

    final connectivity = await Connectivity().checkConnectivity();
    final hasInternet = connectivity.any((r) =>
        r == ConnectivityResult.wifi ||
        r == ConnectivityResult.mobile ||
        r == ConnectivityResult.ethernet);

    if (!hasInternet) {
      _isOffline = true;
      _isLoading = false;
      notifyListeners();
      return;
    }

    try {
      final fetched =
          await NewsService.fetchNews().timeout(const Duration(seconds: 20));
      if (fetched.isNotEmpty) {
        _articles = fetched;
        _isOffline = false;
      }
    } catch (e) {
      _isOffline = true;
      debugPrint('NewsProvider: فشل جلب الأخبار - $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
