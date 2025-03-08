import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';

class Recorder {

  static Future<void> startRecording(AudioRecorder recorder, Function? processAudio, Function? setRecordingState) async {
    try {
      Stream<Uint8List> stream = await recorder.startStream(
          const RecordConfig(
              encoder: AudioEncoder.pcm16bits,
              sampleRate: 200,//44100
              bitRate: 128000,
              noiseSuppress: true));
      debugPrint("Stream Started");

      if(processAudio!=null) processAudio(stream);
      if(setRecordingState!=null) setRecordingState(true);

    } catch (e) {
      debugPrint("Start Recording Error: $e");
    }
  }

  static Future<void> resumeRecording(AudioRecorder recorder, Function? setRecordingState) async {
    if(await recorder.isPaused()) {
      try {
        await recorder.resume();
        debugPrint("Recorder resumed...");
        if(setRecordingState!=null) setRecordingState(true);
      } catch(e) {
        debugPrint("Resume Recording Error: $e");
      }
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