import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:flutter_localizations/flutter_localizations.dart'; // ✅ Import this

import 'general/utils/theme_cubit.dart';
import 'sampling/view/sound_sampling.dart';

class MyApp extends StatefulWidget {
  final ThemeCubit themeCubit;
  final FlutterLocalization localization;

  const MyApp({super.key, required this.themeCubit, required this.localization});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    widget.localization.onTranslatedLanguage = _onTranslatedLanguage;
    super.initState();
  }

  void _onTranslatedLanguage(Locale? locale) {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: widget.themeCubit,
      child: BlocBuilder<ThemeCubit, ThemeData>(
        builder: (context, theme) {
          return MaterialApp(
            title: 'Pitch Trainer',
            theme: theme,
            supportedLocales: widget.localization.supportedLocales,
            localizationsDelegates: [
              ...widget.localization.localizationsDelegates,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
            ],
            locale: widget.localization.currentLocale,
            home: const SoundSampling(),
          );
        },
      ),
    );
  }
}
