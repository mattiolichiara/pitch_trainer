import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CanResetCubit extends Cubit<bool> {
  CanResetCubit() : super(false) {
    _loadInitialState();
  }

  Future<void> _loadInitialState() async {
    final prefs = await SharedPreferences.getInstance();
    emit(prefs.getBool('canReset') ?? false);
  }

  Future<void> toggleReset(bool canReset) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('canReset', canReset);
    emit(canReset);
  }
}