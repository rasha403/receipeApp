import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
// Import sqflite_common_ffi for web support
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
// Import shared_preferences for device-specific storage
import 'package:shared_preferences/shared_preferences.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;
  DatabaseHelper._init() {
    // Initialize sqflite for web
    if (isWeb) {
      databaseFactory = databaseFactoryFfi;
    }
  }
  // Check if running on web
  static bool get isWeb {
    return identical(0, 0.0); // This returns true on web, false on mobile
  }
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('recipes.db');
    return _database!;
  }
  Future<Database> _initDB(String filePath) async {
    if (isWeb) {
      // For web, use in-memory database or specify a path
      return await databaseFactory.openDatabase(
        inMemoryDatabasePath,
        options: OpenDatabaseOptions(
          version: 9, // Updated version to reflect changes for accountless favorites
          onCreate: _createDB,
          onUpgrade: _onUpgrade,
        ),
      );
    } else {
      // For mobile, use the file system
      final dbPath = await getDatabasesPath();
      final path = join(dbPath, filePath);
      return await openDatabase(
        path,
        version: 9, // Updated version to reflect changes for accountless favorites
        onCreate: _createDB,
        onUpgrade: _onUpgrade,
      );
    }
  }
  void _onUpgrade(Database db, int oldVersion, int newVersion) {
    if (oldVersion < 2) {
      // Add Lebanese cuisine specific fields
      try {
        db.execute('ALTER TABLE recipes ADD COLUMN cuisineType TEXT DEFAULT "Main Course"');
        db.execute('ALTER TABLE recipes ADD COLUMN cookingMethod TEXT');
        db.execute('ALTER TABLE recipes ADD COLUMN specialEquipment TEXT');
        db.execute('ALTER TABLE recipes ADD COLUMN dietaryInfo TEXT');
      } catch (e) {
        // Columns might already exist
      }
    }
    if (oldVersion < 3) {
      // Create users table
      db.execute('''
        CREATE TABLE users (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          fullName TEXT NOT NULL,
          phoneNumber TEXT NOT NULL UNIQUE,
          email TEXT NOT NULL UNIQUE,
          password TEXT NOT NULL,
          createdAt TEXT,
          updatedAt TEXT
        )
      ''');
      // Create user_favorites table
      db.execute('''
        CREATE TABLE user_favorites (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          userId INTEGER,
          recipeId INTEGER,
          FOREIGN KEY (userId) REFERENCES users (id) ON DELETE CASCADE,
          FOREIGN KEY (recipeId) REFERENCES recipes (id) ON DELETE CASCADE,
          UNIQUE(userId, recipeId)
        )
      ''');
    }
    if (oldVersion < 4) {
      // Insert breakfast recipes
      _insertBreakfastRecipes(db);
    }
    if (oldVersion < 5) {
      // Ensure breakfast recipes exist
      _insertBreakfastRecipes(db);
    }
    if (oldVersion < 6) {
      // Insert launch recipes
      _insertLaunchRecipes(db);
    }
    if (oldVersion < 7) {
      // Insert snack recipes
      _insertSnackRecipes(db);
    }
    if (oldVersion < 8) {
      // Insert juice recipes
      _insertJuiceRecipes(db);
    }
    // No specific upgrade logic needed for version 9 changes (accountless favorites)
    // The database schema remains the same, only the logic changes.
  }
  Future _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';
    const integerType = 'INTEGER NOT NULL';
    const realType = 'REAL';
    const textNullable = 'TEXT';
    // Create recipes table
    await db.execute('''
      CREATE TABLE recipes (
        id $idType,
        name $textType,
        description TEXT,
        category $textType,
        cuisine $textType DEFAULT 'Lebanese',
        cuisineType TEXT DEFAULT 'Main Course',
        difficulty TEXT DEFAULT 'Medium',
        prepTime $integerType,
        cookTime $integerType,
        servings $integerType,
        instructions $textType,
        imagePath TEXT,
        isFavorite INTEGER DEFAULT 0, // This global flag still exists but might not be used for user favorites
        createdAt $textType,
        updatedAt $textType,
        cookingMethod TEXT,
        specialEquipment TEXT,
        dietaryInfo TEXT
      )
    ''');
    // Create ingredients table
    await db.execute('''
      CREATE TABLE ingredients (
        id $idType,
        recipeId $integerType,
        name $textType,
        quantity TEXT,
        unit TEXT,
        optional INTEGER DEFAULT 0,
        preparation TEXT,
        FOREIGN KEY (recipeId) REFERENCES recipes (id) ON DELETE CASCADE
      )
    ''');
    // Create recipe categories table
    await db.execute('''
      CREATE TABLE recipe_categories (
        id $idType,
        name $textType UNIQUE,
        icon TEXT,
        color TEXT
      )
    ''');
    // Create cuisines table
    await db.execute('''
      CREATE TABLE cuisines (
        id $idType,
        name $textType UNIQUE,
        description TEXT,
        region TEXT
      )
    ''');
    await db.execute('''
  CREATE TABLE blogs (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    title TEXT NOT NULL,
    content TEXT NOT NULL,
    author TEXT NOT NULL,
    imagePath TEXT,
    createdAt TEXT,
    updatedAt TEXT
  )
''');
    // Create users table
    await db.execute('''
      CREATE TABLE users (
        id $idType,
        fullName $textType,
        phoneNumber TEXT NOT NULL UNIQUE,
        email TEXT NOT NULL UNIQUE,
        password $textType NOT NULL,
        createdAt $textType,
        updatedAt $textType
      )
    ''');
    // Create user_favorites table
    await db.execute('''
      CREATE TABLE user_favorites (
        id $idType,
        userId $integerType,
        recipeId $integerType,
        FOREIGN KEY (userId) REFERENCES users (id) ON DELETE CASCADE,
        FOREIGN KEY (recipeId) REFERENCES recipes (id) ON DELETE CASCADE,
        UNIQUE(userId, recipeId)
      )
    ''');
    // Insert Lebanese cuisine
    await db.insert('cuisines', {
      'name': 'Lebanese',
      'description': 'Traditional Lebanese cuisine',
      'region': 'Levant'
    });
    // Insert recipe categories
    final categories = [
      {'name': 'Food', 'icon': 'restaurant', 'color': '#FF6B6B'},
      {'name': 'Sweets', 'icon': 'cake', 'color': '#4ECDC4'},
      {'name': 'Juices', 'icon': 'local_drink', 'color': '#45B7D1'},
      {'name': 'Crepe', 'icon': 'pan_tool', 'color': '#96CEB4'},
      {'name': 'Snacks', 'icon': 'fastfood', 'color': '#FFEAA7'},
    ];
    for (var cat in categories) {
      await db.insert('recipe_categories', cat);
    }
    // Insert Lebanese recipes
    await _insertLebaneseRecipes(db);
    // Insert breakfast recipes
    await _insertBreakfastRecipes(db);
    // Insert launch recipes
    await _insertLaunchRecipes(db);
    // Insert snack recipes
    await _insertSnackRecipes(db);
    // Insert juice recipes
    await _insertJuiceRecipes(db);
  }
  // ... (Keep all your _insertLebaneseRecipes, _insertBreakfastRecipes, etc., implementations unchanged) ...
  Future<void> _insertLebaneseRecipes(Database db) async {
    // [Keep your existing Lebanese recipes implementation]
  }
  Future<void> _insertBreakfastRecipes(Database db) async {
    print('🍳 Starting to insert breakfast recipes...');
    // Check if breakfast recipes already exist
    final existingBreakfastRecipes = await db.query(
      'recipes',
      where: 'cuisineType = ?',
      whereArgs: ['Breakfast'],
    );
    if (existingBreakfastRecipes.isNotEmpty) {
      print('✅ Breakfast recipes already exist (${existingBreakfastRecipes.length} recipes)');
      return;
    }
    // Breakfast recipes
    final breakfastRecipes = [
      {
        'name': 'Chia Seed Pudding',
        'description': 'Chia seeds soaked overnight in milk or almond milk, topped with a few berries.',
        'category': 'Food',
        'cuisineType': 'Breakfast',
        'difficulty': 'Easy',
        'prepTime': 5,
        'cookTime': 0,
        'servings': 1,
        'instructions': '1. In a jar or bowl, combine chia seeds and milk\n2. Add a touch of honey or maple syrup if desired\n3. Stir well to prevent clumping\n4. Cover and refrigerate overnight (or at least 4 hours)\n5. Stir in the morning\n6. Top with fresh berries\n7. Serve cold',
        'imagePath': 'assets/images/chia_pudding.jpg',
        'cookingMethod': 'No cooking',
        'dietaryInfo': 'Light & Healthy, Vegetarian, Vegan-optional',
      },
      {
        'name': 'Fruit Salad Bowl',
        'description': 'A mix of apple, kiwi, orange, and pomegranate with a squeeze of lemon.',
        'category': 'Food',
        'cuisineType': 'Breakfast',
        'difficulty': 'Easy',
        'prepTime': 10,
        'cookTime': 0,
        'servings': 1,
        'instructions': '1. Wash all fruits thoroughly\n2. Dice apple into bite-sized pieces\n3. Peel and slice kiwi\n4. Peel and segment orange\n5. Remove pomegranate seeds\n6. Combine all fruits in a bowl\n7. Squeeze fresh lemon juice over the fruit\n8. Toss gently and serve',
        'imagePath': 'assets/images/fruit_salad.jpg',
        'cookingMethod': 'No cooking',
        'dietaryInfo': 'Light & Healthy, Vegetarian, Vegan',
      },
      {
        'name': 'Cucumber & Labneh Plate',
        'description': 'Labneh with cucumbers, mint, and a drizzle of olive oil—very light and fresh.',
        'category': 'Food',
        'cuisineType': 'Breakfast',
        'difficulty': 'Easy',
        'prepTime': 5,
        'cookTime': 0,
        'servings': 1,
        'instructions': '1. Spread labneh on a plate\n2. Slice cucumbers thinly\n3. Arrange cucumber slices on top of labneh\n4. Chop fresh mint leaves\n5. Sprinkle mint over the dish\n6. Drizzle with olive oil\n7. Serve with pita bread if desired',
        'imagePath': 'assets/images/labneh_plate.jpg',
        'cookingMethod': 'No cooking',
        'dietaryInfo': 'Light & Healthy, Vegetarian',
      },
      {
        'name': 'Oatmeal with Cinnamon',
        'description': 'A small bowl of oats cooked with water or milk, topped with a little cinnamon and honey.',
        'category': 'Food',
        'cuisineType': 'Breakfast',
        'difficulty': 'Easy',
        'prepTime': 2,
        'cookTime': 5,
        'servings': 1,
        'instructions': '1. Bring water or milk to a boil\n2. Add oats and reduce heat\n3. Stir occasionally for 5 minutes\n4. Pour into a bowl\n5. Sprinkle cinnamon on top\n6. Drizzle with honey\n7. Serve warm',
        'imagePath': 'assets/images/cinnamon_oatmeal.jpg',
        'cookingMethod': 'Boiling',
        'dietaryInfo': 'Light & Healthy, Vegetarian, Vegan-optional',
      },
      {
        'name': 'Green Smoothie',
        'description': 'Blend spinach + apple + banana + water or almond milk—very light and energizing.',
        'category': 'Juices',
        'cuisineType': 'Breakfast',
        'difficulty': 'Easy',
        'prepTime': 5,
        'cookTime': 0,
        'servings': 1,
        'instructions': '1. Wash spinach thoroughly\n2. Cut apple into chunks\n3. Peel banana\n4. Add all ingredients to blender\n5. Pour in water or almond milk\n6. Blend until smooth\n7. Add ice cubes if desired\n8. Pour into a glass and serve immediately',
        'imagePath': 'assets/images/green_smoothie.jpg',
        'cookingMethod': 'Blending',
        'specialEquipment': 'Blender',
        'dietaryInfo': 'Light & Healthy, Vegetarian, Vegan',
      },
    ];
    for (var recipe in breakfastRecipes) {
      recipe['cuisine'] = 'Lebanese';
      recipe['createdAt'] = DateTime.now().toIso8601String();
      recipe['updatedAt'] = DateTime.now().toIso8601String();
      final recipeId = await db.insert('recipes', recipe);
      // Add ingredients for each recipe
      await _addBreakfastIngredients(db, recipeId, recipe['name'].toString());
    }
    print('✅ Successfully inserted 5 breakfast recipes!');
  }
  Future<void> _insertLaunchRecipes(Database db) async {
    print('🍽️ Starting to insert launch recipes...');
    // Check if launch recipes already exist
    final existingLaunchRecipes = await db.query(
      'recipes',
      where: 'cuisineType = ?',
      whereArgs: ['Launch'],
    );
    if (existingLaunchRecipes.isNotEmpty) {
      print('✅ Launch recipes already exist (${existingLaunchRecipes.length} recipes)');
      return;
    }
    // Launch recipes
    final launchRecipes = [
      {
        'name': 'Grilled Chicken Salad',
        'description': 'Mixed greens, cherry tomatoes, cucumbers, grilled chicken strips, olive oil & lemon dressing.',
        'category': 'Food',
        'cuisineType': 'Launch',
        'difficulty': 'Medium',
        'prepTime': 15,
        'cookTime': 10,
        'servings': 2,
        'instructions': '1. Season chicken with salt and pepper\n2. Grill chicken until cooked through (about 6-8 minutes per side)\n3. Chop mixed greens, cherry tomatoes, and cucumbers\n4. Slice grilled chicken into strips\n5. Combine all ingredients in a large bowl\n6. Drizzle with olive oil and lemon dressing\n7. Toss gently and serve',
        'imagePath': 'assets/images/grilled_chicken_salad.jpg',
        'cookingMethod': 'Grilling',
        'dietaryInfo': 'High-Protein, Low-Carb',
      },
      {
        'name': 'Quinoa & Veggie Bowl',
        'description': 'Quinoa with roasted vegetables (zucchini, carrots, peppers) and a spoon of hummus.',
        'category': 'Food',
        'cuisineType': 'Launch',
        'difficulty': 'Medium',
        'prepTime': 15,
        'cookTime': 25,
        'servings': 2,
        'instructions': '1. Rinse quinoa under cold water\n2. Cook quinoa according to package instructions\n3. Cut zucchini, carrots, and peppers into bite-sized pieces\n4. Toss vegetables with olive oil, salt, and pepper\n5. Roast vegetables in oven at 400°F for 20-25 minutes\n6. Serve quinoa topped with roasted vegetables\n7. Add a spoon of hummus on the side',
        'imagePath': 'assets/images/quinoa_bowl.jpg',
        'cookingMethod': 'Roasting',
        'dietaryInfo': 'Vegetarian, Gluten-Free',
      },
      {
        'name': 'Tuna & Avocado Wrap',
        'description': 'Whole-wheat wrap filled with tuna, avocado, lettuce, and a light yogurt dressing.',
        'category': 'Food',
        'cuisineType': 'Launch',
        'difficulty': 'Easy',
        'prepTime': 10,
        'cookTime': 0,
        'servings': 1,
        'instructions': '1. Flake tuna in a bowl\n2. Mash avocado with a fork\n3. Mix tuna with avocado\n4. Season with salt and pepper\n5. Add light yogurt dressing\n6. Spread mixture on whole-wheat wrap\n7. Add lettuce leaves\n8. Roll tightly and serve',
        'imagePath': 'assets/images/tuna_wrap.jpg',
        'cookingMethod': 'No cooking',
        'dietaryInfo': 'Healthy, Quick',
      },
      {
        'name': 'Lentil Soup with Side Salad',
        'description': 'Warm lentil soup (very filling and protein-rich) served with a small green salad.',
        'category': 'Food',
        'cuisineType': 'Launch',
        'difficulty': 'Medium',
        'prepTime': 15,
        'cookTime': 45,
        'servings': 4,
        'instructions': '1. Rinse lentils under cold water\n2. Heat oil in a large pot over medium heat\n3. Sauté onions, carrots, and celery\n4. Add lentils, broth, and seasonings\n5. Simmer for 30-40 minutes until lentils are tender\n6. Meanwhile, prepare green salad\n7. Serve soup with side salad',
        'imagePath': 'assets/images/lentil_soup.jpg',
        'cookingMethod': 'Simmering',
        'dietaryInfo': 'Vegetarian, High-Protein',
      },
      {
        'name': 'Baked Salmon with Steamed Vegetables',
        'description': 'Salmon baked with lemon and herbs, served with broccoli or green beans.',
        'category': 'Food',
        'cuisineType': 'Launch',
        'difficulty': 'Medium',
        'prepTime': 10,
        'cookTime': 20,
        'servings': 2,
        'instructions': '1. Preheat oven to 375°F\n2. Season salmon with salt, pepper, lemon juice, and herbs\n3. Place salmon on baking sheet\n4. Bake for 15-20 minutes until fish flakes easily\n5. Steam broccoli or green beans\n6. Serve salmon with steamed vegetables',
        'imagePath': 'assets/images/baked_salmon.jpg',
        'cookingMethod': 'Baking',
        'dietaryInfo': 'High-Protein, Omega-3 Rich',
      },
    ];
    for (var recipe in launchRecipes) {
      recipe['cuisine'] = 'Lebanese';
      recipe['createdAt'] = DateTime.now().toIso8601String();
      recipe['updatedAt'] = DateTime.now().toIso8601String();
      final recipeId = await db.insert('recipes', recipe);
      // Add ingredients for each recipe
      await _addLaunchIngredients(db, recipeId, recipe['name'].toString());
    }
    print('✅ Successfully inserted 5 launch recipes!');
  }
  Future<void> _insertSnackRecipes(Database db) async {
    print('🍪 Starting to insert snack recipes...');
    // Check if snack recipes already exist
    final existingSnackRecipes = await db.query(
      'recipes',
      where: 'cuisineType = ?',
      whereArgs: ['Snacks'],
    );
    if (existingSnackRecipes.isNotEmpty) {
      print('✅ Snack recipes already exist (${existingSnackRecipes.length} recipes)');
      return;
    }
    // Snack recipes
    final snackRecipes = [
      {
        'name': 'Mixed Nuts (Unsalted)',
        'description': 'Almonds, walnuts, and cashews — rich in healthy fats and protein.',
        'category': 'Snacks',
        'cuisineType': 'Snacks',
        'difficulty': 'Easy',
        'prepTime': 2,
        'cookTime': 0,
        'servings': 1,
        'instructions': '1. Measure out a portion of mixed nuts (about 1/4 cup)\n2. If desired, add a small amount of dried fruit\n3. Mix well and serve\n4. Store remaining nuts in an airtight container',
        'imagePath': 'assets/images/mixed_nuts.jpg',
        'cookingMethod': 'No cooking',
        'dietaryInfo': 'High-Protein, Healthy Fats',
      },
      {
        'name': 'Apple Slices with Peanut Butter',
        'description': 'A sweet–savory snack that keeps you full.',
        'category': 'Snacks',
        'cuisineType': 'Snacks',
        'difficulty': 'Easy',
        'prepTime': 5,
        'cookTime': 0,
        'servings': 1,
        'instructions': '1. Wash and core an apple\n2. Slice the apple into wedges\n3. Spread peanut butter on each slice\n4. Optionally, sprinkle with cinnamon\n5. Serve immediately',
        'imagePath': 'assets/images/apple_pb.jpg',
        'cookingMethod': 'No cooking',
        'dietaryInfo': 'Healthy, Fiber-Rich',
      },
      {
        'name': 'Greek Yogurt Cup',
        'description': 'Add a drizzle of honey or a few berries if you like.',
        'category': 'Snacks',
        'cuisineType': 'Snacks',
        'difficulty': 'Easy',
        'prepTime': 2,
        'cookTime': 0,
        'servings': 1,
        'instructions': '1. Open or prepare a cup of Greek yogurt\n2. If desired, add a drizzle of honey\n3. Optionally, add a few fresh berries\n4. Stir gently if adding toppings\n5. Serve immediately',
        'imagePath': 'assets/images/greek_yogurt.jpg',
        'cookingMethod': 'No cooking',
        'dietaryInfo': 'High-Protein, Probiotic',
      },
      {
        'name': 'Carrot & Cucumber Sticks with Hummus',
        'description': 'Crunchy, fresh, and packed with fiber.',
        'category': 'Snacks',
        'cuisineType': 'Snacks',
        'difficulty': 'Easy',
        'prepTime': 10,
        'cookTime': 0,
        'servings': 1,
        'instructions': '1. Wash carrots and cucumber\n2. Cut into sticks of similar size\n3. Place hummus in a small bowl\n4. Serve vegetables with hummus for dipping\n5. Enjoy as a crunchy snack',
        'imagePath': 'assets/images/veggie_sticks.jpg',
        'cookingMethod': 'No cooking',
        'dietaryInfo': 'High-Fiber, Vegetarian',
      },
      {
        'name': 'Dark Chocolate (70%+) with a Few Almonds',
        'description': 'A small, satisfying sweet snack without added sugar.',
        'category': 'Snacks',
        'cuisineType': 'Snacks',
        'difficulty': 'Easy',
        'prepTime': 2,
        'cookTime': 0,
        'servings': 1,
        'instructions': '1. Break off a few squares of dark chocolate (70% or higher)\n2. Add a small handful of almonds\n3. Serve on a small plate\n4. Enjoy as a satisfying sweet treat',
        'imagePath': 'assets/images/dark_chocolate.jpg',
        'cookingMethod': 'No cooking',
        'dietaryInfo': 'Antioxidant-Rich, Satisfying',
      },
    ];
    for (var recipe in snackRecipes) {
      recipe['cuisine'] = 'Lebanese';
      recipe['createdAt'] = DateTime.now().toIso8601String();
      recipe['updatedAt'] = DateTime.now().toIso8601String();
      final recipeId = await db.insert('recipes', recipe);
      // Add ingredients for each recipe
      await _addSnackIngredients(db, recipeId, recipe['name'].toString());
    }
    print('✅ Successfully inserted 5 snack recipes!');
  }
  Future<void> _insertJuiceRecipes(Database db) async {
    print('🥤 Starting to insert juice recipes...');
    // Check if juice recipes already exist
    final existingJuiceRecipes = await db.query(
      'recipes',
      where: 'cuisineType = ?',
      whereArgs: ['Juices'],
    );
    if (existingJuiceRecipes.isNotEmpty) {
      print('✅ Juice recipes already exist (${existingJuiceRecipes.length} recipes)');
      return;
    }
    // Juice recipes
    final juiceRecipes = [
      {
        'name': 'Green Detox Juice',
        'description': 'Spinach, Cucumber, Green apple, Lemon, Ginger',
        'category': 'Juices',
        'cuisineType': 'Juices',
        'difficulty': 'Easy',
        'prepTime': 10,
        'cookTime': 0,
        'servings': 1,
        'instructions': '1. Wash all vegetables and fruits\n2. Chop spinach, cucumber, and green apple\n3. Peel and slice ginger\n4. Juice all ingredients together\n5. Add lemon juice\n6. Stir and serve immediately',
        'imagePath': 'assets/images/green_juice.jpg',
        'cookingMethod': 'Juicing',
        'specialEquipment': 'Juicer',
        'dietaryInfo': 'Detox, Low-Calorie',
      },
      {
        'name': 'Carrot–Orange Boost',
        'description': 'Carrot, Orange, Ginger, A splash of lemon',
        'category': 'Juices',
        'cuisineType': 'Juices',
        'difficulty': 'Easy',
        'prepTime': 10,
        'cookTime': 0,
        'servings': 1,
        'instructions': '1. Wash and peel carrots\n2. Peel oranges\n3. Peel and slice ginger\n4. Juice carrots and oranges together\n5. Add ginger and lemon juice\n6. Stir and serve immediately',
        'imagePath': 'assets/images/carrot_juice.jpg',
        'cookingMethod': 'Juicing',
        'specialEquipment': 'Juicer',
        'dietaryInfo': 'Vitamin C Rich, Energy Boost',
      },
      {
        'name': 'Red Antioxidant Mix',
        'description': 'Beetroot, Apple, Carrot, Lemon',
        'category': 'Juices',
        'cuisineType': 'Juices',
        'difficulty': 'Easy',
        'prepTime': 12,
        'cookTime': 0,
        'servings': 1,
        'instructions': '1. Wash and peel beetroot and carrot\n2. Core and slice apple\n3. Juice beetroot, apple, and carrot together\n4. Add lemon juice\n5. Stir and serve immediately\n6. Note: This juice has a vibrant red color',
        'imagePath': 'assets/images/red_juice.jpg',
        'cookingMethod': 'Juicing',
        'specialEquipment': 'Juicer',
        'dietaryInfo': 'Antioxidant Rich, Heart Healthy',
      },
      {
        'name': 'Tropical Energy Juice',
        'description': 'Pineapple, Mango, Orange, A little mint',
        'category': 'Juices',
        'cuisineType': 'Juices',
        'difficulty': 'Easy',
        'prepTime': 12,
        'cookTime': 0,
        'servings': 1,
        'instructions': '1. Peel and core pineapple\n2. Peel and slice mango\n3. Peel oranges\n4. Juice pineapple, mango, and orange together\n5. Add fresh mint leaves\n6. Stir and serve immediately',
        'imagePath': 'assets/images/tropical_juice.jpg',
        'cookingMethod': 'Juicing',
        'specialEquipment': 'Juicer',
        'dietaryInfo': 'Energy Boost, Tropical',
      },
      {
        'name': 'Hydration Refresh Juice',
        'description': 'Watermelon, Mint, A squeeze of lime',
        'category': 'Juices',
        'cuisineType': 'Juices',
        'difficulty': 'Easy',
        'prepTime': 8,
        'cookTime': 0,
        'servings': 1,
        'instructions': '1. Cut watermelon into chunks\n2. Remove seeds if necessary\n3. Juice watermelon chunks\n4. Add fresh mint leaves\n5. Squeeze in lime juice\n6. Stir and serve immediately',
        'imagePath': 'assets/images/watermelon_juice.jpg',
        'cookingMethod': 'Juicing',
        'specialEquipment': 'Juicer',
        'dietaryInfo': 'Hydrating, Refreshing',
      },
    ];
    for (var recipe in juiceRecipes) {
      recipe['cuisine'] = 'Lebanese';
      recipe['createdAt'] = DateTime.now().toIso8601String();
      recipe['updatedAt'] = DateTime.now().toIso8601String();
      final recipeId = await db.insert('recipes', recipe);
      // Add ingredients for each recipe
      await _addJuiceIngredients(db, recipeId, recipe['name'].toString());
    }
    print('✅ Successfully inserted 5 juice recipes!');
  }
  // ... (Keep all your _addBreakfastIngredients, _addLaunchIngredients, etc., implementations unchanged) ...
  Future<void> _addBreakfastIngredients(Database db, int recipeId, String recipeName) async {
    List<Map<String, dynamic>> ingredients = [];
    switch (recipeName) {
      case 'Chia Seed Pudding':
        ingredients = [
          {'recipeId': recipeId, 'name': 'Chia seeds', 'quantity': '3', 'unit': 'tbsp'},
          {'recipeId': recipeId, 'name': 'Milk or almond milk', 'quantity': '1', 'unit': 'cup'},
          {'recipeId': recipeId, 'name': 'Fresh berries', 'quantity': '1/4', 'unit': 'cup'},
          {'recipeId': recipeId, 'name': 'Honey or maple syrup', 'quantity': '1', 'unit': 'tsp', 'optional': 1},
        ];
        break;
      case 'Fruit Salad Bowl':
        ingredients = [
          {'recipeId': recipeId, 'name': 'Apple', 'quantity': '1', 'unit': 'medium'},
          {'recipeId': recipeId, 'name': 'Kiwi', 'quantity': '1', 'unit': 'medium'},
          {'recipeId': recipeId, 'name': 'Orange', 'quantity': '1', 'unit': 'medium'},
          {'recipeId': recipeId, 'name': 'Pomegranate seeds', 'quantity': '1/4', 'unit': 'cup'},
          {'recipeId': recipeId, 'name': 'Lemon juice', 'quantity': '1', 'unit': 'tbsp'},
        ];
        break;
      case 'Cucumber & Labneh Plate':
        ingredients = [
          {'recipeId': recipeId, 'name': 'Labneh', 'quantity': '1/2', 'unit': 'cup'},
          {'recipeId': recipeId, 'name': 'Cucumber', 'quantity': '1', 'unit': 'medium'},
          {'recipeId': recipeId, 'name': 'Fresh mint', 'quantity': '5-6', 'unit': 'leaves'},
          {'recipeId': recipeId, 'name': 'Olive oil', 'quantity': '1', 'unit': 'tbsp'},
          {'recipeId': recipeId, 'name': 'Pita bread', 'quantity': '1', 'unit': 'piece', 'optional': 1},
        ];
        break;
      case 'Oatmeal with Cinnamon':
        ingredients = [
          {'recipeId': recipeId, 'name': 'Rolled oats', 'quantity': '1/2', 'unit': 'cup'},
          {'recipeId': recipeId, 'name': 'Water or milk', 'quantity': '1', 'unit': 'cup'},
          {'recipeId': recipeId, 'name': 'Cinnamon', 'quantity': '1/2', 'unit': 'tsp'},
          {'recipeId': recipeId, 'name': 'Honey', 'quantity': '1', 'unit': 'tsp'},
        ];
        break;
      case 'Green Smoothie':
        ingredients = [
          {'recipeId': recipeId, 'name': 'Fresh spinach', 'quantity': '1', 'unit': 'cup'},
          {'recipeId': recipeId, 'name': 'Apple', 'quantity': '1', 'unit': 'medium'},
          {'recipeId': recipeId, 'name': 'Banana', 'quantity': '1', 'unit': 'medium'},
          {'recipeId': recipeId, 'name': 'Water or almond milk', 'quantity': '1', 'unit': 'cup'},
          {'recipeId': recipeId, 'name': 'Ice cubes', 'quantity': '3-4', 'unit': 'cubes', 'optional': 1},
        ];
        break;
    }
    for (var ingredient in ingredients) {
      await db.insert('ingredients', ingredient);
    }
  }
  Future<void> _addLaunchIngredients(Database db, int recipeId, String recipeName) async {
    List<Map<String, dynamic>> ingredients = [];
    switch (recipeName) {
      case 'Grilled Chicken Salad':
        ingredients = [
          {'recipeId': recipeId, 'name': 'Chicken breast', 'quantity': '200', 'unit': 'g'},
          {'recipeId': recipeId, 'name': 'Mixed greens', 'quantity': '2', 'unit': 'cups'},
          {'recipeId': recipeId, 'name': 'Cherry tomatoes', 'quantity': '1/2', 'unit': 'cup'},
          {'recipeId': recipeId, 'name': 'Cucumber', 'quantity': '1', 'unit': 'medium'},
          {'recipeId': recipeId, 'name': 'Olive oil', 'quantity': '2', 'unit': 'tbsp'},
          {'recipeId': recipeId, 'name': 'Lemon', 'quantity': '1', 'unit': 'juice of'},
          {'recipeId': recipeId, 'name': 'Salt and pepper', 'quantity': 'to taste', 'unit': ''},
        ];
        break;
      case 'Quinoa & Veggie Bowl':
        ingredients = [
          {'recipeId': recipeId, 'name': 'Quinoa', 'quantity': '1', 'unit': 'cup'},
          {'recipeId': recipeId, 'name': 'Zucchini', 'quantity': '1', 'unit': 'medium'},
          {'recipeId': recipeId, 'name': 'Carrots', 'quantity': '2', 'unit': 'medium'},
          {'recipeId': recipeId, 'name': 'Bell peppers', 'quantity': '1', 'unit': 'large'},
          {'recipeId': recipeId, 'name': 'Hummus', 'quantity': '2', 'unit': 'tbsp'},
          {'recipeId': recipeId, 'name': 'Olive oil', 'quantity': '2', 'unit': 'tbsp'},
          {'recipeId': recipeId, 'name': 'Salt and pepper', 'quantity': 'to taste', 'unit': ''},
        ];
        break;
      case 'Tuna & Avocado Wrap':
        ingredients = [
          {'recipeId': recipeId, 'name': 'Tuna', 'quantity': '1', 'unit': 'can'},
          {'recipeId': recipeId, 'name': 'Avocado', 'quantity': '1', 'unit': 'medium'},
          {'recipeId': recipeId, 'name': 'Whole-wheat wrap', 'quantity': '1', 'unit': 'piece'},
          {'recipeId': recipeId, 'name': 'Lettuce', 'quantity': '2-3', 'unit': 'leaves'},
          {'recipeId': recipeId, 'name': 'Yogurt dressing', 'quantity': '2', 'unit': 'tbsp'},
          {'recipeId': recipeId, 'name': 'Salt and pepper', 'quantity': 'to taste', 'unit': ''},
        ];
        break;
      case 'Lentil Soup with Side Salad':
        ingredients = [
          {'recipeId': recipeId, 'name': 'Lentils', 'quantity': '1', 'unit': 'cup'},
          {'recipeId': recipeId, 'name': 'Vegetable broth', 'quantity': '4', 'unit': 'cups'},
          {'recipeId': recipeId, 'name': 'Onion', 'quantity': '1', 'unit': 'medium'},
          {'recipeId': recipeId, 'name': 'Carrots', 'quantity': '2', 'unit': 'medium'},
          {'recipeId': recipeId, 'name': 'Celery', 'quantity': '2', 'unit': 'stalks'},
          {'recipeId': recipeId, 'name': 'Mixed greens', 'quantity': '2', 'unit': 'cups'},
          {'recipeId': recipeId, 'name': 'Salt and pepper', 'quantity': 'to taste', 'unit': ''},
        ];
        break;
      case 'Baked Salmon with Steamed Vegetables':
        ingredients = [
          {'recipeId': recipeId, 'name': 'Salmon fillet', 'quantity': '2', 'unit': 'pieces'},
          {'recipeId': recipeId, 'name': 'Broccoli', 'quantity': '1', 'unit': 'cup'},
          {'recipeId': recipeId, 'name': 'Green beans', 'quantity': '1', 'unit': 'cup'},
          {'recipeId': recipeId, 'name': 'Lemon', 'quantity': '1', 'unit': 'juice of'},
          {'recipeId': recipeId, 'name': 'Fresh herbs', 'quantity': '2', 'unit': 'tbsp'},
          {'recipeId': recipeId, 'name': 'Olive oil', 'quantity': '1', 'unit': 'tbsp'},
          {'recipeId': recipeId, 'name': 'Salt and pepper', 'quantity': 'to taste', 'unit': ''},
        ];
        break;
    }
    for (var ingredient in ingredients) {
      await db.insert('ingredients', ingredient);
    }
  }
  Future<void> _addSnackIngredients(Database db, int recipeId, String recipeName) async {
    List<Map<String, dynamic>> ingredients = [];
    switch (recipeName) {
      case 'Mixed Nuts (Unsalted)':
        ingredients = [
          {'recipeId': recipeId, 'name': 'Almonds', 'quantity': '1/4', 'unit': 'cup'},
          {'recipeId': recipeId, 'name': 'Walnuts', 'quantity': '1/4', 'unit': 'cup'},
          {'recipeId': recipeId, 'name': 'Cashews', 'quantity': '1/4', 'unit': 'cup'},
          {'recipeId': recipeId, 'name': 'Dried fruit', 'quantity': '1', 'unit': 'tbsp', 'optional': 1},
        ];
        break;
      case 'Apple Slices with Peanut Butter':
        ingredients = [
          {'recipeId': recipeId, 'name': 'Apple', 'quantity': '1', 'unit': 'medium'},
          {'recipeId': recipeId, 'name': 'Peanut butter', 'quantity': '2', 'unit': 'tbsp'},
          {'recipeId': recipeId, 'name': 'Cinnamon', 'quantity': '1/4', 'unit': 'tsp', 'optional': 1},
        ];
        break;
      case 'Greek Yogurt Cup':
        ingredients = [
          {'recipeId': recipeId, 'name': 'Greek yogurt', 'quantity': '1', 'unit': 'cup'},
          {'recipeId': recipeId, 'name': 'Honey', 'quantity': '1', 'unit': 'tsp', 'optional': 1},
          {'recipeId': recipeId, 'name': 'Fresh berries', 'quantity': '1/4', 'unit': 'cup', 'optional': 1},
        ];
        break;
      case 'Carrot & Cucumber Sticks with Hummus':
        ingredients = [
          {'recipeId': recipeId, 'name': 'Carrots', 'quantity': '2', 'unit': 'medium'},
          {'recipeId': recipeId, 'name': 'Cucumber', 'quantity': '1', 'unit': 'medium'},
          {'recipeId': recipeId, 'name': 'Hummus', 'quantity': '1/4', 'unit': 'cup'},
        ];
        break;
      case 'Dark Chocolate (70%+) with a Few Almonds':
        ingredients = [
          {'recipeId': recipeId, 'name': 'Dark chocolate (70%+)', 'quantity': '3-4', 'unit': 'squares'},
          {'recipeId': recipeId, 'name': 'Almonds', 'quantity': '5-6', 'unit': 'pieces'},
        ];
        break;
    }
    for (var ingredient in ingredients) {
      await db.insert('ingredients', ingredient);
    }
  }
  Future<void> _addJuiceIngredients(Database db, int recipeId, String recipeName) async {
    List<Map<String, dynamic>> ingredients = [];
    switch (recipeName) {
      case 'Green Detox Juice':
        ingredients = [
          {'recipeId': recipeId, 'name': 'Spinach', 'quantity': '1', 'unit': 'cup'},
          {'recipeId': recipeId, 'name': 'Cucumber', 'quantity': '1', 'unit': 'medium'},
          {'recipeId': recipeId, 'name': 'Green apple', 'quantity': '1', 'unit': 'medium'},
          {'recipeId': recipeId, 'name': 'Lemon', 'quantity': '1', 'unit': 'juice of'},
          {'recipeId': recipeId, 'name': 'Ginger', 'quantity': '1', 'unit': 'inch piece'},
        ];
        break;
      case 'Carrot–Orange Boost':
        ingredients = [
          {'recipeId': recipeId, 'name': 'Carrots', 'quantity': '2', 'unit': 'medium'},
          {'recipeId': recipeId, 'name': 'Oranges', 'quantity': '2', 'unit': 'medium'},
          {'recipeId': recipeId, 'name': 'Ginger', 'quantity': '1/2', 'unit': 'inch piece'},
          {'recipeId': recipeId, 'name': 'Lemon', 'quantity': '1/2', 'unit': 'juice of', 'optional': 1},
        ];
        break;
      case 'Red Antioxidant Mix':
        ingredients = [
          {'recipeId': recipeId, 'name': 'Beetroot', 'quantity': '1/2', 'unit': 'medium'},
          {'recipeId': recipeId, 'name': 'Apple', 'quantity': '1', 'unit': 'medium'},
          {'recipeId': recipeId, 'name': 'Carrots', 'quantity': '1', 'unit': 'medium'},
          {'recipeId': recipeId, 'name': 'Lemon', 'quantity': '1/2', 'unit': 'juice of'},
        ];
        break;
      case 'Tropical Energy Juice':
        ingredients = [
          {'recipeId': recipeId, 'name': 'Pineapple', 'quantity': '1/2', 'unit': 'cup chunks'},
          {'recipeId': recipeId, 'name': 'Mango', 'quantity': '1/2', 'unit': 'cup chunks'},
          {'recipeId': recipeId, 'name': 'Orange', 'quantity': '1', 'unit': 'medium'},
          {'recipeId': recipeId, 'name': 'Fresh mint', 'quantity': '5-6', 'unit': 'leaves'},
        ];
        break;
      case 'Hydration Refresh Juice':
        ingredients = [
          {'recipeId': recipeId, 'name': 'Watermelon', 'quantity': '2', 'unit': 'cups chunks'},
          {'recipeId': recipeId, 'name': 'Fresh mint', 'quantity': '5-6', 'unit': 'leaves'},
          {'recipeId': recipeId, 'name': 'Lime', 'quantity': '1/2', 'unit': 'juice of'},
        ];
        break;
    }
    for (var ingredient in ingredients) {
      await db.insert('ingredients', ingredient);
    }
  }
  // ... (Keep _addSampleIngredients implementation unchanged) ...
  Future<void> _addSampleIngredients(Database db, int recipeId, String recipeName) async {
    // [Keep your existing ingredients implementation]
  }

  // *** MODIFIED FAVORITE METHODS FOR ACCOUNTLESS USE ***
  // Helper function to get the set of favorite recipe IDs from SharedPreferences
  Future<Set<int>> _getFavoriteRecipeIds() async {
    final prefs = await SharedPreferences.getInstance();
    final List<int>? list = prefs.getIntList('favoriteRecipeIds');
    return list != null ? list.toSet() : <int>{}; // Return empty set if null
  }

  // Device-specific favorite methods
  Future<void> addFavorite(int recipeId, Map<String, dynamic> recipe) async  {
    final prefs = await SharedPreferences.getInstance();
    Set<int> favorites = await _getFavoriteRecipeIds(); // Get current list
    favorites.add(recipeId); // Add new ID
    // Save back to SharedPreferences
    await prefs.setIntList('favoriteRecipeIds', favorites.toList());
  }

  Future<void> removeFavorite(int recipeId, Map<String, dynamic> recipe) async {
    final prefs = await SharedPreferences.getInstance();
    Set<int> favorites = await _getFavoriteRecipeIds(); // Get current list
    favorites.remove(recipeId); // Remove ID
    // Save back to SharedPreferences
    await prefs.setIntList('favoriteRecipeIds', favorites.toList());
  }

  // Function to check if a specific recipe is in the device's favorites list
  Future<bool> isRecipeFavorite(int recipeId, Map<String, dynamic> recipe) async {
    Set<int> favorites = await _getFavoriteRecipeIds();
    return favorites.contains(recipeId);
  }

  // Updated function to get favorite recipes based on stored IDs on this device
  Future<List<Map<String, dynamic>>> getUserFavorites(int userId) async {
    Set<int> favoriteIds = await _getFavoriteRecipeIds();
    if (favoriteIds.isEmpty) {
      return []; // Return empty list if no favorites
    }

    final db = await instance.database;
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

  // *** KEEP EXISTING USER MANAGEMENT METHODS IF YOU STILL WANT ACCOUNTS FOR OTHER FEATURES ***
  // (e.g., adding recipes might still require an account if you want server sync)
  // Or remove them if you don't need accounts at all.
  Future<int> insertUser(Map<String, dynamic> user) async {
    final db = await instance.database;
    user['createdAt'] = DateTime.now().toIso8601String();
    user['updatedAt'] = DateTime.now().toIso8601String();
    return await db.insert('users', user);
  }

  Future<Map<String, dynamic>?> getUserByEmail(String email) async {
    final db = await instance.database;
    final maps = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
    );
    return maps.isNotEmpty ? maps.first : null;
  }

  Future<Map<String, dynamic>?> getUserByPhoneNumber(String phoneNumber) async {
    final db = await instance.database;
    final maps = await db.query(
      'users',
      where: 'phoneNumber = ?',
      whereArgs: [phoneNumber],
    );
    return maps.isNotEmpty ? maps.first : null;
  }

  Future<bool> validateUser(String email, String password) async {
    final db = await instance.database;
    final maps = await db.query(
      'users',
      where: 'email = ? AND password = ?',
      whereArgs: [email, password],
    );
    return maps.isNotEmpty;
  }

  Future<int> insertBlog(Map<String, dynamic> blog) async {
  final db = await instance.database;
  blog['createdAt'] = DateTime.now().toIso8601String();
  blog['updatedAt'] = DateTime.now().toIso8601String();
  return await db.insert('blogs', blog);
}

Future<List<Map<String, dynamic>>> getAllBlogs() async {
  final db = await instance.database;
  return await db.query('blogs', orderBy: 'createdAt DESC');
}

Future<Map<String, dynamic>?> getBlog(int id) async {
  final db = await instance.database;
  final maps = await db.query(
    'blogs',
    where: 'id = ?',
    whereArgs: [id],
  );
  return maps.isNotEmpty ? maps.first : null;
}
  Future<int> insertRecipe(Map<String, dynamic> recipe) async {
    final db = await instance.database;
    recipe['cuisine'] = 'Lebanese';
    recipe['createdAt'] = DateTime.now().toIso8601String();
    recipe['updatedAt'] = DateTime.now().toIso8601String();
    return await db.insert('recipes', recipe);
  }

  Future<int> insertIngredient(Map<String, dynamic> ingredient) async {
    final db = await instance.database;
    return await db.insert('ingredients', ingredient);
  }

  Future<List<Map<String, dynamic>>> getAllRecipes() async {
    final db = await instance.database;
    return await db.query('recipes', orderBy: 'createdAt DESC');
  }

  Future<List<Map<String, dynamic>>> getRecipesByCategory(String category) async {
    final db = await instance.database;
    return await db.query(
      'recipes',
      where: 'category = ?',
      whereArgs: [category],
      orderBy: 'name ASC',
    );
  }

  Future<List<Map<String, dynamic>>> getRecipesByCuisineType(String cuisineType) async {
    final db = await instance.database;
    return await db.query(
      'recipes',
      where: 'cuisineType = ?',
      whereArgs: [cuisineType],
      orderBy: 'name ASC',
    );
  }

  Future<List<Map<String, dynamic>>> getRecipesByMainCategory(String mainCategory) async {
    final db = await instance.database;
    String cuisineType;
    switch (mainCategory) {
      case 'Breakfast':
        cuisineType = 'Breakfast';
        break;
      case 'Launch':
        cuisineType = 'Launch';
        break;
      case 'Lunch':
        cuisineType = 'Main Course';
        break;
      case 'Snacks':
        cuisineType = 'Snacks';
        break;
      case 'Juices':
        cuisineType = 'Juices';
        break;
      case 'Sweets':
        cuisineType = 'Sweets';
        break;
      default:
        return await getAllRecipes();
    }
    return await db.query(
      'recipes',
      where: 'cuisineType = ?',
      whereArgs: [cuisineType],
      orderBy: 'name ASC',
    );
  }

  Future<List<Map<String, dynamic>>> getAllRecipeCategories() async {
    final db = await instance.database;
    return await db.query('recipe_categories', orderBy: 'name ASC');
  }

  Future<List<Map<String, dynamic>>> getAllCuisines() async {
    final db = await instance.database;
    return await db.query('cuisines');
  }

  Future<Map<String, dynamic>?> getRecipe(int id) async {
    final db = await instance.database;
    final maps = await db.query(
      'recipes',
      where: 'id = ?',
      whereArgs: [id],
    );
    return maps.isNotEmpty ? maps.first : null;
  }

  Future<List<Map<String, dynamic>>> getIngredients(int recipeId) async {
    final db = await instance.database;
    return await db.query(
      'ingredients',
      where: 'recipeId = ?',
      whereArgs: [recipeId],
      orderBy: 'name ASC',
    );
  }

  // *** REMOVED THE OLD GLOBAL getFavoriteRecipes METHOD ***
  // Future<List<Map<String, dynamic>>> getFavoriteRecipes(int i) async { ... }

  // *** KEEP SEARCH, UPDATE, DELETE METHODS ***
  Future<List<Map<String, dynamic>>> searchRecipes(String query) async {
    final db = await instance.database;
    return await db.query(
      'recipes',
      where: 'name LIKE ? OR description LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
    );
  }

  Future<int> updateRecipe(Map<String, dynamic> recipe) async {
    final db = await instance.database;
    final id = recipe['id'];
    recipe['updatedAt'] = DateTime.now().toIso8601String();
    return await db.update(
      'recipes',
      recipe,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // *** KEEP THE OLD toggleFavorite METHOD (IT UPDATES THE GLOBAL isFavorite FLAG) ***
  // You might want to rename this to avoid confusion, e.g., toggleGlobalFavorite
  Future<int> toggleFavorite(int id, int isFavorite, int i) async {
    final db = await instance.database;
    return await db.update(
      'recipes',
      {'isFavorite': isFavorite},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteRecipe(int id) async {
    final db = await instance.database;
    return await db.delete(
      'recipes',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteIngredient(int id) async {
    final db = await instance.database;
    return await db.delete(
      'ingredients',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteIngredientsForRecipe(int recipeId) async {
    final db = await instance.database;
    return await db.delete(
      'ingredients',
      where: 'recipeId = ?',
      whereArgs: [recipeId],
    );
  }

  // ... (Keep other existing methods like deleteUser, getAllUsers, close unchanged) ...
  Future<int> deleteUser(int userId) async {
  final db = await instance.database;
  // This will also delete related favorites due to the CASCADE constraint
  return await db.delete(
    'users',
    where: 'id = ?',
    whereArgs: [userId],
  );
}
  Future close() async {
    final db = await instance.database;
    await db.close();
  }
  Future<List<Map<String, dynamic>>> getFavoriteRecipes(int userId) async {
    final db = await instance.database;
    // Query to get recipes that are marked as favorites for this user
    // Note: The original implementation used the global isFavorite flag
    // If you want to use the new device-specific favorites, you'd use getUserFavorites(-1) instead
    List<Map<String, dynamic>> result = await db.query(
      'recipes',
      where: 'isFavorite = ?',
      whereArgs: [1], // Assuming 1 means true/favorite
      orderBy: 'name ASC',
    );
    return result;
  }
  // Replace the empty method with this implementation
 Future<List<int>> getFavoriteRecipeIds(int userId) async {
    Set<int> favoriteIds = await _getFavoriteRecipeIds();
    return favoriteIds.toList();
  }

  Future getAllUsers() async {}
 
}

extension on SharedPreferences {
  Future<void> setIntList(String s, List<int> list) async {}
  
  List<int>? getIntList(String s) {}
}