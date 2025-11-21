// lib/pages/add_recipe_page.dart
import 'package:flutter/material.dart';
import 'package:recipe_book/css/app_theme.dart';
import 'package:recipe_book/database/database_helper.dart';

class AddRecipePage extends StatefulWidget {
  const AddRecipePage({super.key});

  @override
  State<AddRecipePage> createState() => _AddRecipePageState();
}

class _AddRecipePageState extends State<AddRecipePage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _instructionsController = TextEditingController();
  final TextEditingController _prepTimeController = TextEditingController();
  final TextEditingController _cookTimeController = TextEditingController();
  final TextEditingController _servingsController = TextEditingController();
  final List<TextEditingController> _ingredientNameControllers = [];
  final List<TextEditingController> _ingredientQuantityControllers = [];
  final List<TextEditingController> _ingredientUnitControllers = [];
  final List<GlobalKey<FormState>> _ingredientFormKeys = [];

  String _selectedCategory = 'Food';
  String _selectedCuisineType = 'Breakfast';
  int _ingredientCount = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Recipe'),
        backgroundColor: AppTheme.primaryGreen,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Recipe Name
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Recipe Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a recipe name';
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
                  labelText: 'Category',
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
              
              // Cuisine Type Selection
              DropdownButtonFormField<String>(
                value: _selectedCuisineType,
                decoration: const InputDecoration(
                  labelText: 'Cuisine Type',
                  border: OutlineInputBorder(),
                ),
                items: ['Breakfast', 'Launch', 'Main Course', 'Snacks', 'Juices', 'Sweets']
                    .map((type) => DropdownMenuItem(
                          value: type,
                          child: Text(type),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCuisineType = value!;
                  });
                },
              ),
              const SizedBox(height: 16),
              
              // Prep Time
              TextFormField(
                controller: _prepTimeController,
                decoration: const InputDecoration(
                  labelText: 'Prep Time (minutes)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter prep time';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Cook Time
              TextFormField(
                controller: _cookTimeController,
                decoration: const InputDecoration(
                  labelText: 'Cook Time (minutes)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter cook time';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Servings
              TextFormField(
                controller: _servingsController,
                decoration: const InputDecoration(
                  labelText: 'Servings',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter number of servings';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Instructions
              TextFormField(
                controller: _instructionsController,
                decoration: const InputDecoration(
                  labelText: 'Instructions',
                  border: OutlineInputBorder(),
                ),
                maxLines: 8,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter instructions';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Ingredients Section
              const Text(
                'Ingredients',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              
              ...List.generate(_ingredientCount, (index) {
                // Initialize controllers if they don't exist
                if (_ingredientNameControllers.length <= index) {
                  _ingredientNameControllers.add(TextEditingController());
                  _ingredientQuantityControllers.add(TextEditingController());
                  _ingredientUnitControllers.add(TextEditingController());
                  _ingredientFormKeys.add(GlobalKey<FormState>());
                }
                
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Form(
                    key: _ingredientFormKeys[index],
                    child: Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: TextFormField(
                            controller: _ingredientNameControllers[index],
                            decoration: const InputDecoration(
                              labelText: 'Ingredient Name',
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter ingredient name';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          flex: 1,
                          child: TextFormField(
                            controller: _ingredientQuantityControllers[index],
                            decoration: const InputDecoration(
                              labelText: 'Qty',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter quantity';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          flex: 1,
                          child: TextFormField(
                            controller: _ingredientUnitControllers[index],
                            decoration: const InputDecoration(
                              labelText: 'Unit',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
              
              ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    _ingredientCount++;
                  });
                },
                icon: const Icon(Icons.add),
                label: const Text('Add Ingredient'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryGreen,
                  foregroundColor: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              
              // Add Recipe Button
              ElevatedButton(
                onPressed: _addRecipe,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryGreen,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text(
                  'Add Recipe',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _addRecipe() async {
    // Validate main form
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    // Validate all ingredient forms
    bool allIngredientsValid = true;
    for (int i = 0; i < _ingredientCount; i++) {
      if (!_ingredientFormKeys[i].currentState!.validate()) {
        allIngredientsValid = false;
      }
    }
    
    if (!allIngredientsValid) {
      return;
    }

    try {
      // Create recipe map
      Map<String, dynamic> recipe = {
        'name': _nameController.text,
        'description': _descriptionController.text,
        'category': _selectedCategory,
        'cuisineType': _selectedCuisineType,
        'prepTime': int.parse(_prepTimeController.text),
        'cookTime': int.parse(_cookTimeController.text),
        'servings': int.parse(_servingsController.text),
        'instructions': _instructionsController.text,
      };

      // Insert recipe and get the ID
      int recipeId = await DatabaseHelper.instance.insertRecipe(recipe);

      // Insert ingredients
      for (int i = 0; i < _ingredientCount; i++) {
        Map<String, dynamic> ingredient = {
          'recipeId': recipeId,
          'name': _ingredientNameControllers[i].text,
          'quantity': _ingredientQuantityControllers[i].text,
          'unit': _ingredientUnitControllers[i].text,
        };
        await DatabaseHelper.instance.insertIngredient(ingredient);
      }

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Recipe added successfully!'),
        ),
      );

      // Clear form
      _clearForm();

      // Navigate back
      Navigator.pop(context);
    } catch (e) {
      print('Error adding recipe: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error adding recipe: $e'),
        ),
      );
    }
  }

  void _clearForm() {
    _nameController.clear();
    _descriptionController.clear();
    _instructionsController.clear();
    _prepTimeController.clear();
    _cookTimeController.clear();
    _servingsController.clear();
    
    for (var controller in _ingredientNameControllers) {
      controller.clear();
    }
    for (var controller in _ingredientQuantityControllers) {
      controller.clear();
    }
    for (var controller in _ingredientUnitControllers) {
      controller.clear();
    }
    
    setState(() {
      _ingredientCount = 1;
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _instructionsController.dispose();
    _prepTimeController.dispose();
    _cookTimeController.dispose();
    _servingsController.dispose();
    
    for (var controller in _ingredientNameControllers) {
      controller.dispose();
    }
    for (var controller in _ingredientQuantityControllers) {
      controller.dispose();
    }
    for (var controller in _ingredientUnitControllers) {
      controller.dispose();
    }
    
    super.dispose();
  }
}

class AppTheme {
  static Color? get primaryGreen => null;
}