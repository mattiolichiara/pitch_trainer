import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:pitch_trainer/general/utils/languages.dart';
import 'package:pitch_trainer/settings/utils/accuracy_settings.dart';
import 'package:pitch_trainer/settings/utils/language_setting.dart';
import 'package:pitch_trainer/settings/utils/rates_settings.dart';
import 'package:pitch_trainer/settings/utils/sound_wave_settings.dart';
import 'package:pitch_trainer/settings/utils/theme_settings.dart';
import '../../general/widgets/home_app_bar.dart';
import '../../sampling/utils/recorder.dart';
import '../../general/utils/theme_cubit.dart';
import '../../general/widgets/ui_utils.dart';

class Settings extends StatefulWidget {
  const Settings({super.key,});

  @override
  State<Settings> createState() => _Settings();
}

class _Settings extends State<Settings> {

  @override
  void initState() {
    WidgetsFlutterBinding.ensureInitialized();
    super.initState();
  }

  //BUILD
  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvoked: (pop) async {},
      child: Scaffold(
        appBar: HomeAppBar(
          title: 'Pitch Trainer - ${Languages.settings.getString(context)}',
          action1: Container(),
          action2: Container(),
          action3: Container(),
        ),
        body: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Column(
              children: [
                LanguageSettings(),
                RatesSettings(),
                AccuracySettings(),
                SoundWaveSettings(),
                ThemeSettings(),
              ],
            ),
          )
        ),
    );
  }
}

