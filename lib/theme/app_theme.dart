import 'package:flutter/material.dart';

class AppTheme {
  static const Color primaryNavy = Color(0xFF0A2A4B);
  static const Color creamBackground = Color(0xFFF5F3E7);

  static ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    useMaterial3: false,

    scaffoldBackgroundColor: creamBackground,
    primaryColor: primaryNavy,

    colorScheme: const ColorScheme.light(
      primary: primaryNavy,
      secondary: primaryNavy,
      surface: Colors.white,
      error: Color(0xFFD9534F),
      onPrimary: Colors.white,
      onSurface: Color(0xFF1E1E1E),
    ),

    appBarTheme: const AppBarTheme(
      backgroundColor: primaryNavy,
      foregroundColor: Colors.white,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      iconTheme: IconThemeData(color: Colors.white),
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    ),

    cardColor: Colors.white,
    dividerColor: const Color(0xFFE6E6E6),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      hintStyle: const TextStyle(color: Color(0xFFA0A0A0)),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFFE6E6E6)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFFE6E6E6)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: primaryNavy),
      ),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryNavy,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    ),

    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: primaryNavy,
        side: const BorderSide(color: primaryNavy),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    ),

    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: primaryNavy,
      selectedItemColor: Colors.white,
      unselectedItemColor: Color(0xFFB8C4D6),
      type: BottomNavigationBarType.fixed,
    ),

    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: primaryNavy,
      foregroundColor: Colors.white,
    ),

    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected)
            ? primaryNavy
            : Colors.grey.shade400,
      ),
      trackColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected)
            ? primaryNavy.withOpacity(0.5)
            : Colors.grey.shade300,
      ),
    ),

    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Color(0xFF1E1E1E)),
      bodyMedium: TextStyle(color: Color(0xFF4A4A4A)),
      titleLarge: TextStyle(color: Color(0xFF1E1E1E), fontWeight: FontWeight.bold),
      titleMedium: TextStyle(color: Color(0xFF1E1E1E), fontWeight: FontWeight.w600),
    ),

    iconTheme: const IconThemeData(color: primaryNavy),

    dialogTheme: DialogThemeData(
      backgroundColor: Colors.white,
      titleTextStyle: const TextStyle(
        color: Color(0xFF1E1E1E),
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
      contentTextStyle: const TextStyle(color: Color(0xFF4A4A4A)),
    ),
  );
}