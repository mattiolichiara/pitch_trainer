import 'dart:async';
import 'dart:math';
import 'dart:typed_data';

import 'package:complex/complex.dart';
import 'package:flutter/material.dart';
import 'package:pitch_trainer/sampling/sampling_type.dart';
import 'package:pitch_trainer/sampling/utils/frequencies.dart';
import 'package:pitch_trainer/sampling/utils/recorder.dart';
import 'package:pitch_trainer/sampling/utils/sound_processing.dart';
import 'package:pitch_trainer/widgets/home_app_bar.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_audio_waveforms/flutter_audio_waveforms.dart';
import 'package:flutter_svg/svg.dart';
import 'package:linear_progress_bar/linear_progress_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:record/record.dart';

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
  late AudioRecorder _recorder;
  bool _isRecording = false;

  @override
  void initState() {
    super.initState();

    WidgetsFlutterBinding.ensureInitialized().addPostFrameCallback((_) async {
      await _loadFrequencyValues();
      debugPrint("Min: $_minFrequency - Max: $_maxFrequency");
    });

    _recorder = AudioRecorder();
    WidgetsBinding.instance.addObserver(this);
    _requestPermissions(_recorder);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _recorder.dispose();
    Recorder.stopRecording(_recorder, _resetPitchValues);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused || state == AppLifecycleState.detached || state == AppLifecycleState.hidden) {
      Recorder.pauseRecording(_recorder, _resetPitchValues);
    } else if (state == AppLifecycleState.resumed) {
      Recorder.resumeRecording(_recorder, _setRecordingState);
    }
  }

  //STYLE
  BoxShadow _widgetsShadow(double spreadRadius, double blurRadius) {
    return BoxShadow(
      color: const Color(0xFF9168B6),
      spreadRadius: spreadRadius,
      blurRadius: blurRadius,
      offset: const Offset(0, 1),
    );
  }

  Widget _progressBarStyle(size) {
    return Center(
      child: Container(
        width: 10,
        height: size.height * 0.0035,
        decoration: const BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.white,
                spreadRadius: 1,
                blurRadius: 15,
                offset: Offset(0, 1),
              )
            ]
        ),
      ),
    );
  }

  Widget _settingsIcon(size) {
    return SvgPicture.asset(
      "assets/icons/guitar-svgrepo-com.svg",
      height: size.height * 0.03,
      width: size.width * 0.03,
      colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
    );
  }

  Widget _enabledRecordingButton(size) {
    return IconButton(
      icon: SvgPicture.asset(
        "assets/icons/microphone-svgrepo-com.svg",
        height: size.height * 0.04,
        width: size.width * 0.04,
        colorFilter:
        const ColorFilter.mode(Colors.white, BlendMode.srcIn),
      ),
      onPressed: () {
        Recorder.pauseRecording(_recorder, _resetPitchValues);
      },
    );
  }

  Widget _disabledRecordingButton(size) {
    return IconButton(
      icon: SvgPicture.asset(
        "assets/icons/microphone-slash-svgrepo-com.svg",
        height: size.height * 0.04,
        width: size.width * 0.04,
        colorFilter:
        const ColorFilter.mode(Colors.white, BlendMode.srcIn),
      ),
      onPressed: () {
        Recorder.resumeRecording(_recorder, _setRecordingState);
      },
    );
  }

  //WIDGETS
  Widget _mainCard(size) {
    return Card.outlined(
      shadowColor: const Color(0xFF9168B6),
      color: const Color(0xFF252525),
      child: Center(
        child: SizedBox(
          height: size.height * 0.85,
          width: size.width * 0.9,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _noteLabel(size),
              _frequencyBar(size),
              _soundWave(size),
            ],
          ),
        ),
      ),
    );
  }

  Widget _settings(size) {
    return IconButton(
      icon: _settingsIcon(size),
      onPressed: _onPressedSettings,
    );
  }

  Widget _accuracyBar(size) {
    //Color purpleLerpy = Color.lerp(const Color(0xFF9168B6), Colors.white, 0.65)!;
    Color greyLerpy = Color.lerp(const Color(0xFF252428), Colors.white, 0.20)!;

    int currentStep = ((_accuracy + 100) / 200 * 100).round();

    return Container(
      decoration: BoxDecoration(
        color: greyLerpy,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Stack(
        children: [
          _progressBar(size, currentStep, greyLerpy),
          _progressBarStyle(size),
        ],
      ),
    );
  }

  Widget _soundWave(size) {
    Color waveColor = const Color(0xFF9168B6);

    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          _widgetsShadow(1, 45)
        ],
      ),
      child: CurvedPolygonWaveform(
        strokeWidth: 0.6,
        style: PaintingStyle.stroke,
        activeColor: Color.lerp(waveColor, Colors.white, 0.35)!,
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

  Widget _noteLabel(size) {
    return Center(
        child: _isPermissionAllowed == true
            ? Text(
          "$_selectedNote$_selectedOctave",
          style: TextStyle(
            color: Colors.white,
            fontSize: size.width * 0.35,
            shadows: [
              _widgetsShadow(80, 20),
            ],
          ),
        )
            : Text(
          "Allow Microphone Access To Use The App",
          style: TextStyle(
            color: Colors.white,
            fontSize: size.width * 0.04,
            shadows: [
              _widgetsShadow(80, 20),
            ],
          ),
        ));
  }

  Widget _frequencyBar(size) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          _isPermissionAllowed == true
              ? "${_selectedFrequency.toStringAsFixed(2)} HZ"
              : "",
          style: TextStyle(
            color: Colors.white,
            fontSize: size.width * 0.038,
            shadows: [
              _widgetsShadow(80, 20),
            ],
          ),
        ),
        Text(
          _isPermissionAllowed == true
              ? "            ${_accuracy.toStringAsFixed(2)}"
              : "",
          style: TextStyle(
            color: Colors.white,
            fontSize: size.width * 0.038,
            shadows: [
              _widgetsShadow(80, 20),
            ],
          ),
        ),
      ],
    );
  }

  Widget _startStopRecording(size) {
    Widget action;

    (_isRecording == true)
        ? action = _enabledRecordingButton(size)
        : action = _disabledRecordingButton(size);

    return action;
  }

  Widget _progressBar(size, currentStep, greyLerpy) {
    return LinearProgressBar(
      maxSteps: 100,
      progressType: LinearProgressBar.progressTypeLinear,
      currentStep: currentStep.clamp(0, 100),
      progressColor: Colors.white,
      backgroundColor: greyLerpy,
      dotsAxis: Axis.horizontal,
      valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
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
      _setRecordingState(false);
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

  Future<void> _loadFrequencyValues() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _minFrequency = prefs.getDouble('minFrequency') ?? 27.50;
      _maxFrequency = prefs.getDouble('maxFrequency') ?? 4186.01;
    });
  }

  void _onPressedSettings() {
    Recorder.stopRecording(_recorder, _resetPitchValues);
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => const SamplingType(),
    ));
  }

  Future<void> _requestPermissions(AudioRecorder recorder) async {
    PermissionStatus audio = await Permission.microphone.request();
    if(await recorder.hasPermission() && !audio.isDenied) {
      setState(() {
        _isPermissionAllowed = true;
        Recorder.startRecording(_recorder, _processAudio, _setRecordingState);
      });
    } else {
      setState(() async {
        _isPermissionAllowed = false;
        if(await recorder.isRecording()) {
          Recorder.stopRecording(_recorder, _resetPitchValues);
        }
      });
    }
  }

  Future<void> _processAudio(Stream<Uint8List> stream) async {
    debugPrint("Listening...");
    debugPrint("Max: $_maxFrequency - Min: $_minFrequency");

    stream.listen((data) {
      List<Complex> processedData = SoundProcessing.fft(SoundProcessing.convertToComplex(data));
      double frequency = SoundProcessing.getFrequency(SoundProcessing.getPeakIndex(processedData), 837202, data.length);
      String note = SoundProcessing.getClosestNoteFromFrequency(frequency);

      debugPrint("NOTE: $note, FREQUENCY: $frequency");
      if (frequency >= _minFrequency && frequency <= _maxFrequency) {
        _setPitchValues(note, frequency);
      }
    });
  }

  //BUILD
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return PopScope(
      canPop: false,
      onPopInvoked: (pop) async {},
      child: Scaffold(
        appBar: HomeAppBar(
          title: 'Pitch Trainer',
          isHome: true,
          action1: _startStopRecording(size),
          action2: _settings(size),
          action3: Container(),
        ),
        body: Column(
          children: [
            SizedBox(
              height: size.height * 0.001,
            ),
            _isRecording? _accuracyBar(size) : Container(),
            Expanded(
              child: Center(
                child: Container(
                  height: size.height * 0.85,
                  width: size.width * 0.9,
                  decoration: BoxDecoration(
                    boxShadow: [
                      _widgetsShadow(2, 20),
                    ],
                  ),
                  child: _mainCard(size),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}