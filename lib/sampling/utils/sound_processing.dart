import 'dart:math';
import 'dart:core';
import 'dart:typed_data';
import 'package:complex/complex.dart';
import 'package:fftea/impl.dart';
import 'package:flutter/material.dart';
import 'frequencies.dart';

class SoundProcessing {

  static Uint8List applyBasicFilter(Uint8List samples, int sampleRate) {
    const int highPassThreshold = 150;
    const int lowPassThreshold = 4000;

    double rcHigh = 1.0 / (2 * pi * highPassThreshold);
    double dt = 1.0 / sampleRate;
    double alphaHigh = rcHigh / (rcHigh + dt);

    double rcLow = 1.0 / (2 * pi * lowPassThreshold);
    double alphaLow = dt / (rcLow + dt);

    Uint8List filtered = Uint8List(samples.length);
    double lastHigh = 0;
    double lastLow = 0;

    for (int i = 0; i < samples.length; i++) {
      int currentSample = samples[i] - 128;
      int previousSample = (i > 0) ? (samples[i - 1] - 128) : 0;

      double high = alphaHigh * (lastHigh + currentSample - previousSample);
      lastHigh = high;

      lastLow = lastLow + alphaLow * (high - lastLow);

      int outputSample = (lastLow + 128).round().clamp(0, 255);
      filtered[i] = outputSample;
    }

    return filtered;
  }

  // Args -> List of 8bit unsigned integers ranging 0-255
  // Return type is a List of double -> it represents the PCM samples
  // a.k.a. Pulse Code Modulation
  // They're normalized between -1 anc 1
  static List<double> convertData(Uint8List data, {double amplitudeThreshold = 0.12}) {
    // subListView allows to read bytes as integers
    ByteData byteData = ByteData.sublistView(data);
    List<double> pcmSamples = [];

    //It increments by 2 -> each PCM sample is saved as a 16-bit int
    //(2 bytes per sample)
    for(int i = 0; i < byteData.lengthInBytes; i += 2) {
      //reads 2 bytes at a time in position i
      //Little Endian (less significant byte firts) -> e.g. wav -> most used with audio procesing
      //Possible values: -32768 to 32767 -> standard range for 16-bit PCM audio
      //PCM sarebbe e' l'ampiezza del suono o la sound wave, la loudness
      //0 is silence, 32767 is Compression (spinta dello speaker in avanti), -32767 Rarefaction (indietro)
      //Quindi e' come vibra effettivamente il suono
      int sample = byteData.getInt16(i, Endian.little);

      //normalization (-32768 -> -1 ~ 0 -> 0 ~ 32767 -> 1)
      //si normalizza perche' cosi' hai un range compatibile con DSP -> standard
      //DSP = Digital Signal Processing int16sample/32768
      double normalizedSample = sample / 32768.0;

      //Noise removal -> if amplitude is 0.02 eg then sounds that less loud than 2% are not gonna be detected
      //Amplitude Treshold
      if (normalizedSample.abs() < amplitudeThreshold) {
        normalizedSample = 0.0; //low noise will considered as silence
      }

      pcmSamples.add(normalizedSample);
    }
    return pcmSamples;
  }

  static List<double> applyMedianFilter(List<double> samples, {int windowSize = 5}) {
    List<double> filtered = List.from(samples);
    int halfWindow = windowSize ~/ 2;

    for (int i = halfWindow; i < samples.length - halfWindow; i++) {
      List<double> window = samples.sublist(i - halfWindow, i + halfWindow + 1);
      window.sort();
      filtered[i] = window[halfWindow];
    }
    return filtered;
  }


  //A moving average filter smooths out variations in the signal, reducing noise. The weighted version gives more importance to recent values.
  static List<double> applyWeightedMovingAverage(List<double> samples, {int windowSize = 7}) {
    List<double> smoothedSamples = List.filled(samples.length, 0.0);

    for (int i = 0; i < samples.length; i++) {
      double sum = 0.0;
      double weightSum = 0.0;

      for (int j = 0; j < windowSize; j++) {
        int index = i - j;
        if (index < 0) break; // Avoid negative indices

        double weight = (windowSize - j).toDouble(); // More weight to recent values
        sum += samples[index] * weight;
        weightSum += weight;
      }

      smoothedSamples[i] = sum / weightSum; // Normalize by weight sum
    }

    return smoothedSamples;
  }

  //A noise gate ensures that only signals above a threshold (for a consistent duration) are kept.
  //Instead of a fixed amplitude threshold, you can adapt it to the average energy of a sliding window of samples.
  static List<double> applyDynamicNoiseGate(List<double> samples, {double baseThreshold = 0.05, int windowSize = 4410}) {
    List<double> gatedSamples = List.filled(samples.length, 0.0);

    for (int i = 0; i < samples.length; i++) {
      // Calculate local average energy
      int start = (i - windowSize ~/ 2).clamp(0, samples.length - 1);
      int end = (i + windowSize ~/ 2).clamp(0, samples.length - 1);
      double localEnergy = 0.0;

      for (int j = start; j < end; j++) {
        localEnergy += samples[j].abs();
      }
      localEnergy /= (end - start + 1);

      // Adaptive threshold
      double dynamicThreshold = baseThreshold + (localEnergy * 0.5); // adjust multiplier

      if (samples[i].abs() >= dynamicThreshold) {
        gatedSamples[i] = samples[i];
      }
    }

    return gatedSamples;
  }

  //reduce spectral leakage (false frequencies bleeding into spectrum).
  static List<double> applyHammingWindow(List<double> samples) {
    int N = samples.length;
    for (int n = 0; n < N; n++) {
      samples[n] *= 0.54 - 0.46 * cos(2 * pi * n / (N - 1));
    }
    return samples;
  }

  //It takes as input the normalized signal
  //also sample rate which is the number of samples * second
  //It returns the dominant (most present or strongest) frequency
  static double getDominantFrequency(List<double> samples, int sampleRate, double minFrequency, double maxFrequency) {
    FFT fft = FFT(samples.length); //init -> oggetto fft grane quanto il segnale in input
    var spectrum = fft.realFft(samples);//returns a list of complex numers (numeri immaginari)
    //each complex number represents different frequncy components
    //fft scompone un segnale in sinusoidi -> ogni bin index e' una frequenza specifica

    int maxIndex = 0;//indice dove si trova la frequenza interessata
    double maxValue = 0.0;//frequenza con maggiore energia

    //The second half of the of the array is not useful
    //FFTs results are symmetrical and specular
    for(int i = 0; i < spectrum.length ~/ 2; i++) {//x reale y immaginario
      double real = spectrum[i].x;
      double imaginary = spectrum[i].y;
      //sqrt(real^2 + imaginary^2) -> euclindean norm -> quanto forte una frequenza nel segnale
      double magnitude = sqrt(real * real + imaginary * imaginary);

      if (magnitude > maxValue) { //mantengo indice e valore piu' alto
        maxValue = magnitude;
        maxIndex = i;
      }
      debugPrint("Sample Rate: $sampleRate");
      debugPrint("samples.length: ${samples.length}");
      debugPrint("maxIndex: $maxIndex");
      debugPrint("Magnitude: $magnitude");
    }

    //frequenza = bin index*sample rate/grandezza fft
    //un bin index e' un range di frequenze, che va convertito in frequenza
    //Nyquist frequency -> rileva frequenze da 0 alla meta' del sample rate
    double dominantFrequency = maxIndex * sampleRate / samples.length;

    if (dominantFrequency < minFrequency) {
      dominantFrequency = minFrequency;
    } else if (dominantFrequency > maxFrequency) {
      dominantFrequency = maxFrequency;
    }

    return dominantFrequency;
  }

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

  static double getNoteAccuracy(String selectedNote, double selectedFrequency) {
    double closestFrequency = Frequencies.frequencies[selectedNote] ?? 0.0;
    double accuracy = 0.0;

    if (closestFrequency != 0.0) {
      //get how "distant" the actual frequency is from the desired one
      double frequencyDiff = selectedFrequency - closestFrequency;

      //tolerance of 1.5hz
      if (frequencyDiff.abs() < 1.5) {//TODO permettere la modifica del accuracy accettabile
        accuracy = 100.0 - frequencyDiff.abs();
      } else {
        accuracy = 0.0; //if the difference is higher than 1.5hz then the accuracy is none
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













// static List<Complex> convertToComplex(List<int> audioData) {
//   return audioData.map((e) => Complex(e.toDouble(), 0.0)).toList();
// }
//
// static List<Complex> fft(List<Complex> input) {
//   int n = input.length;
//
//   if (n <= 1) return input;
//
//   List<Complex> even = [];
//   List<Complex> odd = [];
//   for (int i = 0; i < n; i++) {
//     if (i.isEven) {
//       even.add(input[i]);
//     } else {
//       odd.add(input[i]);
//     }
//   }
//
//   even = fft(even);
//   odd = fft(odd);
//
//   List<Complex> result = List.filled(n, Complex.zero);
//
//   for (int k = 0; k < n ~/ 2; k++) {
//     Complex t = Complex.polar(1.0, -2 * pi * k / n) * odd[k];
//     result[k] = even[k] + t;
//     result[k + n ~/ 2] = even[k] - t;
//   }
//
//   return result;
// }