// lib/css/app_theme.dart
import 'package:flutter/material.dart';

class AppTheme {
  // Light theme colors - using grey instead of cream
  static const Color primaryColor = Color(0xFFFCC342); // Yellow from your image
  static const Color lightBackground = Color(0xFFF5F5F5); // Light grey background
  static const Color darkText = Color(0xFF333333);
  static const Color mediumText = Color(0xFF666666);
  static const Color lightGrey = Color(0xFFE0E0E0); // Light grey for cards
  
  // Dark theme colors - using black instead of light grey
  static const Color darkBackground = Color(0xFF000000); // Pure black
  static const Color darkCard = Color(0xFF1A1A1A); // Very dark grey for cards
  static const Color darkTextLight = Color(0xFFFFFFFF);
  static const Color darkTextMedium = Color(0xFFB0B0B0);
  static const Color darkPrimary = Color(0xFFFCC342); // Yellow accent
  
  // Get current theme data
  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      primaryColor: primaryColor,
      scaffoldBackgroundColor: lightBackground,
      appBarTheme: AppBarTheme(
        backgroundColor: lightBackground,
        elevation: 0,
        titleTextStyle: TextStyle(
          color: darkText,
          fontSize: 18,
          fontWeight: FontWeight.bold,
          fontFamily: 'Crimson',
        ),
        iconTheme: IconThemeData(color: darkText),
      ),
      textTheme: TextTheme(
        bodyLarge: TextStyle(color: darkText, fontFamily: 'Crimson'),
        bodyMedium: TextStyle(color: mediumText, fontFamily: 'Crimson'),
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: primaryColor),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
      colorScheme: ColorScheme.light(
        primary: primaryColor,
        secondary: primaryColor,
        surface: Colors.white,
        background: lightBackground,
      ),
    );
  }
  
  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: darkPrimary,
      scaffoldBackgroundColor: darkBackground,
      appBarTheme: AppBarTheme(
        backgroundColor: darkBackground,
        elevation: 0,
        titleTextStyle: TextStyle(
          color: darkTextLight,
          fontSize: 18,
          fontWeight: FontWeight.bold,
          fontFamily: 'Crimson',
        ),
        iconTheme: IconThemeData(color: darkTextLight),
      ),
      textTheme: TextTheme(
        bodyLarge: TextStyle(color: darkTextLight, fontFamily: 'Crimson'),
        bodyMedium: TextStyle(color: darkTextMedium, fontFamily: 'Crimson'),
      ),
      cardTheme: CardThemeData(
        color: darkCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: darkPrimary),
        ),
        filled: true,
        fillColor: Color(0xFF2D2D2D),
      ),
      colorScheme: ColorScheme.dark(
        primary: darkPrimary,
        secondary: darkPrimary,
        surface: darkCard,
        background: darkBackground,
      ),
    );
  }

  static Color? get primaryGreen => null;

  static Color? get lightBeige => null;

  static Color? get cream => null;
}