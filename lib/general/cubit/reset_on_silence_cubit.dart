import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ResetOnSilenceCubit extends Cubit<bool> {
  ResetOnSilenceCubit() : super(true) {
    _loadInitialState();
  }

  Future<void> _loadInitialState() async {
    final prefs = await SharedPreferences.getInstance();
    emit(prefs.getBool('isResetOnSilence') ?? true);
  }

  Future<void> toggleSilenceReset(bool isResetOnSilence) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isResetOnSilence', isResetOnSilence);
    emit(isResetOnSilence);
  }
}