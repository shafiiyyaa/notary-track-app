import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
      useMaterial3: false,

    scaffoldBackgroundColor: const Color(0xFFF6F3E8),

    primaryColor: const Color(0xFF5B8DB8),

    appBarTheme: const AppBarTheme(
    backgroundColor: Color(0xff113C67),
    foregroundColor: Colors.white,
    elevation: 0,
    surfaceTintColor: Colors.transparent,
  ),

    cardColor: Colors.white,

    dividerColor: const Color(0xFFE6E6E6),
  );

  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
      useMaterial3: false,

    scaffoldBackgroundColor: const Color(0xFF121212),

    primaryColor: const Color(0xFF7EB6E6),

    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF181818),
      foregroundColor: Colors.white,
      elevation: 0,
    ),

    cardColor: const Color(0xFF1E1E1E),

    dividerColor: const Color(0xFF303030),
  );
}