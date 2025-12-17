import 'package:flutter/material.dart';

class AppThemes {
  // Dark Theme Colors
  static const Color darkBackground = Color(0xFF1c1f23);
  static const Color darkSurface = Color(0xFF2c2f33);
  static const Color darkBottomNav = Color(0xFF2a2a2a);
  static const Color darkText = Colors.white;
  static const Color darkTextSecondary = Colors.white70;

  // Light Theme Colors
  static const Color lightBackground = Color(0xFFF5F5F5);
  static const Color lightSurface = Colors.white;
  static const Color lightBottomNav = Color(0xFFFFFFFF);
  static const Color lightText = Color(0xFF1c1f23);
  static const Color lightTextSecondary = Color(0xFF666666);

  // Dark Theme
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: darkBackground,
    primaryColor: darkSurface,
    colorScheme: const ColorScheme.dark(
      primary: Color(0xFF6200EE),
      secondary: Color(0xFF03DAC6),
      surface: darkSurface,
      background: darkBackground,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: darkSurface,
      foregroundColor: darkText,
      elevation: 0,
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: darkText),
      bodyMedium: TextStyle(color: darkText),
      titleLarge: TextStyle(color: darkText, fontWeight: FontWeight.bold),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: darkSurface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey.shade700),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey.shade700),
      ),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: darkBottomNav,
      selectedItemColor: Colors.white,
      unselectedItemColor: Colors.grey,
    ),
  );

  // Light Theme
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: lightBackground,
    primaryColor: lightSurface,
    colorScheme: const ColorScheme.light(
      primary: Color(0xFF6200EE),
      secondary: Color(0xFF03DAC6),
      surface: lightSurface,
      background: lightBackground,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: lightSurface,
      foregroundColor: lightText,
      elevation: 2,
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: lightText),
      bodyMedium: TextStyle(color: lightText),
      titleLarge: TextStyle(color: lightText, fontWeight: FontWeight.bold),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: lightBottomNav,
      selectedItemColor: Color(0xFF1c1f23),
      unselectedItemColor: Colors.grey,
    ),
  );

  // Helper method to get colors based on current theme
  static Color getBackgroundColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? darkBackground
        : lightBackground;
  }

  static Color getSurfaceColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? darkSurface
        : lightSurface;
  }

  static Color getTextColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? darkText
        : lightText;
  }

  static Color getBottomNavColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? darkBottomNav
        : lightBottomNav;
  }
}
