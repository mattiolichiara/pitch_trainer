import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_audio_waveforms/flutter_audio_waveforms.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:flutter_pitch_detection/flutter_pitch_detection.dart';
import 'package:flutter_pitch_detection/flutter_pitch_detection_platform_interface.dart';
import 'package:flutter_svg/svg.dart';
import 'package:jumping_dot/jumping_dot.dart';
import 'package:linear_progress_bar/linear_progress_bar.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pitch_trainer/sampling/view/sampling_type.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../../general/utils/languages.dart';
import '../../general/widgets/double_tap_to_exit.dart';
import '../../general/widgets/home_app_bar.dart';
import '../../general/widgets/ui_utils.dart';
import '../../settings/view/settings.dart';
import '../logic/utils.dart';
import '../utils/constants.dart';

class SoundSampling extends StatefulWidget {
  const SoundSampling({super.key});

  @override
  State<SoundSampling> createState() => _SoundSampling();
}

class _SoundSampling extends State<SoundSampling> with WidgetsBindingObserver, TickerProviderStateMixin {
  String _selectedNote = "";
  String _selectedOctave = "";
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
  int _midiNote = 0;
  bool _permissionStatus = false;
  bool _settingOpened = false;
  late AnimationController _animationController;
  late Animation<double> _loudnessAnimation;
  double _animatedLoudness = 0;
  Timer? _silenceTimer;
  final Duration _silenceTimeout = Duration(milliseconds: 500);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );

    _loudnessAnimation = Tween<double>(begin: 0, end: _loudness).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.elasticInOut,
      ),
    )..addListener(() {
      setState(() {
        _animatedLoudness = _loudnessAnimation.value;
      });
    });

    _loadPreferences().then((_) {
      _startRecording();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _animationController.dispose();
    _silenceTimer?.cancel();
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
    if(_isOnPitch) return td.colorScheme.primary;
    return Color.lerp(Colors.white, td.colorScheme.primary, accuracy / 100)!;
  }

  Color _getAccuracyColorReverse(double accuracy, ThemeData td) {
    return Color.lerp(td.colorScheme.primary, Colors.black, accuracy / 100)!;
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
      height: size.height * 0.026,
      width: size.width * 0.026,
      colorFilter: ColorFilter.mode(td.colorScheme.onSurface, BlendMode.srcIn),
    );
  }

  Widget _enabledRecordingButton(size, td) {
    return IconButton(
      icon: SvgPicture.asset(
        "assets/icons/microphone-2-svgrepo-com.svg",
        height: size.height * 0.034,
        width: size.width * 0.034,
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
        "assets/icons/microphone-2-svgrepo-com (1).svg",
        height: size.height * 0.034,
        width: size.width * 0.034,
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
              _noteSection(size, td),
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
      icon: SvgPicture.asset(
        "assets/icons/icons8-settings (1).svg",
        height: size.height * 0.04,
        width: size.width * 0.04,
        colorFilter: ColorFilter.mode(td.colorScheme.onSurface, BlendMode.srcIn),
      ),
      onPressed: _onPressedSettings,
    );
  }

  Widget _loudnessBar(size, ThemeData td) {
    int currentStep = _animatedLoudness.toInt();
    //debugPrint("[LOUDNESS] $_loudness");

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

  Widget _noteSection(size, td) {
    return Center(
      child: _permissionStatus
          ? Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: size.width*0.5,
            height: size.height*0.25,
            decoration: BoxDecoration(
              boxShadow: [(_rec && _selectedNote != "") ? _getAccuracyShadow(_accuracy.toDouble(), td) : UiUtils.widgetsShadow(1, 120, td)],
            ),
          ),
          //
          _rec ? (_selectedNote == "" ? _noDetectionLabel(size, td) : _noteLabel(size, td)) : _micOffLabel(size, td),
        ],
      )
          : _permissionsLabel(size, td),
    );
  }

  Widget _noDetectionLabel(Size size, ThemeData td) {
    return JumpingDots(
      color: td.colorScheme.onSurface,
      numberOfDots: 3,
      radius: size.width*0.02,
      innerPadding: size.width*0.05,
    );
  }

  Widget _micOffLabel(size, td) {
    return IconButton(
      icon: SvgPicture.asset(
        "assets/icons/vinyl-svgrepo-com.svg",
        height: size.height * 0.2,
        width: size.width * 0.2,
        colorFilter: ColorFilter.mode(td.colorScheme.primary, BlendMode.srcIn),
      ),
      onPressed: _onPressedSettings,
    );
  }

  Widget _noteLabel(Size size, ThemeData td) {
    return Text(
      "$_selectedNote$_selectedOctave",
      style: TextStyle(
        color: _getAccuracyColor(_accuracy.toDouble(), td),
        fontSize: size.width * 0.35,
        shadows: [UiUtils.widgetsShadowColor(80, 20, _getAccuracyColorReverse(_accuracy.toDouble(), td))],
      ),
    );
  }

  Widget _permissionsLabel(Size size, ThemeData td) {
    return SizedBox(
      width: size.width * 0.7,
      child: Center(
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
    return _permissionStatus ?
      Row(
        spacing: size.width * 0.05,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            _rec ? "${_selectedFrequency.toStringAsFixed(2)}Hz" : "0.0Hz",
            style: TextStyle(
              color: td.colorScheme.onSurface,
              fontSize: size.width * 0.038,
              shadows: [UiUtils.widgetsShadow(80, 20, td)],
            ),
          ),
          Text(
            _rec ? "${_accuracy.toStringAsFixed(2)}%" : "0%",
            style: TextStyle(
              color: td.colorScheme.onSurface,
              fontSize: size.width * 0.038,
              shadows: [UiUtils.widgetsShadow(80, 20, td)],
            ),
          ),
          Text(
            _rec ? "$_midiNote MIDI" : "0 MIDI",
            style: TextStyle(
              color: td.colorScheme.onSurface,
              fontSize: size.width * 0.038,
              shadows: [UiUtils.widgetsShadow(80, 20, td)],
            ),
          ),
        ],
      ) : Container();
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
      _selectedNote = "";
      _selectedOctave = "";
      _accuracy = 0;
      _loudness = 0;
      _samples = [];
    });
  }

  Future<void> _loadPreferences() async {
    await _loadFrequencyValues();
    await _getValues();

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _loadFrequencyValues() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _minFrequency = prefs.getDouble('minFrequency') ?? Constants.defaultMinFrequency;
      _maxFrequency = prefs.getDouble('maxFrequency') ?? Constants.defaultMaxFrequency;
      _selectedInstrument = prefs.getString('instrumentIcon') ?? Constants.defaultInstrumentIcon;
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

  Future<void> _getValues() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _sampleRate = prefs.getInt('sampleRate') ?? Constants.defaultSampleRate;
      _bufferSize = prefs.getInt('bufferSize') ?? Constants.defaultBufferSize;
      _precision = prefs.getDouble('precision') ?? Constants.defaultPrecision;
      _tolerance = prefs.getDouble('tolerance') ?? Constants.defaultTolerance;
      _isCleanWave = prefs.getBool('isCleanWave') ?? true;
    });
  }

  Future<void> _startRecording() async {
    WakelockPlus.enable();
    _getPermissionStatus();
    if(!_rec) {
      try {
        await _pitchDetector.startDetection();
        bool rec = await _pitchDetector.isRecording();

        setState(() {
          _rec = rec;
        });
        debugPrint("[START] Is Recording: $_rec");
        _pitchDetector.setParameters(toleranceCents: _tolerance, bufferSize: _bufferSize, sampleRate: _sampleRate, minPrecision: _precision);
        debugPrint(
            'PitchDetector Parameters -> '
                'toleranceCents: $_tolerance, '
                'bufferSize: $_bufferSize, '
                'sampleRate: $_sampleRate, '
                'minPrecision: $_precision'
        );

        _pitchSubscription = FlutterPitchDetectionPlatform.instance.onPitchDetected.listen((data) async {
          _silenceTimer?.cancel();
          final streamData = await _pitchDetector.getRawDataFromStream();
          final currentFrequency = data['frequency'] ?? 0;
          final octave = data['octave'] ?? 0;
          final sr = data['sampleRate'] ?? 0;
          final currentVolume = data['volume'] ?? 0;

          if (_selectedNote != "") {
            _animationController.stop();
            _loudnessAnimation = Tween<double>(
              begin: _animatedLoudness,
              end: currentVolume,
            ).animate(
              CurvedAnimation(
                parent: _animationController,
                curve: Curves.elasticInOut,
              ),
            )..addListener(() {
              setState(() {
                _animatedLoudness = _loudnessAnimation.value;
              });
            });
            _animationController.forward(from: 0);
          }

          _silenceTimer = Timer(_silenceTimeout, () {
            if (_selectedNote != "") {
              _animationController.stop();
              _loudnessAnimation = Tween<double>(
                begin: _animatedLoudness,
                end: 0,
              ).animate(
                CurvedAnimation(
                  parent: _animationController,
                  curve: Curves.easeOut,
                ),
              )..addListener(() {
                setState(() {
                  _animatedLoudness = _loudnessAnimation.value;
                });
              });
              _animationController.forward(from: 0);

              _resetPitchValues();
            }
          });

          if (currentFrequency > _minFrequency && currentFrequency < _maxFrequency) {
            final newNote = data['note'] ?? "";

            if (newNote.isNotEmpty && newNote != _selectedNote) {
              setState(() {
                _selectedNote = newNote;
                _midiNote = data['midiNote'] ?? 0;
                _selectedFrequency = currentFrequency;
                _selectedOctave = (octave?.clamp(0, 8).toString()) ?? "";
                _accuracy = data['accuracy'] ?? 0;
                _isOnPitch = data['isOnPitch'] ?? false;
              });

              _animationController.stop();
              _loudnessAnimation = Tween<double>(
                begin: _animatedLoudness,
                end: data['volume'] ?? 0,
              ).animate(
                CurvedAnimation(
                  parent: _animationController,
                  curve: Curves.easeOut,
                ),
              );
              _animationController.forward(from: 0);

              setState(() {
                _samples = _isCleanWave ? Utils.updateSamples(currentFrequency, sr) : streamData;
              });
            }
          } else {
            if (_selectedNote.isNotEmpty) {
              _resetPitchValues();
            }
          }
        });

      } catch (e) {
        debugPrint("Start Recording Error: $e");
      }
    }
  }

  Future<void> _stopRecording() async {
    WakelockPlus.disable();
    if(_rec) {
      try {
        _silenceTimer?.cancel();
        await _pitchSubscription?.cancel();
        _pitchSubscription = null;

        await _pitchDetector.stopDetection();
        setState(() {
          _rec = false;
        });

        debugPrint("[STOP] Is Recording: $_rec");
        _resetPitchValues();

      } catch(e) {
        debugPrint("Stop Recording Error: $e");
      }
    }
  }

  Future<void> _getPermissionStatus() async {
    PermissionStatus status = await Permission.microphone.status;


    _permissionStatus = status.isGranted;
    if(status.isPermanentlyDenied && !_settingOpened) {
      openAppSettings();
      _settingOpened = true;
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
