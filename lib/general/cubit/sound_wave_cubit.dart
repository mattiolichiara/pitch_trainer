import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SoundWaveCubit extends Cubit<bool> {
  SoundWaveCubit() : super(false) {
    _loadInitialState();
  }

  Future<void> _loadInitialState() async {
    final prefs = await SharedPreferences.getInstance();
    emit(prefs.getBool('isRawWave') ?? false);
  }

  Future<void> toggleWaveType(bool isRawWave) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isRawWave', isRawWave);
    emit(isRawWave);
  }
}