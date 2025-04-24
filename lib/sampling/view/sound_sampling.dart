import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_audio_waveforms/flutter_audio_waveforms.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:flutter_pitch_detection/flutter_pitch_detection.dart';
import 'package:flutter_pitch_detection/flutter_pitch_detection_platform_interface.dart';
import 'package:flutter_svg/svg.dart';
import 'package:linear_progress_bar/linear_progress_bar.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pitch_trainer/sampling/view/sampling_type.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../general/utils/languages.dart';
import '../../general/widgets/double_tap_to_exit.dart';
import '../../general/widgets/home_app_bar.dart';
import '../../general/widgets/ui_utils.dart';
import '../../settings/view/settings.dart';
import '../utils/constants.dart';

class SoundSampling extends StatefulWidget {
  const SoundSampling({super.key});

  @override
  State<SoundSampling> createState() => _SoundSampling();
}

class _SoundSampling extends State<SoundSampling> with WidgetsBindingObserver {
  String _selectedNote = "-";
  double _selectedFrequency = 0.0;
  List<double> _samples = [];
  int _accuracy = 0;
  double _minFrequency = 0.0;
  double _maxFrequency = 0.0;
  String _selectedInstrument = "";
  bool _isLoading = true;
  double _loudness = 0;
  final _pitchDetector = FlutterPitchDetection();
  StreamSubscription<Map<String, dynamic>>? _pitchSubscription;
  late int _sampleRate;
  late double _tolerance;
  late double _precision;
  late int _bufferSize;
  late bool _isCleanWave;
  bool _isOnPitch = false;
  bool _rec = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _loadPreferences().then((_) {
      _startRecording();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);

    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached ||
        state == AppLifecycleState.hidden) {
      _stopRecording();
    } else if (state == AppLifecycleState.resumed) {
      _startRecording();
    }
  }

  //STYLE
  Widget _loudnessBarStyle(size, td) {
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
            ),
          ],
        ),
      ),
    );
  }

  Color _getAccuracyColor(double accuracy, ThemeData td) {
    return Color.lerp(Colors.white, td.colorScheme.primary, accuracy / 100)!;
  }

  Color _getAccuracyColorReverse(double accuracy, ThemeData td) {
    return Color.lerp(td.colorScheme.primary, Colors.white, accuracy / 100)!;
  }

  BoxShadow _getAccuracyShadow(double accuracy, ThemeData td) {
    double blurRadius = 100;
    double spreadRadius = accuracy/100*20;
    Color mixedColor = Color.lerp(td.colorScheme.primary, td.colorScheme.onSurface, 0.7)!;

    Color shadowColor = Color.lerp(Colors.transparent, td.colorScheme.secondary,(accuracy / 100) * 0.4 + 0.6, )!;

    return BoxShadow(
      color: shadowColor,
      blurRadius: blurRadius,
      spreadRadius: spreadRadius,
      offset: const Offset(0, 1),
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
        colorFilter: ColorFilter.mode(
          td.colorScheme.onSurface,
          BlendMode.srcIn,
        ),
      ),
      onPressed: () {
        _stopRecording();
      },
    );
  }

  Widget _disabledRecordingButton(size, td) {
    return IconButton(
      icon: SvgPicture.asset(
        "assets/icons/microphone-slash-svgrepo-com.svg",
        height: size.height * 0.04,
        width: size.width * 0.04,
        colorFilter: ColorFilter.mode(
          td.colorScheme.onSurface,
          BlendMode.srcIn,
        ),
      ),
      onPressed: () {
        _startRecording();
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
      icon: Icon(
        Icons.settings_outlined,
        color: td.colorScheme.onSurface,
        size: size.height * 0.03,
      ),
      onPressed: _onPressedSettings,
    );
  }

  Widget _loudnessBar(size, ThemeData td) {
    int currentStep = _loudness.toInt();

    return Container(
      decoration: BoxDecoration(
        color: td.colorScheme.primary,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Stack(
        children: [
          _progressLoudBar(size, currentStep, td),
          //_loudnessBarStyle(size, td),
        ],
      ),
    );
  }

  Widget _soundWave(size, td) {
    return Container(
      decoration: BoxDecoration(boxShadow: [UiUtils.widgetsShadow(1, 45, td)]),
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

  Widget _noteLabel(Size size, ThemeData td) {
    return Center(
      child: PermissionStatus.granted.isGranted
          ? Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: size.width*0.5,
            height: size.height*0.25,
            decoration: BoxDecoration(
              boxShadow: [_getAccuracyShadow(_accuracy.toDouble(), td)],
            ),
          ),
          // Actual Text
          Text(
            _selectedNote,
            style: TextStyle(
              color: _getAccuracyColor(_accuracy.toDouble(), td),
              fontSize: size.width * 0.35,
              shadows: [UiUtils.widgetsShadowColor(80, 20, _getAccuracyColorReverse(_accuracy.toDouble(), td))],
            ),
          ),
        ],
      )
          : SizedBox(
        width: size.width * 0.7,
        child: Text(
          Languages.permissionsWarning.getString(context),
          style: TextStyle(
            color: td.colorScheme.onSurface,
            fontSize: size.width * 0.04,
            shadows: [UiUtils.widgetsShadow(80, 20, td)],
          ),
        ),
      ),
    );
  }

  Widget _frequencyBar(Size size, td) {
    return Row(
      spacing: size.width*0.05,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          _rec ? "${_selectedFrequency.toStringAsFixed(2)}Hz" : "",
          style: TextStyle(
            color: td.colorScheme.onSurface,
            fontSize: size.width * 0.038,
            shadows: [UiUtils.widgetsShadow(80, 20, td)],
          ),
        ),
        Text(
          _rec ? "${_accuracy.toStringAsFixed(2)}%" : "",
          style: TextStyle(
            color: td.colorScheme.onSurface,
            fontSize: size.width * 0.038,
            shadows: [UiUtils.widgetsShadow(80, 20, td)],
          ),
        ),
        // Text(
        //   _rec ? "${_loudness.toStringAsFixed(2)} vol" : "",
        //   style: TextStyle(
        //     color: td.colorScheme.onSurface,
        //     fontSize: size.width * 0.038,
        //     shadows: [UiUtils.widgetsShadow(80, 20, td)],
        //   ),
        // ),
      ],
    );
  }

  Widget _startStopRecording(size, td) {
    Widget action;

    (_rec == true)
        ? action = _enabledRecordingButton(size, td)
        : action = _disabledRecordingButton(size, td);

    return action;
  }

  Widget _progressLoudBar(size, currentStep, td) {
    return LinearProgressBar(
      maxSteps: 100,
      progressType: LinearProgressBar.progressTypeLinear,
      currentStep: currentStep,
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
  void _resetPitchValues() {
    setState(() {
      _selectedFrequency = 0.0;
      _selectedNote = "-";
      _accuracy = 0;
      _loudness = 0;
      _samples = [];
    });
  }

  void _setPitchValues(String note, double frequency, int accuracy, bool isCleanWave, List<double> rawData, double loudness,) {
    setState(() {
      _selectedNote = note;
      _selectedFrequency = frequency;
      _accuracy = accuracy;
      // _samples =
      //     isCleanWave
      //         ? SoundProcessing.updateSamples(frequency, recorder!.sampleRate)
      //         : rawData;
      _loudness = loudness;
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
      _selectedInstrument =
          prefs.getString('instrumentIcon') ??
          'assets/icons/piano-instrument-keyboard-svgrepo-com.svg';
    });
  }

  void _onPressedInstruments() {
    _stopRecording();
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => const SamplingType()));
  }

  void _onPressedSettings() {
    _stopRecording();
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => const Settings()));
  }

  Future<void> getValues() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _sampleRate = prefs.getInt('sampleRate') ?? Constants.defaultSampleRate;
    _bufferSize = prefs.getInt('bufferSize') ?? Constants.defaultBufferSize;
    _precision = prefs.getDouble('precision') ?? Constants.defaultPrecision;
    _tolerance = prefs.getDouble('tolerance') ?? Constants.defaultTolerance;
    _isCleanWave = prefs.getBool('isCleanWave') ?? true;
  }

  Future<void> _startRecording() async {
    if(!_rec) {
      try {
        await _pitchDetector.startDetection();
        bool rec = await _pitchDetector.isRecording();

        setState(() {
          _rec = rec;
        });
        debugPrint("[START] Is Recording: $_rec");
        _pitchDetector.setParameters(toleranceCents: 0.15, bufferSize: 8192, sampleRate: 44100, minPrecision: 0.85);

        _pitchSubscription = FlutterPitchDetectionPlatform.instance.onPitchDetected.listen((event) async {
          debugPrint("Full event: $event");
          debugPrint("Event keys: ${event.keys.join(', ')}");
          debugPrint("Event values type: ${event.values.runtimeType}");

          final newNote = await _pitchDetector.getNote();
          final newFrequency = await _pitchDetector.getFrequency();
          final newNoteOctave = await _pitchDetector.printNoteOctave();
          final newOctave = await _pitchDetector.getOctave();
          final newToleranceCents = await _pitchDetector.getToleranceCents();
          final newBufferSize = await _pitchDetector.getBufferSize();
          final newSampleRate = await _pitchDetector.getSampleRate();
          final newIsRecording = await _pitchDetector.isRecording();
          final newMinPrecision = await _pitchDetector.getMinPrecision();
          final newAccuracy = await _pitchDetector.getAccuracy(newToleranceCents);
          final newIsOnPitch = await _pitchDetector.isOnPitch(newToleranceCents, newMinPrecision);
          final newVolume = await _pitchDetector.getVolume();
          final newVolumeFromDbSF = await _pitchDetector.getVolumeFromDbFS();

          if(newFrequency > _minFrequency && newFrequency < _maxFrequency) {
            setState(() {
              _selectedNote = newNoteOctave;
              _selectedFrequency = newFrequency;
              _sampleRate = newSampleRate;
              _accuracy = newAccuracy;
              _isOnPitch = newIsOnPitch;
              _loudness = newVolumeFromDbSF;
              _samples = event.values.toList() as List<double>;
              debugPrint("$_samples");
            });
          }
        });

      } catch (e) {
        debugPrint("Start Recording Error: $e");
      }
    }
  }

  Future<void> _stopRecording() async {
    if(_rec) {
      try {
        await _pitchDetector.stopDetection();
        bool rec = await _pitchDetector.isRecording();

        setState(() {
          _rec = rec;
        });

        debugPrint("[STOP] Is Recording: $_rec");
        await _pitchSubscription?.cancel();
        _pitchSubscription = null;
        _resetPitchValues();

      } catch(e) {
        debugPrint("Stop Recording Error: $e");
      }
    }
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
          action2:
              _isLoading ? UiUtils.loadingStyle(td) : _instruments(size, td),
          action3: _settings(size, td),
        ),
        body: Column(
          children: [
            SizedBox(height: size.height * 0.001),
            _rec ? _loudnessBar(size, td) : Container(),
            Expanded(
              child: Center(
                child: Container(
                  height: size.height * 0.85,
                  width: size.width * 0.9,
                  decoration: BoxDecoration(
                    boxShadow: [UiUtils.widgetsShadow(2, 20, td)],
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
