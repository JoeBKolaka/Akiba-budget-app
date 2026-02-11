import 'package:flutter/material.dart';

class AppTheme {
  static final ThemeData lightTheme = ThemeData(
    colorSchemeSeed: Color(0xFF00B9A6),
    appBarTheme: AppBarThemeData(
      backgroundColor: Colors.white,
      foregroundColor: Colors.white,
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: Colors.white,
    ),
    scaffoldBackgroundColor: Colors.white,
    useMaterial3: true,
    brightness: Brightness.light,
    cardTheme: CardThemeData(
      color: Colors.white,
      //surfaceTintColor: Colors.transparent,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(double.infinity, 50),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      ),
    ),
  );

  static final ThemeData darkTheme = ThemeData(
    colorSchemeSeed: Color(0xFF00C9B6),
    scaffoldBackgroundColor: Colors.black,
    useMaterial3: true,
    brightness: Brightness.dark,
    cardTheme: CardThemeData(
      color: Colors.black,
      //surfaceTintColor: Colors.transparent,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(double.infinity, 50),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      ),
    ),
  );
}
