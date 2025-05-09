import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pitch_trainer/general/cubit/a4_reference_cubit.dart';
import 'package:pitch_trainer/general/cubit/reset_cubit.dart';
import 'package:pitch_trainer/general/cubit/tolerance_cubit.dart';
import 'package:pitch_trainer/general/utils/languages.dart';
import 'package:pitch_trainer/general/utils/warning_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../general/cubit/precision_cubit.dart';
import '../../../general/cubit/reset_on_silence_cubit.dart';
import '../../../general/cubit/show_sound_wave_cubit.dart';
import '../../../general/cubit/sound_wave_cubit.dart';
import '../../../general/cubit/theme_cubit.dart';
import '../../../general/widgets/ui_utils.dart';
import '../../../sampling/utils/constants.dart';
import '../../../sampling/widgets/instrument_card.dart';
import '../../view/advanced_settings.dart';

class OtherSettings extends StatefulWidget {
  const OtherSettings({super.key});

  @override
  State<OtherSettings> createState() => _OtherSettings();
}

class _OtherSettings extends State<OtherSettings> {

  Widget _otherSettingsTitle(Size size, ThemeData td) {
    return SizedBox(
      width: size.width*0.8,
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          Languages.other.getString(context),
          style: TextStyle(color: td.colorScheme.onSurface, fontWeight: FontWeight.w800, fontSize: 18, shadows: [UiUtils.widgetsShadow(80, 20, td),]),
        ),
      ),
    );
  }

  void _onPressedAdvancedSettings() {
    Navigator.of(context).push(MaterialPageRoute(builder: (context) => const AdvancedSettings()));
  }

  Widget _advancedSettingsButton(Size size, td) {
    return SizedBox(
      width: size.width*0.9,
      child: Column(
        children: [
          _otherSettingsTitle(size, td),
          SizedBox(height: size.height*0.03,),
          InstrumentCard(
              onPressed: _onPressedAdvancedSettings,
              text: Languages.advancedSettings.getString(context),
              leadingIcon: "assets/icons/wrenches-wrench-svgrepo-com.svg",
              iconSize: size.width*0.05,
              subText: Languages.advancedSettingsSubText.getString(context)),
        ],
      ),
    );
  }

  void _showDialog() {
    showDialog(
      context: context,
      builder: (context) => WarningDialog(
        title: Languages.resetWarning.getString(context),
        subtitle: Languages.resetWarningSubText.getString(context),
        onYesPressed: () {
          Navigator.pop(context);
          _onPressedResetSettings();
        },
        onNoPressed: () {
          Navigator.pop(context);
        },
      ),
    );
  }

  void _triggerReload() {
    if(context.read<PrecisionCubit>().state != Constants.defaultPrecision || context.read<ToleranceCubit>().state != Constants.defaultTolerance || context.read<A4ReferenceCubit>().state != Constants.defaultA4Reference) {
      BlocProvider.of<ResetCubit>(context).triggerRebuild();
    }
  }

  void _triggerToast() {
    Fluttertoast.showToast(msg: Languages.settingsResetToast.getString(context));
  }

  void _setToleranceState() async {
    BlocProvider.of<ToleranceCubit>(context).updateTolerance(Constants.defaultTolerance);
  }

  void _setPrecisionState() async {
    if(context.read<PrecisionCubit>().state != Constants.defaultPrecision) {
      BlocProvider.of<PrecisionCubit>(context).updatePrecision(Constants.defaultPrecision);
    }
  }

  void _setA4ReferenceState() async {
    if(context.read<A4ReferenceCubit>().state != Constants.defaultA4Reference) {
      BlocProvider.of<A4ReferenceCubit>(context).updateA4Reference(Constants.defaultA4Reference);
    }
  }

  void _setGeneralSettingsState() async {
      BlocProvider.of<SoundWaveCubit>(context).toggleWaveType(true);
      BlocProvider.of<ShowSoundWaveCubit>(context).toggleShowWave(true);
      BlocProvider.of<ResetOnSilenceCubit>(context).toggleSilenceReset(true);
  }

  void _onPressedResetSettings() async {

    ThemeCubit themeCubit = BlocProvider.of<ThemeCubit>(context);
    SharedPreferences sp = await SharedPreferences.getInstance();
    _setToleranceState();
    _setGeneralSettingsState();
    _setPrecisionState();
    _setA4ReferenceState();
    _triggerReload();

    sp.setDouble('minFrequency', Constants.defaultMinFrequency);
    sp.setDouble('maxFrequency', Constants.defaultMaxFrequency);
    sp.setBool('isNotCustom', Constants.defaultIsNotCustom);
    sp.setString('instrumentIcon', Constants.defaultInstrumentIcon);

    await sp.setInt('theme', 0);
    themeCubit.changeTheme(AppThemeMode.purple);
    // debugPrint("Theme: ${sp.getInt('theme')}");
    //
    // await sp.setInt('sampleRate', Constants.defaultSampleRate);
    // debugPrint("SampleRate: ${sp.getInt('sampleRate')}");
    //
    // await sp.setInt('bufferSize', Constants.defaultBufferSize);
    // debugPrint("bufferSize: ${sp.getInt('bufferSize')}");
    //
    // debugPrint("precision: ${sp.getInt('precision')}");
    // debugPrint("tolerance: ${sp.getInt('tolerance')}");
    // debugPrint("isCleanWave: ${sp.getBool('isCleanWave')}");

    _triggerToast();
  }

  Widget _resetSettingsButton(Size size, td) {
    return SizedBox(
      width: size.width*0.9,
      child: Column(
        children: [
          SizedBox(height: size.height*0.03,),
          InstrumentCard(
              onPressed: _showDialog,
              text: Languages.resetSettings.getString(context),
              leadingIcon: "assets/icons/reset-alt-svgrepo-com.svg",
              iconSize: size.width*0.05,
              subText: Languages.resetSettingsSubText.getString(context)),
        ],
      ),
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
        _advancedSettingsButton(size, td),
        _resetSettingsButton(size, td),
        SizedBox(height: size.height * 0.05),
      ],
    );
  }
}
