import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pitch_trainer/general/utils/languages.dart';
import 'package:pitch_trainer/settings/widgets/text_field_card.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../general/widgets/ui_utils.dart';
import '../../../sampling/logic/utils.dart';
import '../../../sampling/utils/constants.dart';

class RatesSettings extends StatefulWidget {
  const RatesSettings({super.key,});

  @override
  State<RatesSettings> createState() => _RatesSettings();
}

class _RatesSettings extends State<RatesSettings> {
  final TextEditingController _sampleRateController = TextEditingController();
  final TextEditingController _bufferSizeController = TextEditingController();
  final TextEditingController _toleranceController = TextEditingController();
  final TextEditingController _precisionController = TextEditingController();
  late SharedPreferences _prefs;
  @override
  void initState() {
    WidgetsFlutterBinding.ensureInitialized();
    _getPreferences();
    super.initState();
  }

  void _getPreferences() async {
    _prefs = await SharedPreferences.getInstance();
    _getSampleRate();

    setState(() {

    });
  }

  //SAMPLE RATE
  //STYLE
  Widget _sampleRateTitle(size, td) {
    return SizedBox(
      width: size.width*0.4,
      child: Align(
        alignment: Alignment.center,
        child: Text(
          "Sample Rate",
          style: TextStyle(color: td.colorScheme.onSurface, fontWeight: FontWeight.w500, fontSize: 18, shadows: [UiUtils.widgetsShadow(80, 20, td),]),
        ),
      ),
    );
  }

  Widget _sampleRateField(Size size) {
    return SizedBox(
      width: size.width*0.4,
      child: TextFieldCard(
        controller: _sampleRateController,
        hintText: Constants.defaultSampleRate.toString(),
        isEnabled: true,
        onChanged: (value) {
          _sampleRateController.text = value;
        },
        onTrailingIconPressed: () => _setSampleRate(_sampleRateController.text),
        trailingIcon: Icons.save_outlined,
      ),
    );
  }

  Widget _sampleRate(Size size, td) {
    return Column(
      children: [
        _sampleRateTitle(size, td),
        SizedBox(height: size.height*0.03,),
        _sampleRateField(size),
      ],
    );
  }

  //METHODS
  void _getSampleRate() async {
    _sampleRateController.text = (_prefs.getInt('sampleRate') ?? Constants.defaultSampleRate).toString();
  }

  void _getTolerance() async {
    _toleranceController.text = (_prefs.getDouble('tolerance') ?? Constants.defaultTolerance).toString();
  }

  void _getPrecision() async {
    _precisionController.text = (_prefs.getDouble('precision') ?? Constants.defaultPrecision).toString();
  }

  void _getBufferSize() async {
    _bufferSizeController.text = (_prefs.getInt('bufferSize') ?? Constants.defaultBufferSize).toString();
  }

  VoidCallback? _setSampleRate(String sampleRate) {
    if(sampleRate=="") {
      setState(() {
        sampleRate = Constants.defaultSampleRate.toString();
      });
    }
    setState(() {
      _sampleRateController.text = sampleRate;
    });
    _prefs.setInt('sampleRate', int.parse(sampleRate));
    Fluttertoast.showToast(msg: Languages.savedSampleRate.getString(context));
    return null;
  }

  VoidCallback? _setPrecision(String precision) {
    if(precision=="") {
      setState(() {
        precision = Constants.defaultSampleRate.toString();
      });
    }
    setState(() {
      _precisionController.text = precision;
    });
    _prefs.setDouble('precision', double.parse(precision));
    Fluttertoast.showToast(msg: Languages.savedSampleRate.getString(context));//TODO make lang
    return null;
  }

  VoidCallback? _setTolerance(String tolerance) {
    if(tolerance=="") {
      setState(() {
        tolerance = Constants.defaultTolerance.toString();
      });
    }
    setState(() {
      _toleranceController.text = tolerance;
    });
    _prefs.setDouble('tolerance', double.parse(tolerance));
    Fluttertoast.showToast(msg: Languages.savedSampleRate.getString(context));//TODO make lang
    return null;
  }

  VoidCallback? _setBufferSize(String bufferSize) {
    if(bufferSize=="") {
      setState(() {
        bufferSize = Constants.defaultBufferSize.toString();
      });
    }
    setState(() {
      _bufferSizeController.text = bufferSize;
    });
    _prefs.setInt('bufferSize', int.parse(bufferSize));
    Fluttertoast.showToast(msg: Languages.savedSampleRate.getString(context));//TODO make lang
    return null;
  }

  //SAMPLE
  Widget _audioOptions(Size size, ThemeData td) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _sampleRate(size, td),
        SizedBox(width: size.width*0.06,),
      ],
    );
  }

  //BUILD
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    ThemeData td = Theme.of(context);

    return Column(
          children: [
            _audioOptions(size, td),
            SizedBox(height: size.height * 0.05),
          ],
    );
  }
}

