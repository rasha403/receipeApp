import 'package:sqflite/sqflite.dart';

class IngredientDao {
  final Database db;

  IngredientDao(this.db);

  Future<int> insertIngredient(Map<String, dynamic> ingredient) async {
    return await db.insert('ingredients', ingredient);
  }

  Future<List<Map<String, dynamic>>> getIngredientsForRecipe(int recipeId) async {
    return await db.query(
      'ingredients',
      where: 'recipeId = ?',
      whereArgs: [recipeId],
      orderBy: 'name ASC',
    );
  }

  // You can keep the _add...Ingredients methods here if they only insert,
  // or move them to RecipeDao if they are tightly coupled to recipe insertion logic.
  // Example:
  Future<void> addBreakfastIngredients(int recipeId, String recipeName) async {
    // Implementation similar to _addBreakfastIngredients in the original file
    // Use this.db.insert('ingredients', ...)
  }

  Future<void> deleteIngredientsForRecipe(int recipeId) async {}
  // ... addLaunchIngredients, addSnackIngredients, etc. ...
}