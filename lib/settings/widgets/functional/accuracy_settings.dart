import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:pitch_trainer/general/utils/languages.dart';
import 'package:pitch_trainer/settings/widgets/button_select.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../general/widgets/ui_utils.dart';

class AccuracySettings extends StatefulWidget {
  const AccuracySettings({super.key});

  @override
  State<AccuracySettings> createState() => _AccuracySettings();
}

class _AccuracySettings extends State<AccuracySettings> {
  late SharedPreferences _prefs;
  List<bool> _selectionValues = [true, false, false];
  double _selectedAccuracy = 0.0;

  @override
  void initState() {
    WidgetsFlutterBinding.ensureInitialized();
    _getPreferences();
    super.initState();
  }

  void _getPreferences() async {
    _prefs = await SharedPreferences.getInstance();
    _getAccuracyState();

    setState(() {});
  }

  //ACCURACY
  //STYLE
  Widget _accuracyTitle(size, td) {
    return SizedBox(
      width: size.width * 0.4,
      child: Align(
        alignment: Alignment.center,
        child: Text(
          Languages.accuracyThreshold.getString(context),//TODO
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

  Widget _accuracySection(size, td) {
    return Center(
      child: SizedBox(
        width: size.width * 0.9,
        child: Column(
          children: [
            SizedBox(height: size.height * 0.04),
            _accuracyTitle(size, td),
            SizedBox(height: size.height * 0.03),
            _accuracySelectionButton(td),
          ],
        ),
      ),
    );
  }

  //WIDGETS
  Widget _accuracySelectionButton(ThemeData td) {
    TextStyle buttonStyle = TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w500,
      color: td.colorScheme.onSurface,
    );
    List<Widget> accuracyValues = [
      Text("0.5 hz", style: buttonStyle),
      Text("1 hz", style: buttonStyle),
      Text("1.5 hz", style: buttonStyle),
    ];

    return ButtonSelect(
      selectionValues: _selectionValues,
      onPressed: _onPressedAccuracy,
      children: accuracyValues,
    );
  }

  //METHODS
  void _onPressedAccuracy(int index) {
    List<double> values = [0.5, 1, 1.5];

    setState(() {
      for (int i = 0; i < _selectionValues.length; i++) {
        _selectionValues[i] = i == index;
      }
      _setAccuracyState(values[index]);
    });
  }


  void _getAccuracyState() async {
    _selectedAccuracy = (_prefs.getDouble('accuracyThreshold') ?? 1);//todo

    setState(() {
      if (_selectedAccuracy == 0.5) {
        _selectionValues = [true, false, false];
      } else if (_selectedAccuracy == 1) {
        _selectionValues = [false, true, false];
      } else if (_selectedAccuracy == 1.5) {
        _selectionValues = [false, false, true];
      }
    });
  }

  void _setAccuracyState(double value) async {
    //_prefs.setDouble('accuracyThreshold', value);TODO
  }

  //BUILD
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    ThemeData td = Theme.of(context);

    return Column(
        children: [
          _accuracySection(size, td),
          SizedBox(height: size.height * 0.05),
        ],
    );
  }
}
