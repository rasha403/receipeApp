import 'package:sqflite/sqflite.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FavoriteDao {
  final Database db;

  FavoriteDao(this.db);

  // Helper function to get the set of favorite recipe IDs from SharedPreferences
  Future<Set<int>> _getFavoriteRecipeIds() async {
    final prefs = await SharedPreferences.getInstance();
    // Use getStringList to retrieve the list, casting it to List<String>?
    final List<String>? stringList = prefs.getStringList('favoriteRecipeIds');
    
    // Convert String list back to int list, or return empty set if null
    if (stringList == null) {
      return <int>{};
    }

    // Convert each string to an integer
    Set<int> intSet = {};
    for (String idStr in stringList) {
      int? id = int.tryParse(idStr); // Safely parse string to int
      if (id != null) {
        intSet.add(id);
      }
    }
    return intSet;
  }

  // Device-specific favorite methods
  Future<void> addFavorite(int recipeId) async {
    final prefs = await SharedPreferences.getInstance();
    Set<int> favorites = await _getFavoriteRecipeIds(); // Get current list
    favorites.add(recipeId); // Add new ID

    // Save back to SharedPreferences using setStringList
    // Convert int set to list of strings
    List<String> stringList = favorites.map((id) => id.toString()).toList();
    await prefs.setStringList('favoriteRecipeIds', stringList);
  }

  Future<void> removeFavorite(int recipeId) async {
    final prefs = await SharedPreferences.getInstance();
    Set<int> favorites = await _getFavoriteRecipeIds(); // Get current list
    favorites.remove(recipeId); // Remove ID

    // Save back to SharedPreferences using setStringList
    // Convert int set to list of strings
    List<String> stringList = favorites.map((id) => id.toString()).toList();
    await prefs.setStringList('favoriteRecipeIds', stringList);
  }

  // Function to check if a specific recipe is in the device's favorites list
  Future<bool> isRecipeFavorite(int recipeId) async {
    Set<int> favorites = await _getFavoriteRecipeIds();
    return favorites.contains(recipeId);
  }

  // Updated function to get favorite recipes based on stored IDs on this device
  Future<List<Map<String, dynamic>>> getUserFavorites(int userId) async {
    Set<int> favoriteIds = await _getFavoriteRecipeIds();
    if (favoriteIds.isEmpty) {
      return []; // Return empty list if no favorites
    }

    // Use IN clause to get recipes matching the stored IDs
    String? inClause = '?';
    for (int i = 1; i < favoriteIds.length; i++) {
      
    }
    List<Map<String, dynamic>> result = await db.rawQuery(
      'SELECT * FROM recipes WHERE id IN ($inClause) ORDER BY createdAt DESC',
      favoriteIds.toList(), // Pass the IDs as arguments
    );
    return result;
  }

  Future<void> toggleFavorite(int userId, int recipeId) async {}
}