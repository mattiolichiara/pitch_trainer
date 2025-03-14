import 'dart:async';
import 'dart:typed_data';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Recorder {
  static late int sampleRate;
  static late int bitRate;
  static final int defaultSampleRate = 44100;
  static final int defaultBitRate = 128000;
  static StreamController<Uint8List>? _controller;

  static void _getValues() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    sampleRate = prefs.getInt('sampleRate') ?? defaultSampleRate;
    bitRate = prefs.getInt('bitRate') ?? defaultBitRate;
  }

  static Future<void> startRecording(FlutterSoundRecorder recorder, Function(Stream<Uint8List>) processAudio, Function? setRecordingState) async {
    _getValues();
    try {
      _controller = StreamController<Uint8List>();

      await recorder.startRecorder(
        toStream: _controller!.sink,
        codec: Codec.pcm16,
        sampleRate: sampleRate,
        enableVoiceProcessing: true
      );

      debugPrint("Recording started...");

      processAudio(_controller!.stream);

      if (setRecordingState != null) setRecordingState(true);
    } catch (e) {
      debugPrint("Start Recording Error: $e");
    }
  }

  static Future<void> resumeRecording(FlutterSoundRecorder recorder, Function? setRecordingState, Future<void>? startRecording) async {
    if(recorder.isPaused) {
      try {
        await recorder.resumeRecorder();
        debugPrint("Recorder resumed...");
        if(setRecordingState!=null) setRecordingState(true);
      } catch(e) {
        debugPrint("Resume Recording Error: $e");
      }
    } else {
      if(startRecording!=null) startRecording;
    }
  }

  static Future<void> pauseRecording(FlutterSoundRecorder recorder, Function? resetValues, Function? setRecordingState) async {
    if(recorder.isRecording) {
      try {
        await recorder.pauseRecorder();
        debugPrint("Recorder paused...");
        if(resetValues!=null) resetValues();
        if(setRecordingState!=null) setRecordingState(false);
      } catch(e) {
        debugPrint("Pause Recording Error: $e");
      }
    }
  }

  static Future<void> stopRecording(FlutterSoundRecorder recorder, Function? resetValues, Function? setRecordingState) async {
    if(recorder.isRecording) {
      try {
        await recorder.stopRecorder();
        recorder.closeRecorder();
        debugPrint("Recorder stopped...");
        if(resetValues!=null) resetValues();
        if(setRecordingState!=null) setRecordingState(false);
      } catch(e) {
        debugPrint("Stop Recording Error: $e");
      }
    }
  }

}