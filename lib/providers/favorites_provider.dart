import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FavoritesProvider extends ChangeNotifier {
  static const String _key = 'favorite_stories';
  Set<String> _favorites = {};
  bool _loaded = false;

  Set<String> get favorites => _favorites;
  bool get loaded => _loaded;

  FavoritesProvider() {
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_key) ?? [];
    _favorites = list.toSet();
    _loaded = true;
    notifyListeners();
  }

  bool isFavorite(String storyId) => _favorites.contains(storyId);

  Future<void> toggleFavorite(String storyId) async {
    if (_favorites.contains(storyId)) {
      _favorites.remove(storyId);
    } else {
      _favorites.add(storyId);
    }
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_key, _favorites.toList());
  }
}
