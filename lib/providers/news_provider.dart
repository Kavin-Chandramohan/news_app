import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/news_article.dart';
import '../services/database_service.dart';

// represent the sorting options for articles
enum SortOption {
  newest,
  oldest,
  alphabetical,
}

// Provider class to manage news articles, bookmarks, and app settings
class NewsProvider with ChangeNotifier {
  List<NewsArticle> _articles = [];
  List<NewsArticle> _techCrunchArticles = [];
  List<NewsArticle> _bookmarkedArticles = [];
  List<NewsArticle> _filteredArticles = [];
  bool _isLoading = false;
  bool _isTechCrunchLoading = false;
  String _currentCategory = 'general';
  bool _isDarkMode = false;
  SortOption _currentSortOption = SortOption.newest;

  // API key and preference keys
  static const String _apiKey = '83ef0f6ac7354c7983b4b39b129eb08e';
  static const String _darkModeKey = 'dark_mode_preference';
  static const String _sortOptionKey = 'sort_option_preference';

  // Constructor to initialize preferences and fetch initial data
  NewsProvider() {
    _loadDarkModePref();
    _loadSortOptionPref();
    loadBookmarks();
    fetchTechCrunchNews();
  }

  // Method to clear filtered articles
  void clearFilteredArticles() {
    _filteredArticles.clear();
    notifyListeners();
  }

  // Reset to the default category (general) and fetch news
  void resetToDefaultNews() {
    _filteredArticles.clear();
    _currentCategory = 'general';
    fetchNews();
  }

  // Reset filtered articles and fetch news for the current category
  void resetAfterSearch() {
    _filteredArticles.clear();
    fetchNews(category: _currentCategory);
    notifyListeners();
  }

  // Dark Mode Preference Methods
  Future<void> _loadDarkModePref() async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool(_darkModeKey) ?? false;
    notifyListeners();
  }

  // Save dark mode preference to SharedPreferences
  Future<void> _saveDarkModePref(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_darkModeKey, value);
  }

  // Load sort option preference from SharedPreferences
  Future<void> _loadSortOptionPref() async {
    final prefs = await SharedPreferences.getInstance();
    final savedSortIndex = prefs.getInt(_sortOptionKey) ?? 0;
    _currentSortOption = SortOption.values[savedSortIndex];
    notifyListeners();
  }

  // Save sort option preference to SharedPreferences
  Future<void> _saveSortOptionPref(SortOption value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_sortOptionKey, value.index);
  }

  // Getter methods
  List<NewsArticle> get articles {
    List<NewsArticle> articlesToSort =
        _filteredArticles.isNotEmpty ? _filteredArticles : _articles;

    switch (_currentSortOption) {
      case SortOption.newest:
        articlesToSort.sort((a, b) => DateTime.parse(b.publishedAt)
            .compareTo(DateTime.parse(a.publishedAt)));
        break;
      case SortOption.oldest:
        articlesToSort.sort((a, b) => DateTime.parse(a.publishedAt)
            .compareTo(DateTime.parse(b.publishedAt)));
        break;
      case SortOption.alphabetical:
        articlesToSort.sort((a, b) => a.title.compareTo(b.title));
        break;
    }
    return articlesToSort;
  }

  List<NewsArticle> get techCrunchArticles => _techCrunchArticles;
  List<NewsArticle> get bookmarkedArticles => _bookmarkedArticles;
  bool get isLoading => _isLoading;
  bool get isTechCrunchLoading => _isTechCrunchLoading;
  bool get isDarkMode => _isDarkMode;
  String get currentCategory => _currentCategory;
  SortOption get currentSortOption => _currentSortOption;

  // Fetch TechCrunch news articles
  Future<void> fetchTechCrunchNews() async {
    _isTechCrunchLoading = true;
    notifyListeners();

    try {
      final response = await http.get(Uri.parse(
          'https://newsapi.org/v2/top-headlines?sources=techcrunch&apiKey=$_apiKey'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _techCrunchArticles = (data['articles'] as List)
            .map((article) => NewsArticle.fromJson(article))
            .toList();

        _isTechCrunchLoading = false;
        notifyListeners();
      }
    } catch (e) {
      _isTechCrunchLoading = false;
      notifyListeners();
      throw Exception('Error fetching TechCrunch news: $e');
    }
  }

  // Fetch news articles for a specific category
  Future<void> fetchNews({String category = 'general'}) async {
    _isLoading = true;
    _currentCategory = category;
    _filteredArticles.clear();
    notifyListeners();

    try {
      final response = await http.get(Uri.parse(
          'https://newsapi.org/v2/top-headlines?country=us&category=$category&apiKey=$_apiKey'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _articles = (data['articles'] as List)
            .map((article) => NewsArticle.fromJson(article))
            .toList();

        await _syncBookmarks();

        _isLoading = false;
        notifyListeners();
      }
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      throw Exception('Error fetching news: $e');
    }
  }

  // Search for articles by query
  Future<List<NewsArticle>> searchArticles(String query) async {
    _isLoading = true;
    _filteredArticles.clear();
    notifyListeners();

    try {
      final response = await http.get(Uri.parse(
          'https://newsapi.org/v2/everything?q=$query&sortBy=publishedAt&apiKey=$_apiKey'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _filteredArticles = (data['articles'] as List)
            .map((article) => NewsArticle.fromJson(article))
            .toList();

        _isLoading = false;
        notifyListeners();
        return _filteredArticles;
      }
    } catch (e) {
      _isLoading = false;
      _filteredArticles.clear();
      notifyListeners();
      throw Exception('Error searching articles: $e');
    }

    return [];
  }

  // Change the sort option and save it to preferences
  Future<void> changeSortOption(SortOption newSortOption) async {
    _currentSortOption = newSortOption;
    await _saveSortOptionPref(newSortOption);
    notifyListeners();
  }

  // Synchronize bookmarks with articles
  Future<void> _syncBookmarks() async {
    for (var article in _articles) {
      article.isBookmarked = _bookmarkedArticles
          .any((bookmarked) => bookmarked.url == article.url);
    }
  }

  // Toggle bookmark for an article
  Future<void> toggleBookmark(NewsArticle article) async {
    article.isBookmarked = !article.isBookmarked;

    if (article.isBookmarked) {
      await DatabaseService.instance.insertBookmark(article);
      _bookmarkedArticles.add(article);
    } else {
      await DatabaseService.instance.deleteBookmark(article.url);
      _bookmarkedArticles.removeWhere((a) => a.url == article.url);
    }

    notifyListeners();
  }

  // Load bookmarked articles from the database
  Future<void> loadBookmarks() async {
    _bookmarkedArticles = await DatabaseService.instance.getBookmarks();
    await _syncBookmarks();
    notifyListeners();
  }

  // Toggle dark mode preference
  Future<void> toggleDarkMode() async {
    _isDarkMode = !_isDarkMode;
    await _saveDarkModePref(_isDarkMode);
    notifyListeners();
  }
}
