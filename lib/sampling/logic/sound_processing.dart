import 'dart:core';
import 'dart:math';
import 'dart:typed_data';

import 'package:fftea/impl.dart';

import '../utils/frequencies.dart';

class SoundProcessing {

  static String getClosestNoteFromFrequency(double frequency) {
    String closestNote = "";
    double closestFrequencyDiff = double.infinity;//setto ad un cap massimo

    //for each note, the difference between the frequency retrieved and
    //the frequencies inside the map
    //the closest note is the one that has the least difference between the compared values in the map
    Frequencies.frequencies.forEach((note, freq) {
      double frequencyDiff = (frequency - freq).abs();
      if (frequencyDiff < closestFrequencyDiff) {
        closestFrequencyDiff = frequencyDiff;
        closestNote = note;
      }
    });

    return closestNote;
  }

  static double getNoteAccuracy(String selectedNote, double selectedFrequency, double accuracyThreshold) {
    //debugPrint("threshold $accuracyThreshold");
    double closestFrequency = Frequencies.frequencies[selectedNote] ?? 0.0;
    double accuracy = 0.0;

    if (closestFrequency != 0.0) {
      //get how "distant" the actual frequency is from the desired one
      double frequencyDiff = selectedFrequency - closestFrequency;

      //tolerance of 1.5hz
      if (frequencyDiff.abs() < accuracyThreshold) {
        accuracy = 100.0 - frequencyDiff.abs();
      } else {
        accuracy = 0.0; //if the difference is higher than num hz then the accuracy is none
      }
    }
    return accuracy;
  }

  static List<double> updateSamples(double frequency, int sampleRate) {
    const int sampleCount = 1024;
    List<double> newSamples = List.generate(sampleCount, (i) {
      double time = i / sampleRate;
      return sin(2 * pi * frequency * time);
    });

    return newSamples;
  }

}













