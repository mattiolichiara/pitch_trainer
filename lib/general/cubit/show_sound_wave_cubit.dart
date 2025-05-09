import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ShowSoundWaveCubit extends Cubit<bool> {
  ShowSoundWaveCubit() : super(true) {
    _loadInitialState();
  }

  Future<void> _loadInitialState() async {
    final prefs = await SharedPreferences.getInstance();
    emit(prefs.getBool('showWave') ?? true);
  }

  Future<void> toggleShowWave(bool isShowWave) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('showWave', isShowWave);
    emit(isShowWave);
  }
}