import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:pitch_trainer/general/cubit/can_reset_cubit.dart';
import 'package:pitch_trainer/general/utils/languages.dart';

import '../../../general/cubit/scroll_position_precision.dart';
import '../../../general/cubit/precision_cubit.dart';
import '../../../general/widgets/ui_utils.dart';
import '../../../sampling/utils/constants.dart';
import '../ValueSlider.dart';

class PrecisionSettings extends StatefulWidget {
  const PrecisionSettings({super.key});

  @override
  State<PrecisionSettings> createState() => _PrecisionSettings();
}

class _PrecisionSettings extends State<PrecisionSettings> {

  Widget _precisionTitle(Size size, ThemeData td) {
    return SizedBox(
      width: size.width*0.8,
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          Languages.precision.getString(context),
          style: TextStyle(color: td.colorScheme.onSurface, fontWeight: FontWeight.w800, fontSize: 18, shadows: [UiUtils.widgetsShadow(80, 20, td),]),
        ),
      ),
    );
  }

  Widget _precisionSlider(Size size, ThemeData td) {
    return BlocBuilder<PrecisionCubit, int>(
      builder: (context, precision) {
        return BlocBuilder<ScrollPositionPrecision, double>(
          builder: (context, scrollPosition) {
          return SizedBox(
            width: size.width * 0.9,
            child: ValueSlider(
              selectedValue: (context.read<PrecisionCubit>().state),
              boxWidth: size.width * 0.15,
              boxHeight: size.height * 0.04,
              activeColor: td.colorScheme.secondary,
              inactiveColor: Colors.white30,
              max: 100,
              min: 0,
              boxShadow: [UiUtils.widgetsShadow(10, 90, td)],
              boxColor: Color.lerp(td.colorScheme.primary, td.colorScheme.onSurfaceVariant, 0.2)!,
              fontSize: 18,
              fontWeight: FontWeight.w900,
              textColor: Color.lerp(td.colorScheme.primary, Colors.white, 0.6)!,
              ticksHeight: size.height*0.06,
              ticksWidth: size.width*0.01,
              ticksMargin: size.width*0.012,
              boxBorderColor: td.colorScheme.primary,
              canReset: BlocProvider.of<CanResetCubit>(context).state,
              onChanged: (newValue) {
                BlocProvider.of<PrecisionCubit>(context).updatePrecision(newValue);
                debugPrint("Current Value PRECISION: ${(context.read<PrecisionCubit>().state)}");
              },
              initialPosition: context.read<ScrollPositionPrecision>().state,
              onScrollPositionChanged: (double value) {
                debugPrint("Current Pos PRECISION: $value, Current Value: ${(context.read<PrecisionCubit>().state)}");
                BlocProvider.of<ScrollPositionPrecision>(context).updateScrollPositionPrecision(value);
              },
            ),
          );
        });
      });
  }

  //BUILD
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    ThemeData td = Theme.of(context);

    return Column(
      children: [
        SizedBox(height: size.height * 0.03),
        _precisionTitle(size, td),
        SizedBox(height: size.height * 0.03),
        _precisionSlider(size, td),
        SizedBox(height: size.height * 0.03),
      ],
    );
  }
}
