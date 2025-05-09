import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:pitch_trainer/general/cubit/reset_cubit.dart';
import 'package:pitch_trainer/general/utils/languages.dart';

import '../../../general/cubit/a4_reference_cubit.dart';
import '../../../general/widgets/ui_utils.dart';
import '../ValueSlider.dart';

class A4ReferenceSettings extends StatefulWidget {
  const A4ReferenceSettings({super.key});

  @override
  State<A4ReferenceSettings> createState() => _A4ReferenceSettings();
}

class _A4ReferenceSettings extends State<A4ReferenceSettings> {

  Widget _a4ReferenceTitle(Size size, ThemeData td) {
    return SizedBox(
      width: size.width*0.8,
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          Languages.a4Reference.getString(context),
          style: TextStyle(color: td.colorScheme.onSurface, fontWeight: FontWeight.w800, fontSize: 18, shadows: [UiUtils.widgetsShadow(80, 20, td),]),
        ),
      ),
    );
  }

  Widget _a4ReferenceSlider(Size size, ThemeData td) {
    int min = 432;

    return BlocBuilder<A4ReferenceCubit, double>(
        builder: (context, a4Reference) {
          return BlocBuilder<ResetCubit, ResetState>(
              builder: (context, key) {
                return SizedBox(
                  key: key.key,
                  width: size.width * 0.9,
                  child: ValueSlider(
                    selectedValue: (context.read<A4ReferenceCubit>().state).toInt(),
                    boxWidth: size.width * 0.15,
                    boxHeight: size.height * 0.04,
                    activeColor: td.colorScheme.secondary,
                    inactiveColor: Colors.white30,
                    max: 448,
                    min: min,
                    boxShadow: [UiUtils.widgetsShadow(10, 90, td)],
                    boxColor: Color.lerp(td.colorScheme.primary, td.colorScheme.onSurfaceVariant, 0.2)!,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    textColor: Color.lerp(td.colorScheme.primary, Colors.white, 0.6)!,
                    ticksHeight: size.height*0.06,
                    ticksWidth: size.width*0.01,
                    ticksMargin: size.width*0.012,
                    boxBorderColor: td.colorScheme.primary,
                    onChanged: (newValue) {
                      BlocProvider.of<A4ReferenceCubit>(context).updateA4Reference(newValue.toDouble());
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
        _a4ReferenceTitle(size, td),
        SizedBox(height: size.height * 0.03),
        _a4ReferenceSlider(size, td),
        SizedBox(height: size.height * 0.03),
      ],
    );
  }
}
