import 'dart:async';
import 'dart:typed_data';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pitch_trainer/sampling/utils/sound_processing.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Recorder {
  static final Recorder _instance = Recorder._internal();
  FlutterSoundRecorder? recorder;
  StreamSubscription<Uint8List>? _listenSubscription;
  late int sampleRate;
  late int bitRate;
  final int defaultSampleRate = 44100;
  final int defaultBitRate = 128000;
  bool permissionsAllowed = false;
  StreamController<Uint8List>? controller;
  bool isCleanWave = true;

  Recorder._internal();

  factory Recorder() => _instance;

  Future<void> getValues() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    sampleRate = prefs.getInt('sampleRate') ?? defaultSampleRate;
    bitRate = prefs.getInt('bitRate') ?? defaultBitRate;
    isCleanWave = prefs.getBool('isCleanWave') ?? true;
  }

  Future<bool> _requestPermissions() async {
    PermissionStatus status = await Permission.microphone.request();
    permissionsAllowed = status.isGranted;
    debugPrint(permissionsAllowed ? "Microphone permission granted." : "Microphone permission denied.");
    return permissionsAllowed;
  }

  Future<void> initialize() async {
    if (recorder == null) {
      recorder = FlutterSoundRecorder();
      await recorder!.openRecorder();
    }
    await getValues();
  }

  Future<void> startRecording(Function? setRecordingState, double minFrequency, double maxFrequency, Function? setPitchValues, Function? resetPitchValues) async {
    if (!await _requestPermissions()) {
      debugPrint("Recording cannot start without permissions.");
      return;
    }
    if (recorder == null) {
      await initialize();
    }

    try {
      controller?.close();
      controller = StreamController<Uint8List>();

      await recorder!.startRecorder(
        toStream: controller!.sink,
        codec: Codec.pcm16,
        sampleRate: sampleRate,
        enableVoiceProcessing: true,
      );

      debugPrint("Recording started...");
      processAudio(controller!.stream, minFrequency, maxFrequency, setPitchValues, resetPitchValues);

      if (setRecordingState != null) setRecordingState(true);
    } catch (e) {
      debugPrint("Start Recording Error: $e");
    }
  }

  Future<void> processAudio(Stream<Uint8List> stream, double minFrequency, double maxFrequency, Function? setPitchValues, Function? resetPitchValues) async {
    debugPrint("Listening...");

    _listenSubscription?.cancel();
    Timer? zeroFrequencyTimer;
    double previousFrequency = 0.0;

    _listenSubscription = stream.listen((data) {
        if (recorder!.isRecording) {
          //Future.delayed(Duration(milliseconds: 1000), () {
          List<double> convertedData = SoundProcessing.convertData(data);

          //Energy-Based Noise Filtering (Skip Low Energy Signals)
          // double energy = convertedData.fold(0.0, (sum, val) => sum + val.abs()) / convertedData.length;
          // if (energy < 0.2) return;

          double loudness = SoundProcessing.calculateLoudnessInDbSPL(convertedData);

          double frequency = SoundProcessing.getDominantFrequency(convertedData, sampleRate, minFrequency, maxFrequency);

          if (frequency == 0.0) {
            zeroFrequencyTimer ??= Timer(Duration(seconds: 5), () {
              resetPitchValues?.call();
            });
          } else {
            zeroFrequencyTimer?.cancel();
            zeroFrequencyTimer = null;
          }

            //Frequency Smoothing (Ignore Quick Shifts)
            if(frequency==0.0) return;
            if(previousFrequency==frequency) return;
            debugPrint("f: $frequency");
            previousFrequency = previousFrequency * 0.7 + frequency * 0.3;

          if (previousFrequency >= minFrequency && previousFrequency <= maxFrequency) {
            setPitchValues?.call(SoundProcessing.getClosestNoteFromFrequency(previousFrequency), previousFrequency, isCleanWave, convertedData, loudness);
          }
        }
    },
      onError: (error) => debugPrint("Error in stream: $error"),
      onDone: () => debugPrint("Stream Closed"),
      cancelOnError: true,
    );
  }

  Future<void> resumeRecording(Function? setRecordingState) async {
    if (recorder != null && recorder!.isPaused) {
      try {
        await recorder!.resumeRecorder();
        debugPrint("Recorder resumed...");
        setRecordingState?.call(true);
      } catch (e) {
        debugPrint("Resume Recording Error: $e");
      }
    }
  }

  Future<void> pauseRecording(Function? resetValues, Function? setRecordingState) async {
    if (recorder != null && recorder!.isRecording) {
      try {
        await recorder!.pauseRecorder();
        debugPrint("Recorder paused...");
        resetValues?.call();
        setRecordingState?.call(false);
      } catch (e) {
        debugPrint("Pause Recording Error: $e");
      }
    }
  }

  Future<void> stopRecording(Function? resetValues, Function? setRecordingState) async {
    debugPrint("Recorder state before stopping: ${recorder?.isRecording}");
    if (recorder != null) {
      try {
        await recorder!.stopRecorder().catchError((e) {
          debugPrint("Error stopping recorder: $e");
        });
        await recorder!.closeRecorder();
        recorder = null;

        debugPrint("Recorder stopped.");

        if (_listenSubscription != null) {
          await _listenSubscription!.cancel();
          _listenSubscription = null;
          debugPrint("Stream subscription cancelled.");
        }

        if (controller != null && !controller!.isClosed) {
          await controller!.close().catchError((e) {
            debugPrint("Error closing StreamController: $e");
          });
          debugPrint("StreamController closed.");
        }
        debugPrint("StreamController is closed: ${controller?.isClosed}");
        controller = null;


        resetValues?.call();
        setRecordingState?.call(false);

      } catch (e) {
        debugPrint("Stop Recording Error: $e");
      }
    }
  }



  Future<void> close() async {
    await recorder?.closeRecorder();
    recorder = null;
    _listenSubscription?.cancel();
    _listenSubscription = null;
    controller?.close();
    controller = null;
    debugPrint("Recorder closed.");
  }
}
