import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pitch_trainer/sampling/utils/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ToleranceCubit extends Cubit<int> {
  ToleranceCubit() : super(Constants.defaultTolerance) {
    _loadInitialState();
  }

  Future<void> _loadInitialState() async {
    final prefs = await SharedPreferences.getInstance();
    emit(prefs.getInt('tolerance') ?? Constants.defaultTolerance);
  }

  Future<void> updateTolerance(int tolerance) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('tolerance', tolerance);
    emit(tolerance);
  }
}