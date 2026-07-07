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
      titleTextStyle: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
    ),
    cardColor: Colors.white,
    dividerColor: const Color(0xFFE6E6E6),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      hintStyle: const TextStyle(color: Color(0xFFA0A0A0)),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE6E6E6))),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE6E6E6))),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: primaryNavy)),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryNavy,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: primaryNavy,
        side: const BorderSide(color: primaryNavy),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
        (states) => states.contains(WidgetState.selected) ? primaryNavy : Colors.grey.shade400,
      ),
      trackColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected) ? primaryNavy.withOpacity(0.5) : Colors.grey.shade300,
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
      titleTextStyle: const TextStyle(color: Color(0xFF1E1E1E), fontSize: 18, fontWeight: FontWeight.bold),
      contentTextStyle: const TextStyle(color: Color(0xFF4A4A4A)),
    ),
  );

  // ── DARK THEME: kebalikan dari light, warna sama, cuma peran ditukar ──
  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    useMaterial3: false,
    scaffoldBackgroundColor: primaryNavy, // dulu cream, sekarang navy
    primaryColor: creamBackground,
    colorScheme: const ColorScheme.dark(
      primary: creamBackground,
      secondary: creamBackground,
      surface: Color(0xFF123356), // navy sedikit lebih terang buat card
      error: Color(0xFFD9534F),
      onPrimary: primaryNavy,
      onSurface: creamBackground,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF123356),
      foregroundColor: creamBackground,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      iconTheme: IconThemeData(color: creamBackground),
      titleTextStyle: TextStyle(color: creamBackground, fontSize: 20, fontWeight: FontWeight.bold),
    ),
    cardColor: const Color(0xFF123356), // dulu putih, sekarang navy lebih terang
    dividerColor: const Color(0xFF2C4A6E),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFF123356),
      hintStyle: const TextStyle(color: Color(0xFF7C93B0)),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFF2C4A6E))),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFF2C4A6E))),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: creamBackground)),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: creamBackground,
        foregroundColor: primaryNavy,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: creamBackground,
        side: const BorderSide(color: creamBackground),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Color(0xFF123356),
      selectedItemColor: creamBackground,
      unselectedItemColor: Color(0xFF7C93B0),
      type: BottomNavigationBarType.fixed,
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: creamBackground,
      foregroundColor: primaryNavy,
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected) ? creamBackground : Colors.grey.shade600,
      ),
      trackColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected) ? creamBackground.withOpacity(0.5) : Colors.grey.shade800,
      ),
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: creamBackground),
      bodyMedium: TextStyle(color: Color(0xFFD8D3C4)),
      titleLarge: TextStyle(color: creamBackground, fontWeight: FontWeight.bold),
      titleMedium: TextStyle(color: creamBackground, fontWeight: FontWeight.w600),
    ),
    iconTheme: const IconThemeData(color: creamBackground),
    dialogTheme: DialogThemeData(
      backgroundColor: const Color(0xFF123356),
      titleTextStyle: const TextStyle(color: creamBackground, fontSize: 18, fontWeight: FontWeight.bold),
      contentTextStyle: const TextStyle(color: Color(0xFFD8D3C4)),
    ),
  );
}