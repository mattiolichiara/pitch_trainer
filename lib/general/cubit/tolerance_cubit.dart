import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pitch_trainer/sampling/utils/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ToleranceCubit extends Cubit<double> {
  ToleranceCubit() : super(Constants.defaultTolerance) {
    _loadInitialState();
  }

  Future<void> _loadInitialState() async {
    final prefs = await SharedPreferences.getInstance();
    emit(prefs.getDouble('tolerance') ?? Constants.defaultTolerance);
  }

  Future<void> updateTolerance(double tolerance) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('tolerance', tolerance);
    emit(tolerance);
  }
}