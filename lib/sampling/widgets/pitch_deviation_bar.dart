import 'dart:ffi';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:linear_progress_bar/linear_progress_bar.dart';

class PitchDeviationBar extends StatelessWidget {
  const PitchDeviationBar({
    super.key,
    required this.currentValue,
    required this.pitchDeviationAnimation,
  });

  final int currentValue;
  final Animation<double>? pitchDeviationAnimation;

  Widget _barSection(progress, td, size, rotation) {
    return Expanded(
      child: Transform(
        alignment: Alignment.center,
        transform: Matrix4.rotationY(rotation),
        child: LinearProgressBar(
          maxSteps: 50,
          progressType: LinearProgressBar.progressTypeLinear,
          currentStep: progress.toInt(),
          progressColor: td.colorScheme.primary,
          backgroundColor: td.colorScheme.onSurfaceVariant,
          valueColor: AlwaysStoppedAnimation<Color>(td.colorScheme.primary),
          minHeight: size.height * 0.004,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(10),
            bottomLeft: Radius.circular(10),
          ),
        ),
      ),
    );
  }

  Widget _pitchDeviationLinearBar(size, int currentValue, ThemeData td) {
    final animatedValue = pitchDeviationAnimation?.value ?? currentValue.toDouble();
    final clampedValue = animatedValue.clamp(-50, 50);
    final positiveProgress = clampedValue > 0 ? clampedValue.abs() : 0;
    final negativeProgress = clampedValue < 0 ? clampedValue.abs() : 0;
    final style = TextStyle(color: td.colorScheme.onSurface, fontWeight: FontWeight.w100, fontSize: 12);
    final accuracyTick = Container(
      width: 1,
      height: size.height * 0.007,
      color: td.colorScheme.primary,
    );

    final tickRow = Center(
      child: SizedBox(
        width: size.width*0.45,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(5, (_) => accuracyTick),
        ),
      ),
    );

    Widget bar = Center(
      child: SizedBox(
        width: size.width*0.45,
        child: Row(
          children: [
            _barSection(negativeProgress, td, size, math.pi),
            _barSection(positiveProgress, td, size, 0.0),
          ],
        ),
      ),
    );

    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            bar,
            tickRow,
          ],
        ),
        SizedBox(
          width: size.width*0.50,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("-50", style: style,),
              Text("-25", style: style,),
              Center(child: Text("0", style: style,),),
              Text("+25", style: style,),
              Text("+50", style: style,),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return _pitchDeviationLinearBar(MediaQuery.of(context).size, currentValue, Theme.of(context));
  }

}