import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../sampling/utils/constants.dart';

class ScrollPositionPrecision extends Cubit<double> {
  ScrollPositionPrecision() : super(Constants.defaultScrollPositionPrecision) {
    _loadInitialState();
  }

  Future<void> _loadInitialState() async {
    final prefs = await SharedPreferences.getInstance();
    emit(prefs.getDouble('scrollPositionPrecision') ?? Constants.defaultScrollPositionPrecision);
  }

  Future<void> updateScrollPositionPrecision(double scrollPosition) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('scrollPositionPrecision', scrollPosition);
    emit(scrollPosition);
  }
}