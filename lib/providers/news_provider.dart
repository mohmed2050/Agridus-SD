import 'package:flutter/foundation.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../services/news_service.dart';

class NewsProvider extends ChangeNotifier {
  List<NewsArticle> _articles = [];
  bool _isLoading = false;
  bool _isOffline = false;

  List<NewsArticle> get articles => _articles;
  bool get isLoading => _isLoading;
  bool get isOffline => _isOffline;

  Future<void> loadNews() async {
    _isLoading = true;
    notifyListeners();

    final connectivity = await Connectivity().checkConnectivity();
    final hasInternet = connectivity.any((r) =>
        r == ConnectivityResult.wifi ||
        r == ConnectivityResult.mobile ||
        r == ConnectivityResult.ethernet);

    if (hasInternet) {
      final fetched = await NewsService.fetchNews();
      if (fetched.isNotEmpty) {
        _articles = fetched;
        _isOffline = false;
      } else {
        _articles = await NewsService.getCachedNews();
        _isOffline = _articles.isEmpty ? false : true;
      }
    } else {
      _articles = await NewsService.getCachedNews();
      _isOffline = true;
    }

    _isLoading = false;
    notifyListeners();
  }
}
