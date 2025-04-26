import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:pitch_trainer/general/utils/languages.dart';
import 'package:pitch_trainer/settings/widgets/button_select.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../general/utils/warning_dialog.dart';
import '../../../general/widgets/ui_utils.dart';
import '../../../sampling/utils/constants.dart';

class SampleRateSettings extends StatefulWidget {
  const SampleRateSettings({super.key});

  @override
  State<SampleRateSettings> createState() => _SampleRateSettings();
}

class _SampleRateSettings extends State<SampleRateSettings> {
  late SharedPreferences _prefs;
  List<bool> _selectionValues = [true, false, false];
  int _selectedSampleRate = Constants.defaultSampleRate;

  @override
  void initState() {
    WidgetsFlutterBinding.ensureInitialized();
    _getPreferences();
    super.initState();
  }

  void _getPreferences() async {
    _prefs = await SharedPreferences.getInstance();
    _getSampleRateState();

    setState(() {});
  }

  //BUFFER SIZE
  //STYLE
  Widget _sampleRateTitle(size, td) {
    return SizedBox(
      width: size.width * 0.8,
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          Languages.sampleRate.getString(context),
          style: TextStyle(
            color: td.colorScheme.onSurface,
            fontWeight: FontWeight.w500,
            fontSize: 18,
            shadows: [UiUtils.widgetsShadow(80, 20, td)],
          ),
        ),
      ),
    );
  }

  Widget _sampleRateSection(size, td) {
    return Center(
      child: SizedBox(
        width: size.width * 0.9,
        child: Column(
          children: [
            SizedBox(height: size.height * 0.04),
            _sampleRateTitle(size, td),
            SizedBox(height: size.height * 0.03),
            _sampleRateSelectionButton(td),
          ],
        ),
      ),
    );
  }

  //WIDGETS
  Widget _sampleRateSelectionButton(ThemeData td) {
    TextStyle buttonStyle = TextStyle(
      color: Color.lerp(td.colorScheme.primary, Colors.white, 0.6)!,
      fontWeight: FontWeight.w800,
      fontSize: 18,
    );
    List<Widget> sampleRateValues = [
      Text("22.05kHz", style: buttonStyle),
      Text("44.1kHz", style: buttonStyle),
      Text("48kHz", style: buttonStyle),
    ];

    return ButtonSelect(
      selectionValues: _selectionValues,
      onPressed: _showDialog,
      children: sampleRateValues,
    );
  }

  //METHODS
  void _onPressedSampleRate(int index) {
    List<int> values = [22050, 44100, 48000];

    setState(() {
      for (int i = 0; i < _selectionValues.length; i++) {
        _selectionValues[i] = i == index;
      }
      _setSampleRateState(values[index]);
    });
  }

  void _showDialog(int index) {
    index == 0 ?
    showDialog(
      context: context,
      builder: (context) => WarningDialog(
        title: Languages.sampleRateWarning.getString(context),
        subtitle: Languages.sampleRateWarningSubText.getString(context),
        onYesPressed: () {
          Navigator.pop(context);
          _onPressedSampleRate(index);
        },
        onNoPressed: () {
          Navigator.pop(context);
        },
      ),
    ) :
    _onPressedSampleRate(index);
  }

  void _getSampleRateState() async {
    _selectedSampleRate = (_prefs.getInt('sampleRate') ?? Constants.defaultSampleRate);

    setState(() {
      if (_selectedSampleRate == 22050) {
        _selectionValues = [true, false, false];
      } else if (_selectedSampleRate == 44100) {
        _selectionValues = [false, true, false];
      } else if (_selectedSampleRate == 48000) {
        _selectionValues = [false, false, true];
      }
    });
  }

  void _setSampleRateState(int value) async {
    _prefs.setInt('sampleRate', value);
  }

  //BUILD
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    ThemeData td = Theme.of(context);

    return Column(
      children: [
        _sampleRateSection(size, td),
        SizedBox(height: size.height * 0.01),
      ],
    );
  }
}
