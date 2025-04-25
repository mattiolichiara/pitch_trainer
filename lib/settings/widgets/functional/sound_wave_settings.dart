import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:pitch_trainer/general/utils/languages.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../general/widgets/ui_utils.dart';
import '../../../sampling/logic/utils.dart';

class SoundWaveSettings extends StatefulWidget {
  const SoundWaveSettings({super.key,});

  @override
  State<SoundWaveSettings> createState() => _SoundWaveSettings();
}

class _SoundWaveSettings extends State<SoundWaveSettings> {
  late SharedPreferences _prefs;
  bool _isCleanWave = true;

  @override
  void initState() {
    WidgetsFlutterBinding.ensureInitialized();
    _getPreferences();
    super.initState();
  }

  void _getPreferences() async {
    _prefs = await SharedPreferences.getInstance();
    _getWaveState();

    setState(() {

    });
  }

  //WAVE VIEW
  //STYLE
  Widget _waveTitle(size, td) {
    return SizedBox(
      width: size.width*0.4,
      child: Align(
        alignment: Alignment.center,
        child: Text(
          "Sound Wave",
          style: TextStyle(color: td.colorScheme.onSurface, fontWeight: FontWeight.w500, fontSize: 18, shadows: [UiUtils.widgetsShadow(80, 20, td),]),
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
        fontWeight: FontWeight.w300,
      ),
    );
  }

  Widget _switchWaveWrapper(String rawText, ThemeData td, String polishedText, Size size) {
    return SizedBox(
      width: size.width*0.8,
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

  Widget _waveSection(size, td) {
    return Center(
      child: SizedBox(
        width: size.width*0.9,
        child: Column(
          children: [
            SizedBox(height: size.height*0.04,),
            _waveTitle(size, td),
            SizedBox(height: size.height*0.03,),
            _switchWaveWrapper(Languages.rawWave.getString(context), td, Languages.polishedWave.getString(context), size),
          ],
        ),
      ),
    );
  }

  //WIDGETS


  Widget _switchWave(Size size, ThemeData td) {
    return SizedBox(
      height: size.height*0.04,
      width: size.width*0.4,
      child: Switch(
        value: _isCleanWave,
        onChanged: (value) {
          _setWaveState(value);
        },
        inactiveTrackColor: td.colorScheme.onSurfaceVariant,
        inactiveThumbColor: td.colorScheme.primary,
        activeColor: td.colorScheme.onSurfaceVariant,
        activeTrackColor: td.colorScheme.primary,
        trackOutlineColor: WidgetStateProperty.all(td.colorScheme.primary),
      ),
    );
  }

  //METHODS
  void _getWaveState() async {
    _isCleanWave = (_prefs.getBool('isCleanWave') ?? true);
  }

  void _setWaveState(value) async {
    setState(() {
      _isCleanWave = !_isCleanWave;
    });
    _prefs.setBool('isCleanWave', _isCleanWave);
  }

  //BUILD
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    ThemeData td = Theme.of(context);

    return Column(
                children: [
                  _waveSection(size, td),
                  SizedBox(height: size.height*0.04,),
                ],
    );
  }
}

