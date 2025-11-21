
import 'package:flutter/material.dart';
import 'package:recipe_book/css/app_theme.dart'; // Assuming AppTheme is defined here
import 'package:recipe_book/database/database_helper.dart'; // For DatabaseHelper



class AddRecipePage extends StatefulWidget {
  final int userId;

  const AddRecipePage({
    Key? key,
    required this.userId,
  }) : super(key: key);

  @override
  State<AddRecipePage> createState() => _AddRecipePageState();
}

class _AddRecipePageState extends State<AddRecipePage> {
  final _formKey = GlobalKey<FormState>();
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _instructionsController = TextEditingController();
  final List<TextEditingController> _ingredientControllers = [
    TextEditingController(),
    TextEditingController(),
  ];
  final List<TextEditingController> _quantityControllers = [
    TextEditingController(),
    TextEditingController(),
  ];
  final List<TextEditingController> _unitControllers = [
    TextEditingController(),
    TextEditingController(),
  ];

  String _selectedCategory = 'Food';
  int _prepTime = 30;
  int _cookTime = 30;
  int _servings = 4;
  String _difficulty = 'Medium';
  String _cuisineType = 'Main Course';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Recipe'),
        backgroundColor: AppTheme.cream,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Recipe Name
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Recipe Name *',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter recipe name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Description
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),

              // Category Selection
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: const InputDecoration(
                  labelText: 'Category *',
                  border: OutlineInputBorder(),
                ),
                items: ['Food', 'Sweets', 'Juices', 'Crepe', 'Snacks']
                    .map((category) => DropdownMenuItem(
                          value: category,
                          child: Text(category),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCategory = value!;
                  });
                },
              ),
              const SizedBox(height: 16),

              // Cuisine Type
              DropdownButtonFormField<String>(
                value: _cuisineType,
                decoration: const InputDecoration(
                  labelText: 'Cuisine Type',
                  border: OutlineInputBorder(),
                ),
                items: ['Main Course', 'Appetizer', 'Dessert', 'Beverage']
                    .map((type) => DropdownMenuItem(
                          value: type,
                          child: Text(type),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _cuisineType = value!;
                  });
                },
              ),
              const SizedBox(height: 16),

              // Difficulty
              DropdownButtonFormField<String>(
                value: _difficulty,
                decoration: const InputDecoration(
                  labelText: 'Difficulty',
                  border: OutlineInputBorder(),
                ),
                items: ['Easy', 'Medium', 'Hard']
                    .map((level) => DropdownMenuItem(
                          value: level,
                          child: Text(level),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _difficulty = value!;
                  });
                },
              ),
              const SizedBox(height: 16),

              // Time Inputs
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Prep Time (min)',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        setState(() {
                          _prepTime = int.tryParse(value) ?? 30;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Cook Time (min)',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        setState(() {
                          _cookTime = int.tryParse(value) ?? 30;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Servings',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        setState(() {
                          _servings = int.tryParse(value) ?? 4;
                        });
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Ingredients Section
              const Text(
                'Ingredients * (at least 2 required)',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),

              // Dynamic ingredient inputs
              Column(
                children: List.generate(_ingredientControllers.length, (index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: TextFormField(
                            controller: _ingredientControllers[index],
                            decoration: InputDecoration(
                              labelText: 'Ingredient ${index + 1}',
                              border: const OutlineInputBorder(),
                            ),
                            validator: index < 2
                                ? (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Ingredient is required';
                                    }
                                    return null;
                                  }
                                : null,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextFormField(
                            controller: _quantityControllers[index],
                            decoration: const InputDecoration(
                              labelText: 'Qty',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextFormField(
                            controller: _unitControllers[index],
                            decoration: const InputDecoration(
                              labelText: 'Unit',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ),
              const SizedBox(height: 8),
              ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    _ingredientControllers.add(TextEditingController());
                    _quantityControllers.add(TextEditingController());
                    _unitControllers.add(TextEditingController());
                  });
                },
                icon: const Icon(Icons.add),
                label: const Text('Add More Ingredient'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryGreen,
                ),
              ),
              const SizedBox(height: 16),

              // Instructions
              TextFormField(
                controller: _instructionsController,
                decoration: const InputDecoration(
                  labelText: 'Instructions *',
                  border: OutlineInputBorder(),
                ),
                maxLines: 6,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter instructions';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Submit Button
              ElevatedButton(
                onPressed: _submitRecipe,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryGreen,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text(
                  'Add Recipe',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submitRecipe() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Check if at least 2 ingredients are provided
    int filledIngredients = 0;
    for (int i = 0; i < _ingredientControllers.length; i++) {
      if (_ingredientControllers[i].text.isNotEmpty) {
        filledIngredients++;
      }
    }

    if (filledIngredients < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add at least 2 ingredients'),
        ),
      );
      return;
    }

    try {
      // Insert recipe
      final recipeId = await _dbHelper.insertRecipe({
        'name': _nameController.text,
        'description': _descriptionController.text,
        'category': _selectedCategory,
        'cuisine': 'Lebanese',
        'cuisineType': _cuisineType,
        'difficulty': _difficulty,
        'prepTime': _prepTime,
        'cookTime': _cookTime,
        'servings': _servings,
        'instructions': _instructionsController.text,
        'isFavorite': 0,
      });

      // Insert ingredients
      for (int i = 0; i < _ingredientControllers.length; i++) {
        if (_ingredientControllers[i].text.isNotEmpty) {
          await _dbHelper.insertIngredient({
            'recipeId': recipeId,
            'name': _ingredientControllers[i].text,
            'quantity': _quantityControllers[i].text,
            'unit': _unitControllers[i].text,
          });
        }
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Recipe added successfully!'),
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error adding recipe: $e'),
        ),
      );
    }
  }
}