import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:pitch_trainer/general/utils/languages.dart';
import 'package:pitch_trainer/settings/widgets/button_select.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../general/widgets/ui_utils.dart';
import '../../../sampling/utils/constants.dart';

class BufferSizeSettings extends StatefulWidget {
  const BufferSizeSettings({super.key});

  @override
  State<BufferSizeSettings> createState() => _BufferSizeSettings();
}

class _BufferSizeSettings extends State<BufferSizeSettings> {
  late SharedPreferences _prefs;
  List<bool> _selectionValues = [false, true];
  int _selectedBufferSize = Constants.defaultBufferSize;

  @override
  void initState() {
    WidgetsFlutterBinding.ensureInitialized();
    _getPreferences();
    super.initState();
  }

  void _getPreferences() async {
    _prefs = await SharedPreferences.getInstance();
    _getBufferSizeState();

    setState(() {});
  }

  //BUFFER SIZE
  //STYLE
  Widget _bufferSizeTitle(size, td) {
    return SizedBox(
      width: size.width * 0.8,
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          Languages.bufferSize.getString(context),
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

  Widget _bufferSizeSection(size, td) {
    return Center(
      child: SizedBox(
        width: size.width * 0.9,
        child: Column(
          children: [
            SizedBox(height: size.height * 0.04),
            _bufferSizeTitle(size, td),
            SizedBox(height: size.height * 0.03),
            _bufferSizeSelectionButton(td, size),
          ],
        ),
      ),
    );
  }

  //WIDGETS
  Widget _bufferSizeSelectionButton(ThemeData td, Size size) {
    TextStyle buttonStyle = TextStyle(
      color: Color.lerp(td.colorScheme.primary, Colors.white, 0.6)!,
      fontWeight: FontWeight.w800,
      fontSize: 18,
    );
    List<Widget> bufferSizeValues = [
      Text("7056", style: buttonStyle),
      Text("8192", style: buttonStyle),
    ];

    return ButtonSelect(
      selectionValues: _selectionValues,
      onPressed: _onPressedBufferSize,
      minWidth: size.width * 0.415,
      children: bufferSizeValues,
    );
  }

  //METHODS
  void _onPressedBufferSize(int index) {
    List<int> values = [7056, 8192];

    setState(() {
      for (int i = 0; i < _selectionValues.length; i++) {
        _selectionValues[i] = i == index;
      }
      _setBufferSizeState(values[index]);
    });
  }


  void _getBufferSizeState() async {
    _selectedBufferSize = (_prefs.getInt('bufferSize') ?? Constants.defaultBufferSize);

    setState(() {
      if (_selectedBufferSize == 7056) {
        _selectionValues = [true, false];
      } else if (_selectedBufferSize == 8192) {
        _selectionValues = [false, true];
      }
    });
  }

  void _setBufferSizeState(int value) async {
    _prefs.setInt('bufferSize', value);
  }

  //BUILD
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    ThemeData td = Theme.of(context);

    return Column(
        children: [
          _bufferSizeSection(size, td),
          SizedBox(height: size.height * 0.05),
        ],
    );
  }
}
