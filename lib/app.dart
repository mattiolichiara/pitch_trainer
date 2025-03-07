import 'package:flutter/material.dart';
import 'package:pitch_trainer/sampling/sound_sampling.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
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
  }
}