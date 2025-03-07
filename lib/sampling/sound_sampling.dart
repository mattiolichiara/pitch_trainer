import 'dart:async';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:pitch_trainer/sampling/sampling_type.dart';
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
  late StreamSubscription<Uint8List>? _audioStreamSubscription;
  bool isRecording = false;

  @override
  void initState() {
    super.initState();

    WidgetsFlutterBinding.ensureInitialized().addPostFrameCallback((_) async {
      await _loadFrequencyValues();
      debugPrint("Min: $_minFrequency - Max: $_maxFrequency");
    });

    _recorder = AudioRecorder();
    WidgetsBinding.instance.addObserver(this);
    _requestPermissions();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _recorder.dispose();
    _stopRecording();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused || state == AppLifecycleState.detached || state == AppLifecycleState.hidden) {
      _pauseRecording();
    } else if (state == AppLifecycleState.resumed) {
      _resumeRecording();
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
        _pauseRecording();
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
        _resumeRecording();
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
              _noteOctaveText(size),
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

  Widget _noteOctaveText(size) {
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

  //FUNCTIONAL WIDGETS
  Widget _startStopRecording(size) {
    Widget action;

    (isRecording == true)
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
  void _onPressedSettings() {
    _stopRecording();
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => const SamplingType(frequencies: frequencies,),
    ));
  }

  Future<void> _loadFrequencyValues() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _minFrequency = prefs.getDouble('minFrequency') ?? 27.50;
      _maxFrequency = prefs.getDouble('maxFrequency') ?? 4186.01;
    });
  }

  Future<void> _requestPermissions() async {
    PermissionStatus audio = await Permission.microphone.request();
    if(await _recorder.hasPermission() && !audio.isDenied) {
      setState(() {
        _isPermissionAllowed = true;
        _startRecording();
      });
    } else {
      setState(() async {
        _isPermissionAllowed = false;
        if(await _recorder.isRecording()) {
          _stopRecording();
        }
      });
    }
  }

  String _getClosestNoteFromFrequency(double frequency) {
    String closestNote = "";
    double closestFrequencyDiff = double.infinity;

    frequencies.forEach((note, freq) {
      double frequencyDiff = (frequency - freq).abs();
      if (frequencyDiff < closestFrequencyDiff) {
        closestFrequencyDiff = frequencyDiff;
        closestNote = note;
      }
    });

    return closestNote;
  }

  Future<void> _stopRecording() async {
    if(await _recorder.isRecording()) {
      try {
        await _recorder.stop();
        await _recorder.cancel();
        _recorder.dispose();
        debugPrint("Recorder stopped...");
        setState(() {
          _selectedFrequency = 0.0;
          _selectedNote = "-";
          _selectedOctave = "";
          _accuracy = 0.0;
          _samples = [];
          isRecording = false;
        });
      } catch(e) {
        debugPrint("Stop Recording Error: $e");
      }
    }
  }

  Future<void> _pauseRecording() async {
    if(await _recorder.isRecording()) {
      try {
        await _recorder.pause();
        debugPrint("Recorder paused...");
        setState(() {
          _selectedFrequency = 0.0;
          _selectedNote = "-";
          _selectedOctave = "";
          _accuracy = 0.0;
          _samples = [];
          isRecording = false;
        });
      } catch(e) {
        debugPrint("Pause Recording Error: $e");
      }
    }
  }

  Future<void> _resumeRecording() async {
    if(await _recorder.isPaused()) {
      try {
        await _recorder.resume();
        debugPrint("Recorder resumed...");
        setState(() {
          isRecording = true;
        });
      } catch(e) {
        debugPrint("Resume Recording Error: $e");
      }
    }
  }

  Future<void> _startRecording() async {
    try {
      Stream<Uint8List> stream = await _recorder.startStream(
          const RecordConfig(
              encoder: AudioEncoder.pcm16bits,
              sampleRate: 44100,
              noiseSuppress: true,
              bitRate: 12800));
      debugPrint("Stream Started");
      setState(() {
        isRecording = true;
      });

      _processAudio(stream);

    } catch (e) {
      debugPrint("Start Recording Error: $e");
    }
  }

  Future<void> _processAudio(Stream<Uint8List> stream) async {
    _audioStreamSubscription = stream.listen((data) {
      debugPrint("Listening...");

    });
  }

  //_audioStreamSubscription = stream
  //     await _fft.startRecorder();
  //     print("Recorder started...");
  //     setState(() {
  //       debugPrint("Is Recording? ${_fft.getIsRecording}");
  //     });
  //   } catch(e) {
  //     debugPrint("Start Recording Exception: $e");
  //   }
  //
  //   _fft.onRecorderStateChanged.listen((data) {
  //     print("Changed state, received: $data");
  //     setState(
  //           () {
  //         double frequency = data[1] as double;
  //
  //         //loadFrequencyValues();
  //         debugPrint("Max: $maxFrequency - Min: $minFrequency");
  //         if(frequency <= maxFrequency && frequency >= minFrequency) {
  //
  //           String note = data[2] as String;
  //           int octave = data[5] as int;
  //
  //           String correctedNote = _getClosestNoteFromFrequency(frequency);
  //
  //           if (correctedNote.contains("#")) {
  //             selectedNote = correctedNote[0] + correctedNote[1];
  //             selectedOctave = correctedNote[2];
  //           } else {
  //             selectedNote = correctedNote[0];
  //             selectedOctave = correctedNote[1];
  //           }
  //
  //           selectedFrequency = frequency;
  //           // selectedNote = note;
  //           // selectedOctave = octave.toString();
  //
  //           _getNoteAccuracy(selectedNote, selectedOctave, selectedFrequency);
  //
  //           _updateSamples(selectedFrequency);
  //
  //           // _fft.setNote = selectedNote;
  //           // _fft.setFrequency = selectedFrequency;
  //           // _fft.setOctave = int.parse(selectedOctave);
  //           debugPrint("Samples: ${samples.length} - $samples - ${samples.last}");
  //
  //         }
  //       },
  //     );
  //   }, onError: (err) {
  //     Fluttertoast.showToast(msg: "Microphone Already In Use By Another App", gravity: ToastGravity.BOTTOM, backgroundColor: const Color.fromARGB(255, 70,70,70));
  //     print("Error: $err");
  //   }, onDone: () => {
  //     print("Isdone"),
  //   },
  //   );


  void _updateSamples(double frequency) {
    const int sampleCount = 1024;
    const double sampleRate = 44100.0;
    List<double> newSamples = List.generate(sampleCount, (i) {
      double time = i / sampleRate;
      return sin(2 * pi * frequency * time);
    });

    setState(() {
      _samples = newSamples;
    });
  }

  double _getNoteAccuracy(String selectedNote, String selectedOctave, double selectedFrequency) {
    String note = "$selectedNote$selectedOctave";
    double closestFrequency = frequencies[note] ?? 0.0;

    if (closestFrequency != 0.0) {
      double frequencyDiff = selectedFrequency - closestFrequency;

      if (frequencyDiff.abs() < 1.0) {
        _accuracy = 0.0;
      } else if (selectedFrequency < closestFrequency) {
        _accuracy = -100 + (frequencyDiff.abs() / closestFrequency * 100);
      } else {
        _accuracy = 100 - (frequencyDiff.abs() / closestFrequency * 100);
      }

      setState(() {
        _accuracy = _accuracy.clamp(-100.0, 100.0);
      });

      print("Accuracy: ${_accuracy.toStringAsFixed(2)}%");
      return _accuracy;
    }
    print("Not Recognized");
    return 0.0;
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
            isRecording? _accuracyBar(size) : Container(),
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

  static const Map<String, double> frequencies = {
    'A0': 27.50,
    'A#0': 29.14,
    'B0': 30.87,
    'C1': 32.70,
    'C#1': 34.65,
    'D1': 36.71,
    'D#1': 38.89,
    'E1': 41.20,
    'F1': 43.65,
    'F#1': 46.25,
    'G1': 49.00,
    'G#1': 51.91,
    'A1': 55.00,
    'A#1': 58.27,
    'B1': 61.74,
    'C2': 65.41,
    'C#2': 69.30,
    'D2': 73.42,
    'D#2': 77.78,
    'E2': 82.41,
    'F2': 87.31,
    'F#2': 92.50,
    'G2': 98.00,
    'G#2': 103.83,
    'A2': 110.00,
    'A#2': 116.54,
    'B2': 123.47,
    'C3': 130.81,
    'C#3': 138.59,
    'D3': 146.83,
    'D#3': 155.56,
    'E3': 164.81,
    'F3': 174.61,
    'F#3': 185.00,
    'G3': 196.00,
    'G#3': 207.65,
    'A3': 220.00,
    'A#3': 233.08,
    'B3': 246.94,
    'C4': 261.63,
    'C#4': 277.18,
    'D4': 293.66,
    'D#4': 311.13,
    'E4': 329.63,
    'F4': 349.23,
    'F#4': 369.99,
    'G4': 392.00,
    'G#4': 415.30,
    'A4': 440.00,
    'A#4': 466.16,
    'B4': 493.88,
    'C5': 523.25,
    'C#5': 554.37,
    'D5': 587.33,
    'D#5': 622.25,
    'E5': 659.26,
    'F5': 698.46,
    'F#5': 739.99,
    'G5': 783.99,
    'G#5': 830.61,
    'A5': 880.00,
    'A#5': 932.33,
    'B5': 987.77,
    'C6': 1046.50,
    'C#6': 1108.73,
    'D6': 1174.66,
    'D#6': 1244.51,
    'E6': 1318.51,
    'F6': 1396.91,
    'F#6': 1479.98,
    'G6': 1567.98,
    'G#6': 1661.22,
    'A6': 1760.00,
    'A#6': 1864.66,
    'B6': 1975.53,
    'C7': 2093.00,
    'C#7': 2217.46,
    'D7': 2349.32,
    'D#7': 2489.02,
    'E7': 2637.02,
    'F7': 2793.83,
    'F#7': 2959.96,
    'G7': 3135.96,
    'G#7': 3322.44,
    'A7': 3520.00,
    'A#7': 3729.31,
    'B7': 3951.07,
    'C8': 4186.01,
  };
}
