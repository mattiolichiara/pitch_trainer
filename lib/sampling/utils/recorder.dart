import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';

class Recorder {
  static final int sampleRate = 44100;
  static final int bitRate = 128000;

  static Future<void> startRecording(AudioRecorder recorder, Function? processAudio, Function? setRecordingState) async {
    try {
      Stream<Uint8List> stream = await recorder.startStream(
           RecordConfig(
              encoder: AudioEncoder.pcm16bits,
              sampleRate: sampleRate,
              bitRate: bitRate,
              noiseSuppress: true,));
      debugPrint("Stream Started");

      if(processAudio!=null) processAudio(stream);
      if(setRecordingState!=null) setRecordingState(true);

    } catch (e) {
      debugPrint("Start Recording Error: $e");
    }
  }

  static Future<void> resumeRecording(AudioRecorder recorder, Function? setRecordingState, Future<void>? startRecording) async {
    if(await recorder.isPaused()) {
      try {
        await recorder.resume();
        debugPrint("Recorder resumed...");
        if(setRecordingState!=null) setRecordingState(true);
      } catch(e) {
        debugPrint("Resume Recording Error: $e");
      }
    } else {
      if(startRecording!=null) startRecording;
    }
  }

  static Future<void> pauseRecording(AudioRecorder recorder, Function? resetValues) async {
    if(await recorder.isRecording()) {
      try {
        await recorder.pause();
        debugPrint("Recorder paused...");
        if(resetValues!=null) resetValues();
      } catch(e) {
        debugPrint("Pause Recording Error: $e");
      }
    }
  }

  static Future<void> stopRecording(AudioRecorder recorder, Function? resetValues) async {
    if(await recorder.isRecording()) {
      try {
        await recorder.stop();
        await recorder.cancel();
        recorder.dispose();
        debugPrint("Recorder stopped...");
        if(resetValues!=null) resetValues();
      } catch(e) {
        debugPrint("Stop Recording Error: $e");
      }
    }
  }

}