import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pitch_trainer/general/utils/languages.dart';
import 'package:pitch_trainer/settings/widgets/text_field_card.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../general/widgets/ui_utils.dart';
import '../../../sampling/logic/recorder.dart';

class RatesSettings extends StatefulWidget {
  const RatesSettings({super.key,});

  @override
  State<RatesSettings> createState() => _RatesSettings();
}

class _RatesSettings extends State<RatesSettings> {
  final TextEditingController _sampleRateController = TextEditingController();
  final TextEditingController _bitRateController = TextEditingController();
  late SharedPreferences _prefs;
  late Recorder recorder;
  @override
  void initState() {
    recorder = Recorder();
    recorder.initialize();
    WidgetsFlutterBinding.ensureInitialized();
    _getPreferences();
    super.initState();
  }

  void _getPreferences() async {
    _prefs = await SharedPreferences.getInstance();
    _getBitRate();
    _getSampleRate();

    setState(() {

    });
  }

  //BIT RATE
  //STYLE
  Widget _bitRateTitle(size, td) {
    return SizedBox(
      width: size.width*0.4,
      child: Align(
        alignment: Alignment.center,
        child: Text(
          "Bit Rate",
          style: TextStyle(color: td.colorScheme.onSurface, fontWeight: FontWeight.w500, fontSize: 18, shadows: [UiUtils.widgetsShadow(80, 20, td),]),
        ),
      ),
    );
  }

  Widget _bitRateField(Size size) {
    return SizedBox(
      width: size.width*0.4,
      child: TextFieldCard(
        controller: _bitRateController,
        hintText: recorder.defaultBitRate.toString(),
        isEnabled: true,
        trailingIcon: Icons.save_outlined,
        onTrailingIconPressed: () => _setBitRate(_bitRateController.text),
        onChanged: (value) {
          _bitRateController.text = value;
        },
      ),
    );
  }

  Widget _bitRate(Size size, td) {
    return Column(
      children: [
        _bitRateTitle(size, td),
        SizedBox(height: size.height*0.03,),
        _bitRateField(size),
      ],
    );
  }

  //METHODS
  void _getBitRate() async {
    _bitRateController.text = (_prefs.getInt('bitRate') ?? recorder.defaultBitRate).toString();
  }

  VoidCallback? _setBitRate(String bitRate) {
    if(bitRate=="") {
      setState(() {
        bitRate = recorder.defaultBitRate.toString();
      });
    }
    setState(() {
      _bitRateController.text = bitRate;
    });
    _prefs.setInt('bitRate', int.parse(bitRate));
    Fluttertoast.showToast(msg: Languages.savedBitRate.getString(context));
    return null;
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
        hintText: recorder.defaultSampleRate.toString(),
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
    _sampleRateController.text = (_prefs.getInt('sampleRate') ?? recorder.defaultSampleRate).toString();
  }

  VoidCallback? _setSampleRate(String sampleRate) {
    if(sampleRate=="") {
      setState(() {
        sampleRate = recorder.defaultSampleRate.toString();
      });
    }
    setState(() {
      _sampleRateController.text = sampleRate;
    });
    _prefs.setInt('sampleRate', int.parse(sampleRate));
    Fluttertoast.showToast(msg: Languages.savedSampleRate.getString(context));
    return null;
  }

  //SAMPLE + BIT RATE
  Widget _audioOptions(Size size, ThemeData td) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _sampleRate(size, td),
        SizedBox(width: size.width*0.06,),
        _bitRate(size, td),
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

