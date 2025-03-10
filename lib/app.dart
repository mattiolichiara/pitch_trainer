import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pitch_trainer/sampling/view/sound_sampling.dart';

import 'general/utils/theme_cubit.dart';

class MyApp extends StatelessWidget {
  final ThemeCubit themeCubit;
  const MyApp({super.key, required this.themeCubit});

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: themeCubit,
      child: BlocBuilder<ThemeCubit, ThemeData>(
        builder: (context, theme) {
          return MaterialApp(
            title: 'Pitch Trainer',
            theme: ThemeData(
              scaffoldBackgroundColor: const Color(0xFF1B1B1B),
              focusColor: const Color(0xFF9168B6),
              colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF9168B6)),
              useMaterial3: true,
            ),
            home: const SoundSampling(),
          );
        },
      ),
    );
  }
}