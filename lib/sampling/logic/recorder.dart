import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_fft/flutter_fft.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pitch_trainer/trashcan/sound_processing.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Recorder {
  static final Recorder _instance = Recorder._internal();
  FlutterFft? recorder;
  StreamSubscription<Uint8List>? _listenSubscription;
  late int sampleRate;
  late int bitRate;
  final int defaultSampleRate = 44100;
  final int defaultBitRate = 128000;
  bool permissionsAllowed = false;
  StreamController<Uint8List>? controller;
  bool isCleanWave = true;
  double accuracyThreshold = 1;

  Recorder._internal();

  factory Recorder() => _instance;

  Future<void> getValues() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    sampleRate = prefs.getInt('sampleRate') ?? defaultSampleRate;
    bitRate = prefs.getInt('bitRate') ?? defaultBitRate;
    isCleanWave = prefs.getBool('isCleanWave') ?? true;
    accuracyThreshold = prefs.getDouble("accuracyThreshold") ?? 1;
  }

  Future<bool> _requestPermissions() async {
    PermissionStatus status = await Permission.microphone.request();
    permissionsAllowed = status.isGranted;
    recorder ??= FlutterFft();
    debugPrint(permissionsAllowed ? "Microphone permission granted." : "Microphone permission denied.");
    return permissionsAllowed;
  }

  Future<void> initialize() async {
    await getValues();
  }

  Future<void> startRecording(Function? setRecordingState, double minFrequency, double maxFrequency, Function? setPitchValues, Function? resetPitchValues) async {
    if (!await _requestPermissions()) {
      debugPrint("Recording cannot start without permissions.");
      return;
    }

    try {
      recorder ??= FlutterFft();
      recorder!.setSampleRate = sampleRate;
      recorder!.setTolerance = accuracyThreshold;
      await recorder!.startRecorder();
      if (!recorder!.getIsRecording) {
        debugPrint("Recorder failed to start.");
        return;
      }
      debugPrint("Recording started...");

      processAudio(minFrequency, maxFrequency, setPitchValues, resetPitchValues);
      if (setRecordingState != null) setRecordingState(true);

    } catch (e) {
      debugPrint("Start Recording Error: $e");
    }
  }

  Future<void> processAudio(double minFrequency, double maxFrequency, Function? setPitchValues, Function? resetPitchValues) async {

    recorder!.onRecorderStateChanged.listen((data) {
      debugPrint("Changed state, received: $data");
      double frequency = data[1] as double;

      if(frequency <= maxFrequency && frequency >= minFrequency) {

        String note = data[2] as String;
        int octave = data[5] as int;
        note = "$note$octave";

        debugPrint("Data Type: ${data.runtimeType}");
        debugPrint("Is on Pitch: ${recorder!.getIsOnPitch}");
        debugPrint("Nearest Note: ${recorder!.getNearestNote}");
        debugPrint("Note: ${recorder!.getNote}");
        debugPrint("Tolerance: ${recorder!.getTolerance}");

        setPitchValues?.call(SoundProcessing.getClosestNoteFromFrequency(frequency), frequency, isCleanWave, [], 70);//TODO calculate loudness
      }
    },
      onError: (err) {
        Fluttertoast.showToast(
          msg: "Microphone Already In Use By Another App",
          gravity: ToastGravity.BOTTOM,
          backgroundColor: const Color.fromARGB(255, 70, 70, 70),
        );
        debugPrint("Error: $err");
      },
      onDone: () {
        debugPrint("Is done");
      },
    );

    // debugPrint("Listening...");
    //
    // _listenSubscription?.cancel();
    // Timer? zeroFrequencyTimer;
    // double previousFrequency = 0.0;
    //
    // _listenSubscription = stream.listen((data) {
    //   if (recorder!.) {
    //     //Future.delayed(Duration(milliseconds: 1000), () {
    //     List<double> convertedData = SoundProcessing.convertData(data);
    //
    //     //Energy-Based Noise Filtering (Skip Low Energy Signals)
    //     // double energy = convertedData.fold(0.0, (sum, val) => sum + val.abs()) / convertedData.length;
    //     // if (energy < 0.2) return;
    //
    //     double loudness = SoundProcessing.calculateLoudnessInDbSPL(convertedData);
    //
    //     double frequency = SoundProcessing.getDominantFrequency(convertedData, sampleRate, minFrequency, maxFrequency);
    //
    //     if (frequency == 0.0) {
    //       zeroFrequencyTimer ??= Timer(Duration(seconds: 3), () {
    //         resetPitchValues?.call();
    //       });
    //     } else {
    //       zeroFrequencyTimer?.cancel();
    //       zeroFrequencyTimer = null;
    //     }
    //
    //     //Frequency Smoothing (Ignore Quick Shifts)
    //     if(frequency==0.0) return;
    //     if(previousFrequency==frequency) return;
    //     if (frequency < minFrequency || frequency > maxFrequency) return;
    //     debugPrint("f: $frequency");
    //     previousFrequency = previousFrequency * 0.7 + frequency * 0.3;
    //     setPitchValues?.call(SoundProcessing.getClosestNoteFromFrequency(previousFrequency), previousFrequency, isCleanWave, convertedData, loudness);
    //   }
    // },
    //   onError: (error) => debugPrint("Error in stream: $error"),
    //   onDone: () => debugPrint("Stream Closed"),
    //   cancelOnError: true,
    // );
  }

  Future<void> stopRecording(Function? resetValues, Function? setRecordingState) async {
    if(recorder!.getIsRecording) {
      try {
        await recorder!.stopRecorder();

        resetValues?.call();
        setRecordingState?.call(false);

      } catch(e) {
        debugPrint("Stop Recording Exception: $e");
      }
    }
  }
}
