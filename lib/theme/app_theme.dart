import 'package:flutter/material.dart';

class AppTheme {
  // Exact colors from the images
  static const Color primaryBlue = Color(0xFF6366F1); // Indigo
  static const Color lightBlueBg = Color(0xFFEFF6FF); // Light blue background
  static const Color darkBlueBg = Color(0xFF1E293B); // Dark blue
  static const Color accentPurple = Color(0xFF8B5CF6);
  
  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    primaryColor: primaryBlue,
    scaffoldBackgroundColor: lightBlueBg,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryBlue,
      brightness: Brightness.light,
    ),
    cardTheme: const CardThemeData(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
    ),
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        fontSize: 56,
        fontWeight: FontWeight.w900,
        letterSpacing: -1.5,
      ),
      headlineLarge: TextStyle(
        fontSize: 40,
        fontWeight: FontWeight.bold,
      ),
      titleLarge: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
    ),
  );

  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    primaryColor: primaryBlue,
    scaffoldBackgroundColor: darkBlueBg,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryBlue,
      brightness: Brightness.dark,
    ),
    cardTheme: const CardThemeData(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
    ),
  );
}
