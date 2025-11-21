import 'package:flutter/services.dart';
import 'package:recipe_book/database/database_helper.dart';
import 'package:recipe_book/models/recipe_models.dart';

// Example usage of the database
class RecipeService {
  final dbHelper = DatabaseHelper.instance;

  // Add a new recipe with ingredients
  Future<int> addRecipe(Recipe recipe, List<Ingredient> ingredients) async {
    // Insert recipe and get its ID
    final recipeId = await dbHelper.insertRecipe(recipe.toMap());

    // Insert all ingredients
    for (var ingredient in ingredients) {
      final ingredientWithRecipeId = ingredient.copyWith(recipeId: recipeId);
      await dbHelper.insertIngredient(ingredientWithRecipeId.toMap());
    }

    return recipeId;
  }

  // Get a complete recipe with ingredients
  Future<RecipeWithIngredients?> getRecipeWithIngredients(int id) async {
    final recipeMap = await dbHelper.getRecipe(id);
    if (recipeMap == null) return null;

    final recipe = Recipe.fromMap(recipeMap);
    final ingredientMaps = await dbHelper.getIngredients(id);
    final ingredients = ingredientMaps.map((map) => Ingredient.fromMap(map)).toList();

    return RecipeWithIngredients(recipe: recipe, ingredients: ingredients);
  }

  // Get all recipes
  Future<List<Recipe>> getAllRecipes() async {
    final recipeMaps = await dbHelper.getAllRecipes();
    return recipeMaps.map((map) => Recipe.fromMap(map)).toList();
  }

  // Search recipes
  Future<List<Recipe>> searchRecipes(String query) async {
    final recipeMaps = await dbHelper.searchRecipes(query);
    return recipeMaps.map((map) => Recipe.fromMap(map)).toList();
  }

  // Get favorite recipes - NOW WITH USER ID PARAMETER
  Future<List<Recipe>> getFavoriteRecipes(int userId) async {
    final recipeMaps = await dbHelper.getFavoriteRecipeIds(userId);
    return recipeMaps.map((map) => Recipe.fromMap(map as Map<String, dynamic>)).toList();
  }

  // Get recipes by category
  Future<List<Recipe>> getRecipesByCategory(String category) async {
    final recipeMaps = await dbHelper.getRecipesByCategory(category);
    return recipeMaps.map((map) => Recipe.fromMap(map)).toList();
  }

  // Update recipe
  Future<void> updateRecipe(Recipe recipe, List<Ingredient> ingredients) async {
    // Update recipe
    await dbHelper.updateRecipe(recipe.toMap());

    // Delete old ingredients and insert new ones
    await dbHelper.deleteIngredientsForRecipe(recipe.id!);
    for (var ingredient in ingredients) {
      final ingredientWithRecipeId = ingredient.copyWith(recipeId: recipe.id!);
      await dbHelper.insertIngredient(ingredientWithRecipeId.toMap());
    }
  }

  // Toggle favorite - NOW WITH USER ID PARAMETER
  Future<void> toggleFavorite(int userId, int id, bool isFavorite) async {
    await dbHelper.toggleFavorite(userId, id, isFavorite ? 1 : 0);
  }

  // Delete recipe
  Future<void> deleteRecipe(int id) async {
    await dbHelper.deleteRecipe(id);
  }
}

// Example: How to use in your Flutter app
void exampleUsage() async {
  final recipeService = RecipeService();

  // Create a new recipe
  final newRecipe = Recipe(
    name: 'Spaghetti Carbonara',
    description: 'Classic Italian pasta dish',
    category: 'Dinner',
    cuisine: 'Italian',
    difficulty: 'Medium',
    prepTime: 10,
    cookTime: 20,
    servings: 4,
    instructions: '''
1. Cook spaghetti according to package instructions
2. Fry pancetta until crispy
3. Mix eggs with parmesan cheese
4. Combine hot pasta with pancetta
5. Add egg mixture and stir quickly
6. Serve immediately with black pepper
    ''',
  );

  final ingredients = [
    Ingredient(recipeId: 0, name: 'Spaghetti', quantity: '400', unit: 'g'),
    Ingredient(recipeId: 0, name: 'Pancetta', quantity: '200', unit: 'g'),
    Ingredient(recipeId: 0, name: 'Eggs', quantity: '4', unit: 'pcs'),
    Ingredient(recipeId: 0, name: 'Parmesan', quantity: '100', unit: 'g'),
    Ingredient(recipeId: 0, name: 'Black pepper', quantity: 'to taste'),
  ];

  // Add recipe to database
  final recipeId = await recipeService.addRecipe(newRecipe, ingredients);
  print('Recipe added with ID: $recipeId');

  // Get the recipe back
  final retrievedRecipe = await recipeService.getRecipeWithIngredients(recipeId);
  if (retrievedRecipe != null) {
    print('Recipe: ${retrievedRecipe.recipe.name}');
    print('Ingredients:');
    for (var ingredient in retrievedRecipe.ingredients) {
      print('- ${ingredient.displayText}');
    }
  }

  // Get all recipes
  final allRecipes = await recipeService.getAllRecipes();
  print('Total recipes: ${allRecipes.length}');

  // Search recipes
  final searchResults = await recipeService.searchRecipes('pasta');
  print('Found ${searchResults.length} pasta recipes');

  // Toggle favorite - NOW WITH USER ID
  await recipeService.toggleFavorite(1, recipeId, true); // Assuming user ID is 1
  print('Recipe marked as favorite');

  // Get favorites - NOW WITH USER ID
  final favorites = await recipeService.getFavoriteRecipes(1); // Assuming user ID is 1
  print('Favorite recipes: ${favorites.length}');
}