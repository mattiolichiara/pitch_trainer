import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppThemeMode {purple, green, blue, red, pink, yellow, orange}

class ThemeCubit extends Cubit<ThemeData> {
  ThemeCubit() : super(_themes[AppThemeMode.purple]!);

  static final Map<AppThemeMode, ThemeData> _themes = {
    AppThemeMode.purple: ThemeData(
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: Colors.purple,
        secondary: Colors.blueAccent,
        surface: Colors.grey,
        onPrimary: Colors.black,
        onSecondary: Colors.white,
        onSurface: Colors.black,
      ),
    ),
    AppThemeMode.green: ThemeData(
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: Colors.green,
        secondary: Colors.deepPurple,
        surface: Colors.grey,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: Colors.white,
      ),
    ),
    AppThemeMode.blue: ThemeData(
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: Colors.blue,
        secondary: Colors.blueAccent,
        surface: Colors.white,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: Colors.black,
      ),
    ),
    AppThemeMode.red: ThemeData(
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: Colors.red,
        secondary: Colors.lightGreen,
        surface: Colors.white,
        onPrimary: Colors.white,
        onSecondary: Colors.black,
        onSurface: Colors.black,
      ),
    ),
    AppThemeMode.pink: ThemeData(
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: Colors.pink,
        secondary: Colors.redAccent,
        surface: Colors.white,
        onPrimary: Colors.white,
        onSecondary: Colors.black,
        onSurface: Colors.black,
      ),
    ),
    AppThemeMode.yellow: ThemeData(
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: Colors.yellow,
        secondary: Colors.pinkAccent,
        surface: Colors.white,
        onPrimary: Colors.white,
        onSecondary: Colors.black,
        onSurface: Colors.black,
      ),
    ),
    AppThemeMode.orange: ThemeData(
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: Colors.orange,
        secondary: Colors.pinkAccent,
        surface: Colors.white,
        onPrimary: Colors.white,
        onSecondary: Colors.black,
        onSurface: Colors.black,
      ),
    ),
  };

  Future<void> loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    int theme = prefs.getInt('theme') ?? 0;
    AppThemeMode selectedTheme = AppThemeMode.values[theme];
    emit(_themes[selectedTheme]!);
  }

  Future<void> changeTheme(AppThemeMode theme) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('theme', theme.index);
    emit(_themes[theme]!);
  }

  Map<AppThemeMode, ThemeData> get availableThemes => _themes;
}
