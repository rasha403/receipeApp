// lib/pages/dashboard_page.dart (Updated with Calorie Calculator)
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:recipe_book/AppBar/app_bar.dart';
import 'package:recipe_book/css/app_theme.dart';
import 'package:recipe_book/database/database_helper.dart';
import 'package:recipe_book/pages/BreakfastPage.dart';
import 'package:recipe_book/pages/Juices.dart';
import 'package:recipe_book/pages/LaunchPage.dart';
import 'package:recipe_book/pages/Snacks.dart';
import 'package:recipe_book/pages/account_page.dart';
import 'package:recipe_book/pages/admin_page.dart';
import 'package:recipe_book/pages/blogs_page.dart';
import 'package:recipe_book/pages/favorite.dart';
import 'package:recipe_book/pages/users_list_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  int? _currentUserId;
  bool _isAdmin = false;
  int _currentQuoteIndex = 0;
  Timer? _timer;

  // Calorie Calculator Variables
  final TextEditingController _recipeSearchController = TextEditingController();
  String? _selectedRecipeName;
  int? _caloriesFound;
  double? _proteinFound;
  double? _carbsFound;
  double? _fatsFound;
  bool _isSearching = false;
  List<Map<String, dynamic>> _searchResults = [];

  // List of colorful quotes
  final List<Map<String, String>> _quotes = [
    {
      'text': 'A recipe has no soul. You, as the cook, must bring soul to the recipe.',
      'author': 'Thomas Keller',
      'color': '#FF6B6B',
    },
    {
      'text': 'Cooking is like love; it should be entered into with abandon or not at all.',
      'author': 'Harriet Van Horne',
      'color': '#4ECDC4',
    },
    {
      'text': 'Food is our common ground, a universal experience.',
      'author': 'James Beard',
      'color': '#45B7D1',
    },
    {
      'text': 'The secret ingredient is always love.',
      'author': 'Unknown',
      'color': '#96CEB4',
    },
    {
      'text': 'Life is uncertain. Eat dessert first.',
      'author': 'Ernestine Ulmer',
      'color': '#FFEAA7',
    },
    {
      'text': 'In every meal, there is a story waiting to be told.',
      'author': 'Unknown',
      'color': '#DDA0DD',
    },
    {
      'text': 'Good food is the foundation of genuine happiness.',
      'author': 'Auguste Escoffier',
      'color': '#FFB347',
    },
    {
      'text': 'Cooking is an art, but all art requires knowing the techniques.',
      'author': 'Julia Child',
      'color': '#AEC6CF',
    },
  ];

  @override
  void initState() {
    super.initState();
    _getCurrentUserId();
    _checkAdminStatus();
    _startQuoteTimer();
  }

  void _startQuoteTimer() {
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      setState(() {
        _currentQuoteIndex = (_currentQuoteIndex + 1) % _quotes.length;
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _recipeSearchController.dispose();
    super.dispose();
  }

  Future<void> _getCurrentUserId() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('userId');
    setState(() {
      _currentUserId = userId;
    });
  }

  Future<void> _checkAdminStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final isAdmin = prefs.getBool('isAdmin') ?? false;
    setState(() {
      _isAdmin = isAdmin;
    });
  }

  // Search for recipe and calculate calories
  Future<void> _searchRecipe(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _searchResults = [];
        _caloriesFound = null;
        _proteinFound = null;
        _carbsFound = null;
        _fatsFound = null;
        _selectedRecipeName = null;
      });
      return;
    }

    setState(() {
      _isSearching = true;
    });

    try {
      final results = await _dbHelper.searchRecipes(query);
      setState(() {
        _searchResults = results;
        _isSearching = false;
        
        if (results.isNotEmpty) {
          // Automatically select the first result
          final recipe = results[0];
          _selectedRecipeName = recipe['name'];
          final nutrition = _calculateNutrition(recipe);
          _caloriesFound = nutrition['calories'];
          _proteinFound = nutrition['protein'];
          _carbsFound = nutrition['carbs'];
          _fatsFound = nutrition['fats'];
        } else {
          _caloriesFound = null;
          _proteinFound = null;
          _carbsFound = null;
          _fatsFound = null;
          _selectedRecipeName = null;
        }
      });
    } catch (e) {
      setState(() {
        _isSearching = false;
        _caloriesFound = null;
        _proteinFound = null;
        _carbsFound = null;
        _fatsFound = null;
        _selectedRecipeName = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error searching recipe: $e')),
      );
    }
  }

  // Calculate nutrition information based on recipe
  Map<String, dynamic> _calculateNutrition(Map<String, dynamic> recipe) {
    // This is a simplified nutrition calculation
    // In a real app, you would have nutrition data stored in the database for each recipe
    
    int baseCalories = 200;
    double baseProtein = 10.0;
    double baseCarbs = 25.0;
    double baseFats = 8.0;
    
    // Adjust based on servings
    int servings = recipe['servings'] ?? 1;
    baseCalories += (servings * 50);
    baseProtein += (servings * 5);
    baseCarbs += (servings * 8);
    baseFats += (servings * 3);
    
    // Adjust based on cook time
    int cookTime = recipe['cookTime'] ?? 0;
    baseCalories += (cookTime * 2);
    baseCarbs += (cookTime * 0.5);
    
    // Adjust based on category
    String category = recipe['category'] ?? '';
    if (category == 'Sweets') {
      baseCalories += 150;
      baseCarbs += 30;
      baseFats += 10;
      baseProtein += 2;
    } else if (category == 'Food') {
      baseCalories += 100;
      baseProtein += 15;
      baseCarbs += 15;
      baseFats += 8;
    } else if (category == 'Juices') {
      baseCalories += 50;
      baseCarbs += 15;
      baseProtein += 1;
      baseFats += 0.5;
    } else if (category == 'Snacks') {
      baseCalories += 75;
      baseProtein += 5;
      baseCarbs += 10;
      baseFats += 5;
    }
    
    return {
      'calories': baseCalories,
      'protein': baseProtein.roundToDouble(),
      'carbs': baseCarbs.roundToDouble(),
      'fats': baseFats.roundToDouble(),
    };
  }

  void _selectRecipe(Map<String, dynamic> recipe) {
    setState(() {
      _selectedRecipeName = recipe['name'];
      final nutrition = _calculateNutrition(recipe);
      _caloriesFound = nutrition['calories'];
      _proteinFound = nutrition['protein'];
      _carbsFound = nutrition['carbs'];
      _fatsFound = nutrition['fats'];
      _recipeSearchController.text = recipe['name'];
      _searchResults = [];
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Lebanese Recipes',
        currentUserId: _currentUserId,
        onLanguageChanged: (languageCode) {
          print('Language changed to: $languageCode');
        },
        onFavoriteToggle: (userId, recipeId, isFavorite) {
          print('Favorite updated: $recipeId = $isFavorite');
        },
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: theme.scaffoldBackgroundColor,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Lebanese Recipes',
                    style: TextStyle(
                      color: theme.brightness == Brightness.light 
                          ? Colors.black 
                          : Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Discover delicious recipes',
                    style: TextStyle(
                      color: theme.brightness == Brightness.light 
                          ? Colors.black54 
                          : Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.favorite),
              title: const Text('Favorite List'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const FavoriteListPage()),
                );
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.people),
              title: const Text('Users List'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const UsersListPage()),
                );
              },
            ),
            const Divider(),
            if (_isAdmin) ...[
              ListTile(
                leading: const Icon(Icons.admin_panel_settings, color: Colors.orange),
                title: const Text('Admin Panel', style: TextStyle(color: Colors.orange)),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AdminPage()),
                  );
                },
              ),
              const Divider(),
            ],
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Settings'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.person_add),
              title: const Text('Create Account'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (context) => AccountPage()));
              },
            ),
            // In your dashboard_page.dart, update the Blogs ListTile:
ListTile(
  leading: const Icon(Icons.rss_feed),
  title: const Text('Blogs'),
  onTap: () {
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const BlogsPage()),
    );
  },
),
            ListTile(
              leading: const Icon(Icons.info),
              title: const Text('About Us'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () async {
                Navigator.pop(context);
                final prefs = await SharedPreferences.getInstance();
                await prefs.setBool('isLoggedIn', false);
                await prefs.remove('userEmail');
                await prefs.remove('userFullName');
                await prefs.remove('userId');
                await prefs.remove('isAdmin');
                
                setState(() {
                  _isAdmin = false;
                });
                
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Logged out successfully')),
                );
              },
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Animated Quotes Card
            AnimatedContainer(
              duration: Duration(milliseconds: 500),
              curve: Curves.easeInOut,
              margin: EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(int.parse(_quotes[_currentQuoteIndex]['color']!.substring(1, 7), radix: 16)).withOpacity(0.8),
                    Color(int.parse(_quotes[_currentQuoteIndex]['color']!.substring(1, 7), radix: 16)),
                  ],
                ),
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    Text(
                      '"${_quotes[_currentQuoteIndex]['text']}"',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                        fontStyle: FontStyle.italic,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 8),
                    Text(
                      '- ${_quotes[_currentQuoteIndex]['author']}',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: Colors.white70,
                      ),
                      textAlign: TextAlign.right,
                    ),
                  ],
                ),
              ),
            ),

            // Categories Section
            Text(
              'Categories',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: theme.textTheme.bodyLarge?.color,
              ),
            ),
            SizedBox(height: 20),
            
            // Category Grid
            GridView.count(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              children: [
                CategoryCard(
                  title: 'Breakfast',
                  imagePath: 'assets/images/BreakfastCategory.png',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const BreakfastCategoryPage(
                          category: 'Breakfast',
                          title: 'Breakfast',
                        ),
                      ),
                    );
                  },
                ),
                CategoryCard(
                  title: 'Snacks',
                  imagePath: 'assets/images/SnacksCategory.png',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SnacksCategoryPage(
                          category: 'Snacks',
                          title: 'Snacks',
                        ),
                      ),
                    );
                  },
                ),
                CategoryCard(
                  title: 'Lunch',
                  imagePath: 'assets/images/LaunchCategory.png',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LaunchCategoryPage(
                          category: 'Launch',
                          title: 'Lunch',
                        ),
                      ),
                    );
                  },
                ),
                CategoryCard(
                  title: 'Juices',
                  imagePath: 'assets/images/JuicesCategory.png',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const JuicesCategoryPage(
                          category: 'Juices',
                          title: 'Juices',
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),

            SizedBox(height: 30),

            // Calorie Calculator Card (Below Categories)
            Container(
              margin: EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: isDark ? Colors.grey[850] : Colors.grey[100],
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.calculate, 
                          color: theme.primaryColor, 
                          size: 28
                        ),
                        SizedBox(width: 10),
                        Text(
                          'Calculate Nutrition',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: theme.textTheme.bodyLarge?.color,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    
                    // Search Field
                    Container(
                      decoration: BoxDecoration(
                        color: isDark ? Colors.grey[800] : const Color(0xFFFFF8E1),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isDark ? Colors.grey[700]! : const Color(0xFFFFF8E1),
                        ),
                      ),
                      child: TextField(
                        controller: _recipeSearchController,
                        style: TextStyle(color: theme.textTheme.bodyLarge?.color),
                        decoration: InputDecoration(
                          hintText: 'Enter recipe name...',
                          hintStyle: TextStyle(
                            color: isDark ? Colors.grey[500] : Colors.grey[600],
                          ),
                          prefixIcon: Icon(
                            Icons.search, 
                            color: Colors.black,
                          ),
                          suffixIcon: _recipeSearchController.text.isNotEmpty
                              ? IconButton(
                                  icon: Icon(Icons.clear, color: Colors.grey),
                                  onPressed: () {
                                    _recipeSearchController.clear();
                                    setState(() {
                                      _searchResults = [];
                                      _caloriesFound = null;
                                      _proteinFound = null;
                                      _carbsFound = null;
                                      _fatsFound = null;
                                      _selectedRecipeName = null;
                                    });
                                  },
                                )
                              : null,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: EdgeInsets.symmetric(vertical: 12),
                        ),
                        onChanged: (value) {
                          _searchRecipe(value);
                        },
                      ),
                    ),
                    
                    SizedBox(height: 12),
                    
                    // Search Results Dropdown
                    if (_searchResults.isNotEmpty && _selectedRecipeName == null)
                      Container(
                        constraints: BoxConstraints(maxHeight: 200),
                        decoration: BoxDecoration(
                          color: isDark ? Colors.grey[800] : Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
                          ),
                        ),
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: _searchResults.length,
                          itemBuilder: (context, index) {
                            final recipe = _searchResults[index];
                            return ListTile(
                              leading: Icon(
                                Icons.restaurant, 
                                color: theme.primaryColor,
                              ),
                              title: Text(
                                recipe['name'],
                                style: TextStyle(
                                  color: theme.textTheme.bodyLarge?.color,
                                ),
                              ),
                              subtitle: Text(
                                recipe['category'] ?? 'No category',
                                style: TextStyle(
                                  color: isDark ? Colors.grey[500] : Colors.grey[600],
                                ),
                              ),
                              onTap: () => _selectRecipe(recipe),
                            );
                          },
                        ),
                      ),
                    
                    // Loading Indicator
                    if (_isSearching)
                      Center(
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: CircularProgressIndicator(
                            color: theme.primaryColor,
                          ),
                        ),
                      ),
                    
                    // Nutrition Result Display
                    if (_caloriesFound != null && _selectedRecipeName != null)
                      Container(
                        margin: EdgeInsets.only(top: 16),
                        padding: EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: isDark ? Colors.grey[800] : Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: theme.primaryColor.withOpacity(0.3),
                            width: 2,
                          ),
                        ),
                        child: Column(
                          children: [
                            Text(
                              _selectedRecipeName!,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: theme.textTheme.bodyLarge?.color,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: 20),
                            
                            // Calories Display (Prominent)
                            Container(
                              padding: EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: theme.primaryColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.local_fire_department, 
                                    color: Colors.orange, 
                                    size: 40,
                                  ),
                                  SizedBox(width: 15),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '$_caloriesFound',
                                        style: TextStyle(
                                          fontSize: 32,
                                          fontWeight: FontWeight.bold,
                                          color: theme.textTheme.bodyLarge?.color,
                                        ),
                                      ),
                                      Text(
                                        'calories',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            
                            SizedBox(height: 20),
                            
                            // Macronutrients Grid
                            Row(
                              children: [
                                Expanded(
                                  child: _buildNutrientCard(
                                    'Protein',
                                    _proteinFound!,
                                    'g',
                                    Colors.blue,
                                    Icons.fitness_center,
                                    isDark,
                                    theme,
                                  ),
                                ),
                                SizedBox(width: 12),
                                Expanded(
                                  child: _buildNutrientCard(
                                    'Carbs',
                                    _carbsFound!,
                                    'g',
                                    Colors.orange,
                                    Icons.bakery_dining,
                                    isDark,
                                    theme,
                                  ),
                                ),
                                SizedBox(width: 12),
                                Expanded(
                                  child: _buildNutrientCard(
                                    'Fats',
                                    _fatsFound!,
                                    'g',
                                    Colors.green,
                                    Icons.water_drop,
                                    isDark,
                                    theme,
                                  ),
                                ),
                              ],
                            ),
                            
                            SizedBox(height: 12),
                            Text(
                              'Estimated per serving',
                              style: TextStyle(
                                fontSize: 12,
                                color: isDark ? Colors.grey[500] : Colors.grey[600],
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ),
                      ),
                    
                    // No Results Message
                    if (_recipeSearchController.text.isNotEmpty && 
                        _searchResults.isEmpty && 
                        !_isSearching &&
                        _caloriesFound == null)
                      Padding(
                        padding: EdgeInsets.only(top: 16),
                        child: Text(
                          'No recipes found. Try a different search term.',
                          style: TextStyle(
                            color: isDark ? Colors.grey[500] : Colors.grey[600],
                            fontSize: 14,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper method to build nutrient cards
  Widget _buildNutrientCard(
    String label,
    double value,
    String unit,
    Color color,
    IconData icon,
    bool isDark,
    ThemeData theme,
  ) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          SizedBox(height: 8),
          Text(
            '${value.toStringAsFixed(1)}$unit',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: theme.textTheme.bodyLarge?.color,
            ),
          ),
          SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: isDark ? Colors.grey[400] : Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}

class CategoryCard extends StatelessWidget {
  final String title;
  final String imagePath;
  final VoidCallback onTap;

  const CategoryCard({
    Key? key,
    required this.title,
    required this.imagePath,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Card(
        margin: const EdgeInsets.only(bottom: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(15),
                topRight: Radius.circular(15),
              ),
              child: Image.asset(
                imagePath,
                height: 120,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 120,
                    color: Colors.grey[200],
                    child: Icon(
                      Icons.image,
                      size: 40,
                      color: theme.primaryColor,
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: theme.textTheme.bodyLarge?.color,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}