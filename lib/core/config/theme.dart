import 'package:flutter/material.dart';

class TokyoDarkTheme {
  static const Color background = Color(0xFF1A1B26);
  static const Color surface = Color(0xFF24283B);
  static const Color accent = Color(0xFF7AA2F7);
  static const Color accentSecondary = Color(0xFFBB9AF7);
  static const Color textPrimary = Color(0xFFA9B1D6);
  static const Color textSecondary = Color(0xFF565F89);
  static const Color success = Color(0xFF9ECE6A);
  static const Color warning = Color(0xFFE0AF68);
  static const Color error = Color(0xFFF7768E);

  static ThemeData get theme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: background,
      primaryColor: accent,
      colorScheme: const ColorScheme.dark(
        primary: accent,
        secondary: accentSecondary,
        surface: surface,
        error: error,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: background,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: surface,
        selectedItemColor: accent,
        unselectedItemColor: textSecondary,
        type: BottomNavigationBarType.fixed,
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: textPrimary),
        bodyMedium: TextStyle(color: textPrimary),
        titleLarge: TextStyle(color: textPrimary, fontWeight: FontWeight.bold),
      ),
    );
  }
}
