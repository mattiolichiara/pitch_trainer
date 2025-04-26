import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SoundWaveCubit extends Cubit<bool> {
  SoundWaveCubit() : super(true) {
    _loadInitialState();
  }

  Future<void> _loadInitialState() async {
    final prefs = await SharedPreferences.getInstance();
    emit(prefs.getBool('isCleanWave') ?? true);
  }

  Future<void> toggleWaveType(bool isCleanWave) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isCleanWave', isCleanWave);
    emit(isCleanWave);
  }
}