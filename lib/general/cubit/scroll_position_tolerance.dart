import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../sampling/utils/constants.dart';

class ScrollPositionTolerance extends Cubit<double> {
  ScrollPositionTolerance() : super(Constants.defaultScrollPositionTolerance) {
    _loadInitialState();
  }

  Future<void> _loadInitialState() async {
    final prefs = await SharedPreferences.getInstance();
    emit(prefs.getDouble('scrollPositionTolerance') ?? Constants.defaultScrollPositionTolerance);
  }

  Future<void> updateScrollPositionTolerance(double scrollPosition) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('scrollPositionTolerance', scrollPosition);
    emit(scrollPosition);
  }
}