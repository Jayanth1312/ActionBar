import 'package:flutter/material.dart';

class AppTheme extends ChangeNotifier {
  late bool _isDarkMode;

  AppTheme() {
    _isDarkMode = ThemeMode.system == ThemeMode.dark;
  }

  bool get isDarkMode => _isDarkMode;

  ThemeData get currentTheme => _isDarkMode ? darkTheme : lightTheme;

  ThemeData get lightTheme => ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          titleTextStyle: TextStyle(color: Colors.black, fontSize: 20),
          elevation: 0,
        ),
        inputDecorationTheme: InputDecorationTheme(
          fillColor: Colors.grey[200],
          hintStyle: TextStyle(color: Colors.grey[500]),
        ),
        textTheme: const TextTheme(
          bodyMedium: TextStyle(color: Colors.black),
        ),
      );

  // Dark theme
  ThemeData get darkTheme => ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF121212),
        appBarTheme: const AppBarTheme(
          titleTextStyle: TextStyle(color: Colors.white, fontSize: 20),
          elevation: 0,
        ),
        inputDecorationTheme: InputDecorationTheme(
          fillColor: const Color(0xFF262626),
          hintStyle: const TextStyle(color: Color(0xFFD4D4D4)),
        ),
        textTheme: const TextTheme(
          bodyMedium: TextStyle(color: Colors.white),
        ),
      );
}
