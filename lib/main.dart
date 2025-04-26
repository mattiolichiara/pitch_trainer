import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';

import 'app.dart';
import 'general/cubit/sound_wave_cubit.dart';
import 'general/cubit/theme_cubit.dart';
import 'general/utils/languages.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final themeCubit = ThemeCubit();
  await themeCubit.loadTheme();

  final FlutterLocalization localization = FlutterLocalization.instance;
  await localization.ensureInitialized();

  localization.init(
    mapLocales: [
      const MapLocale('en', Languages.EN),
      const MapLocale('it', Languages.IT),
    ],
    initLanguageCode: 'en',
  );

  runApp(MyApp(themeCubit: themeCubit, localization: localization));
}
