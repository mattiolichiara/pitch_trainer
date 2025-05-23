import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pitch_trainer/sampling/utils/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PrecisionCubit extends Cubit<int> {
  PrecisionCubit() : super(Constants.defaultPrecision) {
    _loadInitialState();
  }

  Future<void> _loadInitialState() async {
    final prefs = await SharedPreferences.getInstance();
    emit(prefs.getInt('tolerance') ?? Constants.defaultPrecision);
  }

  Future<void> updatePrecision(int precision) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('precision', precision);
    emit(precision);
  }
}