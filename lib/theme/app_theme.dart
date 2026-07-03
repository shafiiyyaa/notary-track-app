import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: const Color(0xffF6F3E8),
    primaryColor: const Color(0xff6A99C8),

    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xffEFEAF3),
      foregroundColor: Colors.black,
      elevation: 0,
    ),

    cardColor: Colors.white,
  );

  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,

    scaffoldBackgroundColor: const Color(0xFF113C67),

    primaryColor: const Color(0xffF6F3E8),

    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF113C67),
      foregroundColor: Colors.white,
      elevation: 0,
    ),

    cardColor: const Color(0xff222222),
  );
}