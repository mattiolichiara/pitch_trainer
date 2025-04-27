import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pitch_trainer/general/utils/languages.dart';
import 'package:pitch_trainer/sampling/utils/constants.dart';
import 'package:pitch_trainer/sampling/widgets/instrument_card.dart';
import 'package:pitch_trainer/settings/widgets/functional/other_settings.dart';
import 'package:pitch_trainer/settings/widgets/functional/precision_settings.dart';
import 'package:pitch_trainer/settings/widgets/functional/sample_rate_settings.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../general/widgets/home_app_bar.dart';
import '../../general/widgets/ui_utils.dart';
import '../../sampling/view/sound_sampling.dart';
import '../widgets/ValueSlider.dart';
import '../widgets/functional/buffer_size_settings.dart';
import '../widgets/functional/language_setting.dart';
import '../widgets/functional/sound_wave_settings.dart';
import '../widgets/functional/theme_settings.dart';
import '../widgets/functional/tolerance_settings.dart';
import 'advanced_settings.dart';

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
    Size size = MediaQuery.of(context).size;
    return PopScope(
      canPop: true,
      onPopInvoked: (pop) async {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const SoundSampling()),
                (Route<dynamic> route) => false,
          );
        });
      },
      child: Scaffold(
        appBar: HomeAppBar(
          title: /*Pitch Trainer - */'${Languages.settings.getString(context)}',
          action1: Container(),
          action2: Container(),
          action3: Container(),
        ),
        body: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            children: [
              LanguageSettings(),
              ThemeSettings(),
              SizedBox(height: size.height * 0.03),
              Divider(height: 0.1, color: Colors.white, thickness: 0.2,),
              PrecisionSettings(),
              ToleranceSettings(),
              SoundWaveSettings(),
              Divider(height: 0.1, color: Colors.white, thickness: 0.2,),
              OtherSettings(),
            ],
          ),
        ),
      ),
    );
  }
}

