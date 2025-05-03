import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ResetCubit extends Cubit<ResetState> {
  ResetCubit() : super(ResetState(key: UniqueKey(), shouldReset: false));

  void triggerRebuild() {
    final newKey = UniqueKey();
    emit(ResetState(key: newKey, shouldReset: true));
  }

  void denyRebuild() {
    emit(ResetState(key: state.key, shouldReset: false));
  }

  UniqueKey get currentKey => state.key;
}

class ResetState {
  final UniqueKey key;
  final bool shouldReset;

  ResetState({required this.key, required this.shouldReset});
}

// import 'package:flutter/cupertino.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
//
// class ResetCubit extends Cubit<UniqueKey> {
//   ResetCubit() : super(UniqueKey()) {
//     triggerRebuild();
//   }
//
//   void triggerRebuild() {
//     emit(UniqueKey());
//   }
//
//   UniqueKey get currentKey => state;
// }


