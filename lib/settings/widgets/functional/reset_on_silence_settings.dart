import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:pitch_trainer/general/utils/languages.dart';

import '../../../general/cubit/reset_on_silence_cubit.dart';
import '../../../general/widgets/ui_utils.dart';

class ResetOnSlienceSettings extends StatefulWidget {
  const ResetOnSlienceSettings({super.key,});

  @override
  State<ResetOnSlienceSettings> createState() => _ResetOnSilenceSettings();
}

class _ResetOnSilenceSettings extends State<ResetOnSlienceSettings> {

  @override
  void initState() {
    WidgetsFlutterBinding.ensureInitialized();
    super.initState();
  }

  //RESET ON SILENCE VIEW
  //STYLE
  Widget _resetOnSilenceTitle(size, td) {
    return SizedBox(
      width: size.width*0.4,
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          Languages.resetOnSilence.getString(context),
          style: TextStyle(color: td.colorScheme.onSurface, fontWeight: FontWeight.w800, fontSize: 18, shadows: [UiUtils.widgetsShadow(80, 20, td),]),
        ),
      ),
    );
  }

  Widget _resetOnSilenceTypeText(String text, ThemeData td) {
    return Text(
      text,
      style: TextStyle(
        color: Colors.white,
        fontSize: 13,
        shadows: [UiUtils.widgetsShadow(80, 20, td),],
        fontWeight: FontWeight.w100,
      ),
    );
  }

  // Widget _switchResetOnSilenceWrapper(String dynamicText, ThemeData td, String staticText, Size size) {
  //   return SizedBox(
  //     width: size.width,
  //     child: Center(
  //       child: Row(
  //         mainAxisAlignment: MainAxisAlignment.center,
  //         crossAxisAlignment: CrossAxisAlignment.center,
  //         children: [
  //           _resetOnSilenceTypeText(staticText, td),
  //           _switchResetOnSilence(size, td),
  //           _resetOnSilenceTypeText(dynamicText, td),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  Widget _resetOnSilenceSection(size, td) {
    return Center(
      child: SizedBox(
        width: size.width*0.8,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _resetOnSilenceTitle(size, td),
            _switchResetOnSilence(size, td),
          ],
        )
      ),
    );
  }

  //WIDGETS
  Widget _switchResetOnSilence(Size size, ThemeData td) {
    return BlocBuilder<ResetOnSilenceCubit, bool>(
      builder: (context, isRawResetOnSilence) {
        return SizedBox(
          height: size.height*0.04,
          width: size.width*0.4,
          child: Switch(
            value: isRawResetOnSilence,
            onChanged: (value) {
              context.read<ResetOnSilenceCubit>().toggleSilenceReset(value);
            },
            inactiveTrackColor: td.colorScheme.onPrimaryContainer,
            inactiveThumbColor: td.colorScheme.primary,
            activeColor: td.colorScheme.onPrimaryContainer,
            activeTrackColor: td.colorScheme.primary,
            trackOutlineColor: WidgetStateProperty.all(td.colorScheme.primary),
          ),
        );
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
        SizedBox(height: size.height * 0.03),
        _resetOnSilenceSection(size, td),
        SizedBox(height: size.height * 0.03),
      ],
    );
  }
}

