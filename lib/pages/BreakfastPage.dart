import 'package:flutter/material.dart';
import 'package:recipe_book/AppBar/app_bar.dart';
import 'package:recipe_book/css/app_theme.dart';
import 'package:recipe_book/database/database_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BreakfastCategoryPage extends StatefulWidget {
  final String category;
  final String title;

  const BreakfastCategoryPage({
    Key? key,
    required this.category,
    required this.title,
  }) : super(key: key);

  @override
  State<BreakfastCategoryPage> createState() => _BreakfastCategoryPageState();
}

class _BreakfastCategoryPageState extends State<BreakfastCategoryPage> {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  List<Map<String, dynamic>> _recipes = [];
  List<int> _favoriteRecipeIds = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRecipes();
    _loadFavorites();
  }

  Future<void> _loadRecipes() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      List<Map<String, dynamic>> breakfastRecipes = await _dbHelper.getRecipesByCuisineType('Breakfast');
      setState(() {
        _recipes = breakfastRecipes;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading recipes: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadFavorites() async {
    final dbHelper = DatabaseHelper.instance;
    // Get favorite recipe IDs from device storage
    final favoriteIds = await dbHelper.getUserFavorites(-1); // Pass -1 as dummy userId
    setState(() {
      _favoriteRecipeIds = favoriteIds.map((recipe) => recipe['id'] as int).toList();
    });
  }

  Future<void> _toggleFavorite(int recipeId, Map<String, dynamic> recipe) async {
    bool isFavorite = _favoriteRecipeIds.contains(recipeId);
    
    if (isFavorite) {
      await _dbHelper.removeFavorite(recipeId, recipe);
      setState(() {
        _favoriteRecipeIds.remove(recipeId);
      });
    } else {
      await _dbHelper.addFavorite(recipeId, recipe);
      setState(() {
        _favoriteRecipeIds.add(recipeId);
      });
    }
    
    // Update the custom app bar if needed
    if (mounted) {
      final appBar = context.findAncestorWidgetOfExactType<CustomAppBar>();
      if (appBar != null && appBar.onFavoriteToggle != null) {
        appBar.onFavoriteToggle!(null, recipeId, !isFavorite); // Pass null for userId
      }
    }
  }

  Future<void> _showAddRecipeDialog() async {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController ingredientsController = TextEditingController();
    final TextEditingController chefController = TextEditingController();
    
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Breakfast Recipe'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Recipe Name *',
                  border: OutlineInputBorder(),
                  hintText: 'Enter recipe name',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: ingredientsController,
                decoration: const InputDecoration(
                  labelText: 'Ingredients *',
                  border: OutlineInputBorder(),
                  hintText: 'Enter ingredients (comma separated)',
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: chefController,
                decoration: const InputDecoration(
                  labelText: 'Chef Name (Optional)',
                  border: OutlineInputBorder(),
                  hintText: 'Enter chef name',
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.isNotEmpty && 
                  ingredientsController.text.isNotEmpty) {
                
                // Insert the new recipe
                await _insertNewRecipe(
                  nameController.text,
                  ingredientsController.text,
                  chefController.text,
                );
                
                // Reload recipes and close dialog
                await _loadRecipes();
                await _loadFavorites();
                Navigator.of(context).pop();
              } else {
                // Show error if required fields are empty
                if (nameController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Recipe name is required')),
                  );
                } else if (ingredientsController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Ingredients are required')),
                  );
                }
              }
            },
            child: const Text('Add Recipe'),
          ),
        ],
      ),
    );
  }

  Future<void> _insertNewRecipe(String name, String ingredientsText, String chefName) async {
    try {
      // Prepare recipe data
      Map<String, dynamic> recipeData = {
        'name': name,
        'description': 'Added by user: $chefName'.trim(),
        'category': 'Food',
        'cuisineType': 'Breakfast',
        'difficulty': 'Medium',
        'prepTime': 10, // Default value
        'cookTime': 15, // Default value
        'servings': 1, // Default value
        'instructions': 'No instructions provided. User added recipe.',
        'createdAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
        'cookingMethod': 'User added',
        'dietaryInfo': 'User added recipe',
      };

      // Insert the recipe into the database
      int recipeId = await _dbHelper.insertRecipe(recipeData);

      // Process and insert ingredients
      List<String> ingredients = ingredientsText.split(',');
      for (String ingredientStr in ingredients) {
        String trimmedIngredient = ingredientStr.trim();
        if (trimmedIngredient.isNotEmpty) {
          Map<String, dynamic> ingredientData = {
            'recipeId': recipeId,
            'name': trimmedIngredient,
            'quantity': 'to taste', // Default quantity
            'unit': '',
          };
          await _dbHelper.insertIngredient(ingredientData);
        }
      }

      print('Successfully added new recipe: $name');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Recipe "$name" added successfully!')),
      );
    } catch (e) {
      print('Error adding recipe: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error adding recipe: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: widget.title,
        onLanguageChanged: (languageCode) {
          print('Language changed to: $languageCode');
        },
        onFavoriteToggle: (userId, recipeId, isFavorite) {
          print('Favorite updated: $recipeId = $isFavorite');
        },
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: AppTheme.primaryGreen,
              ),
            )
          : _recipes.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'No ${widget.title.toLowerCase()} found',
                        style: TextStyle(
                          fontSize: 18,
                          color: AppTheme.mediumText,
                        ),
                      ),
                      SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadRecipes,
                        child: Text('Refresh'),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: () async {
                    await _loadRecipes();
                    await _loadFavorites();
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _recipes.length,
                    itemBuilder: (context, index) {
                      final recipe = _recipes[index];
                      bool isFavorite = _favoriteRecipeIds.contains(recipe['id']);
                      return RecipeItemCard(
                        recipe: recipe,
                        index: index,
                        isFavorite: isFavorite,
                        onFavoriteToggle: () => _toggleFavorite(recipe['id'], recipe),
                      );
                    },
                  ),
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddRecipeDialog,
        backgroundColor: AppTheme.primaryGreen,
        child: const Icon(Icons.add, color: Colors.white),
        tooltip: 'Add new recipe',
      ),
    );
  }
}

class RecipeItemCard extends StatelessWidget {
  final Map<String, dynamic> recipe;
  final int index;
  final bool isFavorite;
  final VoidCallback onFavoriteToggle;

  const RecipeItemCard({
    Key? key,
    required this.recipe,
    required this.index,
    required this.isFavorite,
    required this.onFavoriteToggle,
  }) : super(key: key);

  // Define the color palette
  List<Color> get colorPalette => [
    Color(0xFFADD8E6), // Light blue
    Color(0xFFFFB6C1), // Light pink
    Color(0xFF90EE90), // Light green
    Color(0xFFFFFFE0), // Light yellow
    Color(0xFFFFCCCB), // Light red
  ];

  // Get a color based on the index
  Color _getCardColor(int index) {
    return colorPalette[index % colorPalette.length];
  }

  @override
  Widget build(BuildContext context) {
    final cardColor = _getCardColor(index);
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: BorderSide(color: cardColor.withOpacity(0.3), width: 1), // Optional border
      ),
      elevation: 0,
      child: Container(
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Recipe Name in Bold
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      recipe['name'],
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87, // Darker text for better contrast
                      ),
                    ),
                  ),
                  // Favorite Icon
                  IconButton(
                    icon: Icon(
                      isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: isFavorite ? Colors.red : Colors.grey,
                    ),
                    onPressed: onFavoriteToggle,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              
              // Ingredients in Italic
              FutureBuilder<List<Map<String, dynamic>>>(
                future: _getIngredientsForRecipe(recipe['id']),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator(
                      color: AppTheme.primaryGreen,
                    );
                  } else if (snapshot.hasError) {
                    return Text(
                      'Error loading ingredients',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                    );
                  } else if (snapshot.data == null || snapshot.data!.isEmpty) {
                    return Text(
                      'No ingredients available',
                      style: TextStyle(
                        fontSize: 14,
                        fontStyle: FontStyle.italic,
                        color: Colors.black54,
                      ),
                    );
                  } else {
                    // Display ingredients as a comma-separated list
                    final ingredients = snapshot.data!
                        .map((ingredient) => '${ingredient['quantity']} ${ingredient['unit']} ${ingredient['name']}')
                        .join(', ');
                    
                    return Text(
                      ingredients,
                      style: TextStyle(
                        fontSize: 14,
                        fontStyle: FontStyle.italic,
                        color: Colors.black54,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    );
                  }
                },
              ),
              
              // Add some spacing at the bottom
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Future<List<Map<String, dynamic>>> _getIngredientsForRecipe(int recipeId) async {
    final dbHelper = DatabaseHelper.instance;
    return await dbHelper.getIngredients(recipeId);
  }
}