import 'dart:math';
import 'dart:core';
import 'package:complex/complex.dart';
import 'frequencies.dart';

class SoundProcessing {

  static List<Complex> convertToComplex(List<int> audioData) {
    return audioData.map((e) => Complex(e.toDouble(), 0.0)).toList();
  }

  static List<Complex> fft(List<Complex> input) {
    int n = input.length;

    if (n <= 1) return input;

    List<Complex> even = [];
    List<Complex> odd = [];
    for (int i = 0; i < n; i++) {
      if (i.isEven) {
        even.add(input[i]);
      } else {
        odd.add(input[i]);
      }
    }

    even = fft(even);
    odd = fft(odd);

    List<Complex> result = List.filled(n, Complex.zero);

    for (int k = 0; k < n ~/ 2; k++) {
      Complex t = Complex.polar(1.0, -2 * pi * k / n) * odd[k];
      result[k] = even[k] + t;
      result[k + n ~/ 2] = even[k] - t;
    }

    return result;
  }

  static int getPeakIndex(List<Complex> processedData) {
    int peakIndex = 0;
    double peakMagnitude = 0.0;
    for (int i = 1; i < processedData.length ~/ 2; i++) {
      double magnitude = processedData[i].abs();
      if (magnitude > peakMagnitude) {
        peakMagnitude = magnitude;
        peakIndex = i;
      }
    }

    return peakIndex;
  }

  static double getFrequency(int index, int sampleRate, int length) {
    return (index * sampleRate) / length.toDouble();
  }

  static String getClosestNoteFromFrequency(double frequency) {
    String closestNote = "";
    double closestFrequencyDiff = double.infinity;

    Frequencies.frequencies.forEach((note, freq) {
      double frequencyDiff = (frequency - freq).abs();
      if (frequencyDiff < closestFrequencyDiff) {
        closestFrequencyDiff = frequencyDiff;
        closestNote = note;
      }
    });

    return closestNote;
  }

  static double getNoteAccuracy(String selectedNote, double selectedFrequency) {
    double closestFrequency = Frequencies.frequencies[selectedNote] ?? 0.0;
    double accuracy = 0.0;

    if (closestFrequency != 0.0) {
      double frequencyDiff = selectedFrequency - closestFrequency;

      if (frequencyDiff.abs() < 2.0) {
        accuracy = 100.0 - frequencyDiff.abs();
      } else {
        accuracy = 0.0;
      }
    }
    return accuracy;
  }

  static List<double> updateSamples(double frequency) {
    const int sampleCount = 1024;
    const double sampleRate = 44100.0;
    List<double> newSamples = List.generate(sampleCount, (i) {
      double time = i / sampleRate;
      return sin(2 * pi * frequency * time);
    });

    return newSamples;
  }

}