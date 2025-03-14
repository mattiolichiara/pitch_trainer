import 'dart:async';
import 'dart:typed_data';

import 'package:complex/complex.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:flutter_sound/public/flutter_sound_recorder.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pitch_trainer/sampling/utils/recorder.dart';
import 'package:pitch_trainer/sampling/utils/sound_processing.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_audio_waveforms/flutter_audio_waveforms.dart';
import 'package:flutter_svg/svg.dart';
import 'package:linear_progress_bar/linear_progress_bar.dart';
import 'package:pitch_trainer/sampling/view/sampling_type.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../general/utils/languages.dart';
import '../../general/view/settings.dart';
import '../../general/widgets/double_tap_to_exit.dart';
import '../../general/widgets/home_app_bar.dart';
import '../../general/widgets/ui_utils.dart';

class SoundSampling extends StatefulWidget {
  const SoundSampling({super.key});

  @override
  State<SoundSampling> createState() => _SoundSampling();
}

class _SoundSampling extends State<SoundSampling> with WidgetsBindingObserver {
  String _selectedNote = "-";
  String _selectedOctave = "";
  double _selectedFrequency = 0.0;
  bool _isPermissionAllowed = false;
  List<double> _samples = [];
  double _accuracy = 0.0;
  double _minFrequency = 0.0;
  double _maxFrequency = 0.0;
  String _selectedInstrument = "";
  late FlutterSoundRecorder _recorder;
  bool _isRecording = false;
  bool _isLoading = true;

  @override
  void initState() {
    _loadPreferences().then((_){});

    _recorder = FlutterSoundRecorder();
    WidgetsBinding.instance.addObserver(this);
    _requestPermissions(_recorder);

    super.initState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _recorder.closeRecorder();
    Recorder.stopRecording(_recorder, _resetPitchValues, _setRecordingState);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused || state == AppLifecycleState.detached || state == AppLifecycleState.hidden) {
      Recorder.pauseRecording(_recorder, _resetPitchValues, _setRecordingState);
    } else if (state == AppLifecycleState.resumed) {
      Recorder.resumeRecording(_recorder, _setRecordingState, _requestPermissions(_recorder));
    }
  }

  //STYLE
  Widget _progressBarStyle(size, td) {
    return Center(
      child: Container(
        width: 10,
        height: size.height * 0.0035,
        decoration: BoxDecoration(
            color: td.colorScheme.onSurface,
            boxShadow: [
              BoxShadow(
                color: td.colorScheme.onSurface,
                spreadRadius: 1,
                blurRadius: 15,
                offset: Offset(0, 1),
              )
            ]
        ),
      ),
    );
  }

  Widget _instrumentIcon(size, td) {
    return SvgPicture.asset(
      _selectedInstrument,
      height: size.height * 0.03,
      width: size.width * 0.03,
      colorFilter: ColorFilter.mode(td.colorScheme.onSurface, BlendMode.srcIn),
    );
  }

  Widget _enabledRecordingButton(size, td) {
    return IconButton(
      icon: SvgPicture.asset(
        "assets/icons/microphone-svgrepo-com.svg",
        height: size.height * 0.04,
        width: size.width * 0.04,
        colorFilter: ColorFilter.mode(td.colorScheme.onSurface, BlendMode.srcIn),
      ),
      onPressed: () {
        Recorder.pauseRecording(_recorder, _resetPitchValues, _setRecordingState);
      },
    );
  }

  Widget _disabledRecordingButton(size, td) {
    return IconButton(
      icon: SvgPicture.asset(
        "assets/icons/microphone-slash-svgrepo-com.svg",
        height: size.height * 0.04,
        width: size.width * 0.04,
        colorFilter: ColorFilter.mode(td.colorScheme.onSurface, BlendMode.srcIn),
      ),
      onPressed: () {
        Recorder.resumeRecording(_recorder, _setRecordingState, _requestPermissions(_recorder));
      },
    );
  }

  //WIDGETS
  Widget _mainCard(size, td) {
    return Card.outlined(
      shadowColor: td.colorScheme.primary,
      color: td.colorScheme.surface,
      child: Center(
        child: SizedBox(
          height: size.height * 0.85,
          width: size.width * 0.9,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _noteLabel(size, td),
              _frequencyBar(size, td),
              _soundWave(size, td),
            ],
          ),
        ),
      ),
    );
  }

  Widget _instruments(size, td) {
    return IconButton(
      icon: _instrumentIcon(size, td),
      onPressed: _onPressedInstruments,
    );
  }

  Widget _settings(size, td) {
    return IconButton(
      icon: Icon(Icons.settings_outlined, color: td.colorScheme.onSurface, size: size.height*0.03,),
      onPressed: _onPressedSettings,
    );
  }

  Widget _accuracyBar(size, ThemeData td) {

    int currentStep = ((_accuracy + 100) / 200 * 100).round();

    return Container(
      decoration: BoxDecoration(
        color: td.colorScheme.primary,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Stack(
        children: [
          _progressBar(size, currentStep, td),
          _progressBarStyle(size, td),
        ],
      ),
    );
  }

  Widget _soundWave(size, td) {

    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          UiUtils.widgetsShadow(1, 45, td)
        ],
      ),
      child: CurvedPolygonWaveform(
        strokeWidth: 0.6,
        style: PaintingStyle.stroke,
        activeColor: td.colorScheme.secondary,
        inactiveColor: const Color(0xFF252428),
        samples: _samples,
        height: size.height * 0.035,
        width: size.width * 0.85,
        showActiveWaveform: true,
        elapsedDuration: Durations.short1,
        maxDuration: Durations.short1,
      ),
    );
  }

  Widget _noteLabel(size, td) {
    return Center(
        child: _isPermissionAllowed == true
            ? Text(
          "$_selectedNote$_selectedOctave",
          style: TextStyle(
            color: td.colorScheme.onSurface,
            fontSize: size.width * 0.35,
            shadows: [
              UiUtils.widgetsShadow(80, 20, td),
            ],
          ),
        )
            : Text(
          Languages.permissionsWarning.getString(context),
          style: TextStyle(
            color: td.colorScheme.onSurface,
            fontSize: size.width * 0.04,
            shadows: [
              UiUtils.widgetsShadow(80, 20, td),
            ],
          ),
        ));
  }

  Widget _frequencyBar(size, td) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          _isPermissionAllowed == true
              ? "${_selectedFrequency.toStringAsFixed(2)} HZ"
              : "",
          style: TextStyle(
            color: td.colorScheme.onSurface,
            fontSize: size.width * 0.038,
            shadows: [
              UiUtils.widgetsShadow(80, 20, td),
            ],
          ),
        ),
        Text(
          _isPermissionAllowed == true
              ? "            ${_accuracy.toStringAsFixed(2)}"
              : "",
          style: TextStyle(
            color: td.colorScheme.onSurface,
            fontSize: size.width * 0.038,
            shadows: [
              UiUtils.widgetsShadow(80, 20, td),
            ],
          ),
        ),
      ],
    );
  }

  Widget _startStopRecording(size, td) {
    Widget action;

    (_isRecording == true)
        ? action = _enabledRecordingButton(size, td)
        : action = _disabledRecordingButton(size, td);

    return action;
  }

  Widget _progressBar(size, currentStep, td) {
    return LinearProgressBar(
      maxSteps: 100,
      progressType: LinearProgressBar.progressTypeLinear,
      currentStep: currentStep.clamp(0, 100),
      progressColor: td.colorScheme.onSurface,
      backgroundColor: td.colorScheme.onSurfaceVariant,
      dotsAxis: Axis.horizontal,
      valueColor: AlwaysStoppedAnimation<Color>(td.colorScheme.onSurface),
      semanticsLabel: "Label",
      semanticsValue: "Value",
      minHeight: size.height * 0.0035,
      borderRadius: BorderRadius.circular(10),
    );
  }

  //METHODS
  void _setRecordingState(bool listening) {
    setState(() {
      _isRecording = listening;
    });
  }

  void _resetPitchValues() {
    setState(() {
      _selectedFrequency = 0.0;
      _selectedNote = "-";
      _selectedOctave = "";
      _accuracy = 0.0;
      _samples = [];
    });
  }

  void _setPitchValues(String note, double frequency) {
    setState(() {
      _selectedNote = note;
      _selectedFrequency = frequency;
      _accuracy = SoundProcessing.getNoteAccuracy(note, frequency);
      _samples = SoundProcessing.updateSamples(frequency);
    });
  }

  Future<void> _loadPreferences() async {
    await _loadFrequencyValues();

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _loadFrequencyValues() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _minFrequency = prefs.getDouble('minFrequency') ?? 27.50;
      _maxFrequency = prefs.getDouble('maxFrequency') ?? 4186.01;
      _selectedInstrument = prefs.getString('instrumentIcon') ?? 'assets/icons/piano-instrument-keyboard-svgrepo-com.svg';
    });
  }

  void _onPressedInstruments() {
    Recorder.pauseRecording(_recorder, _resetPitchValues, _setRecordingState);
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => const SamplingType(),
    ));
  }

  void _onPressedSettings() {
    Recorder.pauseRecording(_recorder, _resetPitchValues, _setRecordingState);
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => const Settings(),
    ));
  }

  Future<void> _requestPermissions(FlutterSoundRecorder recorder) async {
    await _recorder.openRecorder();
    PermissionStatus audio = await Permission.microphone.request();
    if(audio.isGranted) {
      setState(() {
        _isPermissionAllowed = true;
        Recorder.startRecording(_recorder, _processAudio, _setRecordingState);
      });
    } else {
      setState(() async {
        _isPermissionAllowed = false;
        if(recorder.isRecording) {
          Recorder.stopRecording(_recorder, _resetPitchValues, _setRecordingState);
        }
      });
    }
  }

  Future<void> _processAudio(Stream<Uint8List> stream) async {
    debugPrint("Listening...");
    //debugPrint("Max: $_maxFrequency - Min: $_minFrequency");

    stream.listen((data) {
      List<Complex> processedData = SoundProcessing.fft(SoundProcessing.convertToComplex(SoundProcessing.convertToInt16(data)));
      double frequency = SoundProcessing.getFrequency(SoundProcessing.getPeakIndex(processedData), Recorder.sampleRate, (data.length/2).toInt());

      //debugPrint("NOTE: $note, FREQUENCY: $frequency");
      if (frequency >= _minFrequency && frequency <= _maxFrequency) {
        String note = SoundProcessing.getClosestNoteFromFrequency(frequency);
        _setPitchValues(note, frequency);
      }
    });
  }

  //BUILD
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    ThemeData td = Theme.of(context);

    return DoubleTapToExit(
      toastText: Languages.exitToast.getString(context),
      child: Scaffold(
        appBar: HomeAppBar(
          title: 'Pitch Trainer',
          isHome: true,
          action1: _startStopRecording(size, td),
          action2: _isLoading ? UiUtils.loadingStyle(td) : _instruments(size, td),
          action3: _settings(size, td),
        ),
        body: Column(
          children: [
            SizedBox(
              height: size.height * 0.001,
            ),
            _isRecording? _accuracyBar(size, td) : Container(),
            Expanded(
              child: Center(
                child: Container(
                  height: size.height * 0.85,
                  width: size.width * 0.9,
                  decoration: BoxDecoration(
                    boxShadow: [
                      UiUtils.widgetsShadow(2, 20, td),
                    ],
                  ),
                  child: _mainCard(size, td),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}