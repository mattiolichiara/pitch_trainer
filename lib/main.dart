import 'package:flutter/material.dart';

import 'app.dart';
import 'general/utils/theme_cubit.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final themeCubit = ThemeCubit();
  await themeCubit.loadTheme();

  runApp(MyApp(themeCubit: themeCubit));
}



