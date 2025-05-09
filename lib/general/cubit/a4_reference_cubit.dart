import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pitch_trainer/sampling/utils/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class A4ReferenceCubit extends Cubit<double> {
  A4ReferenceCubit() : super(Constants.defaultA4Reference) {
    _loadInitialState();
  }

  Future<void> _loadInitialState() async {
    final prefs = await SharedPreferences.getInstance();
    emit(prefs.getDouble('a4Reference') ?? Constants.defaultA4Reference);
  }

  Future<void> updateA4Reference(double a4Reference) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('a4Reference', a4Reference);
    emit(a4Reference);
  }
}