import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CanScrollCubit extends Cubit<bool> {
  CanScrollCubit() : super(false) {
    _loadInitialState();
  }

  Future<void> _loadInitialState() async {
    final prefs = await SharedPreferences.getInstance();
    emit(prefs.getBool('canScroll') ?? false);
  }

  Future<void> updateScroll(bool canScroll) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('canScroll', canScroll);
    emit(canScroll);
  }
}