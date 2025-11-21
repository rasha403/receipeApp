// Recipe Model
class Recipe {
  final int? id;
  final String name;
  final String? description;
  final String category;
  final String? cuisine;
  final String? difficulty;
  final int prepTime; // in minutes
  final int cookTime; // in minutes
  final int servings;
  final String instructions;
  final String? imagePath;
  final bool isFavorite;
  final DateTime createdAt;
  final DateTime updatedAt;

  Recipe({
    this.id,
    required this.name,
    this.description,
    required this.category,
    this.cuisine,
    this.difficulty,
    required this.prepTime,
    required this.cookTime,
    required this.servings,
    required this.instructions,
    this.imagePath,
    this.isFavorite = false,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  // Convert Recipe to Map for database
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'category': category,
      'cuisine': cuisine,
      'difficulty': difficulty,
      'prepTime': prepTime,
      'cookTime': cookTime,
      'servings': servings,
      'instructions': instructions,
      'imagePath': imagePath,
      'isFavorite': isFavorite ? 1 : 0,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  // Create Recipe from Map
  factory Recipe.fromMap(Map<String, dynamic> map) {
    return Recipe(
      id: map['id'] as int?,
      name: map['name'] as String,
      description: map['description'] as String?,
      category: map['category'] as String,
      cuisine: map['cuisine'] as String?,
      difficulty: map['difficulty'] as String?,
      prepTime: map['prepTime'] as int,
      cookTime: map['cookTime'] as int,
      servings: map['servings'] as int,
      instructions: map['instructions'] as String,
      imagePath: map['imagePath'] as String?,
      isFavorite: map['isFavorite'] == 1,
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: DateTime.parse(map['updatedAt'] as String),
    );
  }

  // Get total cooking time
  int get totalTime => prepTime + cookTime;

  // Copy with method for updates
  Recipe copyWith({
    int? id,
    String? name,
    String? description,
    String? category,
    String? cuisine,
    String? difficulty,
    int? prepTime,
    int? cookTime,
    int? servings,
    String? instructions,
    String? imagePath,
    bool? isFavorite,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Recipe(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      category: category ?? this.category,
      cuisine: cuisine ?? this.cuisine,
      difficulty: difficulty ?? this.difficulty,
      prepTime: prepTime ?? this.prepTime,
      cookTime: cookTime ?? this.cookTime,
      servings: servings ?? this.servings,
      instructions: instructions ?? this.instructions,
      imagePath: imagePath ?? this.imagePath,
      isFavorite: isFavorite ?? this.isFavorite,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

// Ingredient Model
class Ingredient {
  final int? id;
  final int recipeId;
  final String name;
  final String? quantity;
  final String? unit;

  Ingredient({
    this.id,
    required this.recipeId,
    required this.name,
    this.quantity,
    this.unit,
  });

  // Convert Ingredient to Map for database
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'recipeId': recipeId,
      'name': name,
      'quantity': quantity,
      'unit': unit,
    };
  }

  // Create Ingredient from Map
  factory Ingredient.fromMap(Map<String, dynamic> map) {
    return Ingredient(
      id: map['id'] as int?,
      recipeId: map['recipeId'] as int,
      name: map['name'] as String,
      quantity: map['quantity'] as String?,
      unit: map['unit'] as String?,
    );
  }

  // Format ingredient for display
  String get displayText {
    final parts = <String>[];
    if (quantity != null && quantity!.isNotEmpty) parts.add(quantity!);
    if (unit != null && unit!.isNotEmpty) parts.add(unit!);
    parts.add(name);
    return parts.join(' ');
  }

  // Copy with method
  Ingredient copyWith({
    int? id,
    int? recipeId,
    String? name,
    String? quantity,
    String? unit,
  }) {
    return Ingredient(
      id: id ?? this.id,
      recipeId: recipeId ?? this.recipeId,
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
    );
  }
}

// Complete Recipe with Ingredients
class RecipeWithIngredients {
  final Recipe recipe;
  final List<Ingredient> ingredients;

  RecipeWithIngredients({
    required this.recipe,
    required this.ingredients,
  });
}