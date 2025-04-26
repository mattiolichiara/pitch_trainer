import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:pitch_trainer/general/utils/languages.dart';
import 'package:pitch_trainer/settings/widgets/functional/sample_rate_settings.dart';

import '../../general/widgets/home_app_bar.dart';
import '../widgets/functional/buffer_size_settings.dart';
import '../widgets/functional/language_setting.dart';
import '../widgets/functional/sound_wave_settings.dart';
import '../widgets/functional/theme_settings.dart';

class AdvancedSettings extends StatefulWidget {
  const AdvancedSettings({super.key,});

  @override
  State<AdvancedSettings> createState() => _AdvancedSettings();
}

class _AdvancedSettings extends State<AdvancedSettings> {

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
            title: 'Pitch Trainer - ${Languages.advancedSettings.getString(context)}',
            action1: Container(),
            action2: Container(),
            action3: Container(),
          ),
          body: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Column(
              children: [
                SampleRateSettings(),
                BufferSizeSettings(),
              ],
            ),
          )
      ),
    );
  }
}

