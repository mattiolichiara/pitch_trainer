import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppThemeMode {purple, green, blue, red, pink, yellow, orange}

class ThemeCubit extends Cubit<ThemeData> {
  ThemeCubit() : super(_themes[AppThemeMode.purple]!);

  static const Color purple = Color(0xFFAA60C8);
  static const Color blue = Color(0xFF15DAE7);
  static const Color green = Color(0xB81EC771);
  static const Color red = Color(0xFFE52020);
  static const Color pink = Color(0xFFDA0C81);
  static const Color orange = Color(0xFFFF7F3E);
  static const Color yellow = Color(0xFFFFF574);

  static final Map<AppThemeMode, ThemeData> _themes = {
    AppThemeMode.purple: ThemeData(
      // textTheme: ThemeData.dark().textTheme.apply(
      //     fontFamily: 'Urbanist'
      // ),
      fontFamily: 'Urbanist',
      brightness: Brightness.dark,
      colorScheme: ColorScheme.dark(
        primary: purple,
        secondary: Color.lerp(purple, Colors.white, 0.35)!,
        surface: Color(0xFF1B1B1B),
        onSurfaceVariant: Color.lerp(const Color(0xFF252428), Colors.white, 0.20)!,
        onSurface: Colors.white,
      ),
    ),
    AppThemeMode.green: ThemeData(
      fontFamily: 'Urbanist',
      brightness: Brightness.dark,
      colorScheme: ColorScheme.dark(
        primary: green,
        secondary: Color.lerp(green, Colors.white, 0.35)!,
        surface: Color(0xFF1B1B1B),
        onSurfaceVariant: Color.lerp(const Color(0xFF252428), Colors.white, 0.20)!,
        onSurface: Colors.white,
      ),
    ),
    AppThemeMode.blue: ThemeData(
      fontFamily: 'Urbanist',
      brightness: Brightness.dark,
      colorScheme: ColorScheme.dark(
        primary: blue,
        secondary: Color.lerp(blue, Colors.white, 0.35)!,
        surface: Color(0xFF1B1B1B),
        onSurfaceVariant: Color.lerp(const Color(0xFF252428), Colors.white, 0.20)!,
        onSurface: Colors.white,
      ),
    ),
    AppThemeMode.pink: ThemeData(
      fontFamily: 'Urbanist',
      brightness: Brightness.dark,
      colorScheme: ColorScheme.dark(
        primary: pink,
        secondary: Color.lerp(pink, Colors.white, 0.35)!,
        surface: Color(0xFF1B1B1B),
        onSurfaceVariant: Color.lerp(const Color(0xFF252428), Colors.white, 0.20)!,
        onSurface: Colors.white,
      ),
    ),
    AppThemeMode.yellow: ThemeData(
      fontFamily: 'Urbanist',
      brightness: Brightness.dark,
      colorScheme: ColorScheme.dark(
        primary: yellow,
        secondary: Color.lerp(yellow, Colors.white, 0.35)!,
        surface: Color(0xFF1B1B1B),
        onSurfaceVariant: Color.lerp(const Color(0xFF252428), Colors.white, 0.20)!,
        onSurface: Colors.white,
      ),
    ),
    AppThemeMode.red: ThemeData(
      fontFamily: 'Urbanist',
      brightness: Brightness.dark,
      colorScheme: ColorScheme.dark(
        primary: red,
        secondary: Color.lerp(red, Colors.white, 0.35)!,
        surface: Color(0xFF1B1B1B),
        onSurfaceVariant: Color.lerp(const Color(0xFF252428), Colors.white, 0.20)!,
        onSurface: Colors.white,
      ),
    ),
    AppThemeMode.orange: ThemeData(
      fontFamily: 'Urbanist',
      brightness: Brightness.dark,
      colorScheme: ColorScheme.dark(
        primary: orange,
        secondary: Color.lerp(orange, Colors.white, 0.35)!,
        surface: Color(0xFF1B1B1B),
        onSurfaceVariant: Color.lerp(const Color(0xFF252428), Colors.white, 0.20)!,
        onSurface: Colors.white,
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

