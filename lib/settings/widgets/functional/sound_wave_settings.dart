import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:pitch_trainer/general/utils/languages.dart';

import '../../../general/cubit/show_sound_wave_cubit.dart';
import '../../../general/cubit/sound_wave_cubit.dart';
import '../../../general/widgets/ui_utils.dart';
import '../../../sampling/logic/utils.dart';

class SoundWaveSettings extends StatefulWidget {
  const SoundWaveSettings({super.key,});

  @override
  State<SoundWaveSettings> createState() => _SoundWaveSettings();
}

class _SoundWaveSettings extends State<SoundWaveSettings> {
  bool _isDisplayed = true;

  @override
  void initState() {
    WidgetsFlutterBinding.ensureInitialized();

    setState(() {
      _isDisplayed = context.read<ShowSoundWaveCubit>().state;
    });
    super.initState();
  }

  //WAVE VIEW
  //STYLE
  Widget _waveTitle(size, td) {
    return SizedBox(
      width: size.width*0.4,
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          Languages.soundWave.getString(context),
          style: TextStyle(color: td.colorScheme.onSurface, fontWeight: FontWeight.w800, fontSize: 18, shadows: [UiUtils.widgetsShadow(80, 20, td),]),
        ),
      ),
    );
  }

  Widget _waveTypeText(String text, ThemeData td) {
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

  Widget _switchWaveWrapper(String rawText, ThemeData td, String polishedText, Size size) {
    return SizedBox(
      width: size.width,
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _waveTypeText(rawText, td),
            _switchWave(size, td),
            _waveTypeText(polishedText, td),
          ],
        ),
      ),
    );
  }

  // Widget _hideWaveWrapper(String rawText, ThemeData td, String polishedText, Size size) {
  //   return SizedBox(
  //     width: size.width,
  //     child: Center(
  //       child: Row(
  //         mainAxisAlignment: MainAxisAlignment.center,
  //         crossAxisAlignment: CrossAxisAlignment.center,
  //         children: [
  //           _waveTypeText(rawText, td),
  //           _hideWave(size, td),
  //           _waveTypeText(polishedText, td),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  Widget _waveSection(size, td) {
    return Center(
      child: SizedBox(
        width: size.width*0.9,
        child: Column(
          children: [
            SizedBox(height: size.height*0.03,),
            _switchWaveWrapper(Languages.rawWave.getString(context), td, Languages.polishedWave.getString(context), size),
          ],
        ),
      ),
    );
  }

  Widget _hideWaveSection(size, td) {
    return Center(
      child: SizedBox(
        width: size.width*0.8,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _waveTitle(size, td),
            _hideWave(size, td),
          ],
        ),
      ),
    );
  }

  //WIDGETS
  Widget _switchWave(Size size, ThemeData td) {
    return BlocBuilder<SoundWaveCubit, bool>(
      builder: (context, isCleanWave) {
        return SizedBox(
          height: size.height*0.04,
          width: size.width*0.4,
          child: Switch(
            value: isCleanWave,
            onChanged: (value) {
              context.read<SoundWaveCubit>().toggleWaveType(value);
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

  Widget _hideWave(Size size, ThemeData td) {
    return BlocBuilder<ShowSoundWaveCubit, bool>(
      builder: (context, isShowWave) {
        return SizedBox(
          height: size.height*0.04,
          width: size.width*0.4,
          child: Switch(
            value: isShowWave,
            onChanged: (value) {
              context.read<ShowSoundWaveCubit>().toggleShowWave(value);
              setState(() {
                _isDisplayed = value;
              });
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

    return BlocListener<ShowSoundWaveCubit, bool>(
      listener: (context, state) {
        if (state != _isDisplayed) {
          setState(() {
            _isDisplayed = state;
          });
        }
      },
      child: Column(
        children: [
          SizedBox(height: size.height * 0.03),
          _hideWaveSection(size, td),
          SizedBox(height: size.height * 0.03),
          _isDisplayed
              ? SizedBox(
            width: size.width*0.8,
            child: Divider(
              height: 0.1,
              color: Colors.grey,
              thickness: 0.1,
            ),
          )
              : Container(),
          _isDisplayed ? _waveSection(size, td) : Container(),
          _isDisplayed ? SizedBox(height: size.height * 0.03) : Container(),
        ],
      ),
    );
  }
}

