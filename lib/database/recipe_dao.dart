// import 'package:sqflite/sqflite.dart';
// import 'recipe_data.dart'; // Import the file containing recipe data

// class RecipeDao {
//   final Database db;

//   RecipeDao(this.db);

//   Future<int> insertRecipe(Map<String, dynamic> recipe) async {
//     recipe['cuisine'] = 'Lebanese';
//     recipe['createdAt'] = DateTime.now().toIso8601String();
//     recipe['updatedAt'] = DateTime.now().toIso8601String();
//     return await db.insert('recipes', recipe);
//   }

//   Future<List<Map<String, dynamic>>> getAllRecipes() async {
//     return await db.query('recipes', orderBy: 'createdAt DESC');
//   }

//   Future<List<Map<String, dynamic>>> getRecipesByCategory(String category) async {
//     return await db.query(
//       'recipes',
//       where: 'category = ?',
//       whereArgs: [category],
//       orderBy: 'name ASC',
//     );
//   }

//   Future<List<Map<String, dynamic>>> getRecipesByCuisineType(String cuisineType) async {
//     return await db.query(
//       'recipes',
//       where: 'cuisineType = ?',
//       whereArgs: [cuisineType],
//       orderBy: 'name ASC',
//     );
//   }

//   // --- Methods for inserting default recipes ---
//   Future<void> insertLebaneseRecipes(Database db) async {
//     // [Implement _insertLebaneseRecipes logic here]
//     // Use db.insert('recipes', ...) and call ingredientDao.insertIngredientsForRecipe(...)
//   }

//   Future<void> insertBreakfastRecipes(Database db) async {
//     print('🍳 Starting to insert breakfast recipes...');
//     final existingBreakfastRecipes = await db.query(
//       'recipes',
//       where: 'cuisineType = ?',
//       whereArgs: ['Breakfast'],
//     );
//     if (existingBreakfastRecipes.isNotEmpty) {
//       print('✅ Breakfast recipes already exist (${existingBreakfastRecipes.length} recipes)');
//       return;
//     }

//     for (var recipeData in breakfastRecipes) { // Assume breakfastRecipes is defined in recipe_data.dart
//       recipeData['cuisine'] = 'Lebanese';
//       recipeData['createdAt'] = DateTime.now().toIso8601String();
//       recipeData['updatedAt'] = DateTime.now().toIso8601String();
//       final recipeId = await db.insert('recipes', recipeData);
//       // Call ingredient DAO to add ingredients for this recipe
//       // IngredientDao ingredientDao = IngredientDao(db); // Or get it from a shared instance
//       // await ingredientDao.addBreakfastIngredients(recipeId, recipeData['name']);
//       // Or pass the IngredientDao instance if available
//       await _addBreakfastIngredients(recipeId, recipeData['name']);
//     }
//     print('✅ Successfully inserted 5 breakfast recipes!');
//   }

//   Future<void> _addBreakfastIngredients(int recipeId, String recipeName) async {
//     // Move the logic from the original _addBreakfastIngredients function here
//     // Use db.insert('ingredients', ...) for each ingredient
//     // This function might need access to the IngredientDao to perform the insertions
//     // Or just use the db instance directly here.
//     List<Map<String, dynamic>> ingredients = [];
//     switch (recipeName) {
//       // ... populate ingredients list based on recipeName ...
//       case 'Chia Seed Pudding':
//         ingredients = [
//           {'recipeId': recipeId, 'name': 'Chia seeds', 'quantity': '3', 'unit': 'tbsp'},
//           {'recipeId': recipeId, 'name': 'Milk or almond milk', 'quantity': '1', 'unit': 'cup'},
//           {'recipeId': recipeId, 'name': 'Fresh berries', 'quantity': '1/4', 'unit': 'cup'},
//           {'recipeId': recipeId, 'name': 'Honey or maple syrup', 'quantity': '1', 'unit': 'tsp', 'optional': 1},
//         ];
//         break;
//       // ... other cases ...
//     }
//     for (var ingredient in ingredients) {
//       await db.insert('ingredients', ingredient);
//     }
//   }

//   // ... Implement insertLaunchRecipes, insertSnackRecipes, insertJuiceRecipes similarly ...
//   Future<void> insertLaunchRecipes(Database db) async { /* ... */ }
//   Future<void> insertSnackRecipes(Database db) async { /* ... */ }
//   Future<void> insertJuiceRecipes(Database db) async { /* ... */ }

//   Future<Map<String, dynamic>?> getRecipe(int id) async {}

//   Future<void> updateRecipe(Map<String, dynamic> recipe) async {}

//   Future<void> deleteRecipe(int id) async {}

//   Future<List<Map<String, dynamic>>> searchRecipes(String query) async {}
//   // ... Implement other recipe-specific methods ...
// }