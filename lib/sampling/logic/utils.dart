import 'dart:math';

class Utils {

  static List<double> updateSamples(double frequency, int sampleRate) {
    const int sampleCount = 1024;
    List<double> newSamples = List.generate(sampleCount, (i) {
      double time = i / sampleRate;
      return sin(2 * pi * frequency * time);
    });

    return newSamples;
  }
}
