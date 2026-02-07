import 'package:flutter/material.dart';

class AppTheme {
  static final ThemeData lightTheme = ThemeData(
    colorSchemeSeed: Color.fromRGBO(18, 97, 26, 1),
    appBarTheme: AppBarThemeData(backgroundColor: Colors.white),
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
  );

  static final ThemeData darkTheme = ThemeData(
    colorSchemeSeed: Color.fromRGBO(18, 97, 26, 1),
    appBarTheme: AppBarThemeData(backgroundColor: Colors.black),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: Colors.black,
    ),
    scaffoldBackgroundColor: Colors.black,
    useMaterial3: true,
    brightness: Brightness.dark,
    cardTheme: CardThemeData(
      color: Colors.black,
      //surfaceTintColor: Colors.transparent,
    ),
  );
}
