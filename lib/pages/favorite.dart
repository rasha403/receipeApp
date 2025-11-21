// lib/pages/favorite_list_page.dart
import 'package:flutter/material.dart';
import 'package:recipe_book/database/database_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FavoriteListPage extends StatefulWidget {
  const FavoriteListPage({super.key});

  @override
  State<FavoriteListPage> createState() => _FavoriteListPageState();
}

class _FavoriteListPageState extends State<FavoriteListPage> {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  int? _currentUserId;
  List<Map<String, dynamic>> _favorites = [];

  @override
  void initState() {
    super.initState();
    _getCurrentUserId();
    _loadFavorites();
  }

  Future<void> _getCurrentUserId() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('userId');
    setState(() {
      _currentUserId = userId;
    });
  }

  Future<void> _loadFavorites() async {
    if (_currentUserId != null) {
      final favorites = await _dbHelper.getFavoriteRecipeIds(_currentUserId!);
      setState(() {
        _favorites = favorites.cast<Map<String, dynamic>>();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorite Recipes'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: _favorites.isEmpty
          ? const Center(
              child: Text(
                'No favorite recipes yet!',
                style: TextStyle(fontSize: 18),
              ),
            )
          : ListView.builder(
              itemCount: _favorites.length,
              itemBuilder: (context, index) {
                final favorite = _favorites[index];
                return Card(
                  margin: const EdgeInsets.all(8.0),
                  child: ListTile(
                    title: Text(favorite['title'] ?? 'Unknown Recipe'),
                    subtitle: Text(favorite['category'] ?? 'Uncategorized'),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () async {
                        await _dbHelper.removeFavorite(
                          _currentUserId!,
                          favorite['recipe_id'],
                        );
                        _loadFavorites(); // Refresh the list
                      },
                    ),
                  ),
                );
              },
            ),
    );
  }
}