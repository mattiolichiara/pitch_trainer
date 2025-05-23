import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localization/flutter_localization.dart';

import '../../../general/cubit/reset_cubit.dart';
import '../../../general/cubit/tolerance_cubit.dart';
import '../../../general/utils/languages.dart';
import '../../../general/widgets/ui_utils.dart';
import '../ValueSlider.dart';

class ToleranceSettings extends StatefulWidget {
  const ToleranceSettings({super.key});

  @override
  State<ToleranceSettings> createState() => _ToleranceSettings();
}

class _ToleranceSettings extends State<ToleranceSettings> {

  Widget _toleranceTitle(Size size, ThemeData td) {
    return SizedBox(
      width: size.width*0.8,
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          Languages.tolerance.getString(context),
          style: TextStyle(color: td.colorScheme.onSurface, fontWeight: FontWeight.w800, fontSize: 18, shadows: [UiUtils.widgetsShadow(80, 20, td),]),
        ),
      ),
    );
  }

  Widget _toleranceSlider(Size size, ThemeData td) {
    int min = 10;
    return BlocBuilder<ToleranceCubit, int>(
      builder: (context, tolerance) {
        return BlocBuilder<ResetCubit, ResetState>(
            builder: (context, key) {
              return SizedBox(
                width: size.width * 0.9,
                child: ValueSlider(
                  key: key.key,
                  selectedValue: context
                      .read<ToleranceCubit>()
                      .state,
                  boxWidth: size.width * 0.15,
                  boxHeight: size.height * 0.04,
                  activeColor: td.colorScheme.secondary,
                  inactiveColor: Colors.white30,
                  max: 50,
                  min: min,
                  boxShadow: [UiUtils.widgetsShadow(10, 90, td)],
                  boxColor: Color.lerp(
                      td.colorScheme.primary, td.colorScheme.onSurfaceVariant,
                      0.2)!,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  textColor: Color.lerp(
                      td.colorScheme.primary, Colors.white, 0.6)!,
                  ticksHeight: size.height * 0.06,
                  ticksWidth: size.width * 0.01,
                  ticksMargin: size.width * 0.012,
                  boxBorderColor: td.colorScheme.primary,
                  onChanged: (newValue) {
                    BlocProvider.of<ToleranceCubit>(context).updateTolerance(
                        newValue);
                  },
                ),
              );
            });
      },
    );
  }

  //BUILD
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    ThemeData td = Theme.of(context);

    return Column(
      children: [
        _toleranceTitle(size, td),
        SizedBox(height: size.height * 0.03),
        _toleranceSlider(size, td),
        SizedBox(height: size.height * 0.03),
      ],
    );
  }
}

