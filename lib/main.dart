import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:recipe_book/css/app_theme.dart';
import 'package:recipe_book/pages/SplashScreen.dart';
import 'package:recipe_book/pages/home_page.dart';
import 'package:recipe_book/services/localization.dart';
import 'package:recipe_book/providers/theme_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart' as sqflite_common show databaseFactory;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          title: 'Lebanese Recipe Book',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeProvider.themeMode,
          home: const SplashScreen(),
          routes: {
            // Define other routes as needed
          },
          builder: (context, child) {
            return Directionality(
              textDirection: TextDirection.ltr,
              child: child!,
            );
          },
        );
      },
    );
  }
}