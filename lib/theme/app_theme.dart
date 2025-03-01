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

  // Define dark theme
  ThemeData get darkTheme => ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF1E1E1E),
        appBarTheme: const AppBarTheme(
          titleTextStyle: TextStyle(color: Colors.white, fontSize: 20),
          elevation: 0,
        ),
        inputDecorationTheme: InputDecorationTheme(
          fillColor: Colors.grey[850],
          hintStyle: const TextStyle(color: Colors.grey),
        ),
        textTheme: const TextTheme(
          bodyMedium: TextStyle(color: Colors.white),
        ),
      );
}
