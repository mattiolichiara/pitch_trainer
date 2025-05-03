// import 'dart:core';
// import 'dart:math';
// import 'dart:typed_data';
//
// import '../sampling/cubit/frequencies.dart';
//
// class SoundProcessing {
//
//   // Args -> List of 8bit unsigned integers ranging 0-255
//   // Return type is a List of double -> it represents the PCM samples
//   // a.k.a. Pulse Code Modulation
//   // They're normalized between -1 anc 1
//   static List<double> convertData(Uint8List data, {double amplitudeThreshold = 0.12}) {
//     // subListView allows to read bytes as integers
//     ByteData byteData = ByteData.sublistView(data);
//     List<double> pcmSamples = [];
//
//     //It increments by 2 -> each PCM sample is saved as a 16-bit int
//     //(2 bytes per sample)
//     for(int i = 0; i < byteData.lengthInBytes; i += 2) {
//       //reads 2 bytes at a time in position i
//       //Little Endian (less significant byte firts) -> e.g. wav -> most used with audio procesing
//       //Possible values: -32768 to 32767 -> standard range for 16-bit PCM audio
//       //PCM sarebbe e' l'ampiezza del suono o la sound wave, la loudness
//       //0 is silence, 32767 is Compression (spinta dello speaker in avanti), -32767 Rarefaction (indietro)
//       //Quindi e' come vibra effettivamente il suono
//       int sample = byteData.getInt16(i, Endian.little);
//
//       //normalization (-32768 -> -1 ~ 0 -> 0 ~ 32767 -> 1)
//       //si normalizza perche' cosi' hai un range compatibile con DSP -> standard
//       //DSP = Digital Signal Processing int16sample/32768
//       double normalizedSample = sample / 32768.0;
//
//       //Noise removal -> if amplitude is 0.02 eg then sounds that less loud than 2% are not gonna be detected
//       //Amplitude Treshold
//       if (normalizedSample.abs() < amplitudeThreshold) {
//         normalizedSample = 0.0; //low noise will considered as silence
//       }
//
//       pcmSamples.add(normalizedSample);
//     }
//     return pcmSamples;
//   }
//
//   static double calculateLoudnessInDbSPL(List<double> samples) {
//     if (samples.isEmpty) return 0.0; // Silence
//
//     const double referencePressure = 20e-6; // Reference sound pressure (20 µPa)
//     const double epsilon = 1e-12; // Small value to prevent log(0)
//
//     // Calculate RMS
//     double rms = sqrt(samples.map((s) => s * s).reduce((a, b) => a + b) / samples.length);
//
//     // Convert to dB SPL
//     double dbSPL = 20 * log(max(rms / referencePressure, epsilon)) / ln10;
//
//     return dbSPL.clamp(0, 140); // Within a realistic range
//   }
//
//   //It takes as input the normalized signal
//   //also sample rate which is the number of samples * second
//   //It returns the dominant (most present or strongest) frequency
//   static double getDominantFrequency(List<double> samples, int sampleRate, double minFrequency, double maxFrequency) {
//     FFT fft = FFT(samples.length); //init -> oggetto fft grane quanto il segnale in input
//     var spectrum = fft.realFft(samples);//returns a list of complex numers (numeri immaginari)
//     //each complex number represents different frequncy components
//     //fft scompone un segnale in sinusoidi -> ogni bin index e' una frequenza specifica
//
//     int maxIndex = 0;//indice dove si trova la frequenza interessata
//     double maxValue = 0.0;//frequenza con maggiore energia
//
//     //The second half of the of the array is not useful
//     //FFTs results are symmetrical and specular
//     for(int i = 0; i < spectrum.length ~/ 2; i++) {//x reale y immaginario
//       double real = spectrum[i].x;
//       double imaginary = spectrum[i].y;
//       //sqrt(real^2 + imaginary^2) -> euclindean norm -> quanto forte una frequenza nel segnale
//       double magnitude = sqrt(real * real + imaginary * imaginary);
//
//       if (magnitude > maxValue) { //mantengo indice e valore piu' alto
//         maxValue = magnitude;
//         maxIndex = i;
//       }
//       // debugPrint("Sample Rate: $sampleRate");
//       // debugPrint("samples.length: ${samples.length}");
//       // debugPrint("maxIndex: $maxIndex");
//       // debugPrint("Magnitude: $magnitude");
//     }
//
//     //frequenza = bin index*sample rate/grandezza fft
//     //un bin index e' un range di frequenze, che va convertito in frequenza
//     //Nyquist frequency -> rileva frequenze da 0 alla meta' del sample rate
//     double dominantFrequency = maxIndex * sampleRate / samples.length;
//
//     // if (dominantFrequency < minFrequency) {
//     //   dominantFrequency = minFrequency;
//     // } else
//     if (dominantFrequency > maxFrequency) {
//       dominantFrequency = maxFrequency;
//     }
//
//     return dominantFrequency;
//   }
//
//   static String getClosestNoteFromFrequency(double frequency) {
//     String closestNote = "";
//     double closestFrequencyDiff = double.infinity;//setto ad un cap massimo
//
//     //for each note, the difference between the frequency retrieved and
//     //the frequencies inside the map
//     //the closest note is the one that has the least difference between the compared values in the map
//     Frequencies.frequencies.forEach((note, freq) {
//       double frequencyDiff = (frequency - freq).abs();
//       if (frequencyDiff < closestFrequencyDiff) {
//         closestFrequencyDiff = frequencyDiff;
//         closestNote = note;
//       }
//     });
//
//     return closestNote;
//   }
//
//   static double getNoteAccuracy(String selectedNote, double selectedFrequency, double accuracyThreshold) {
//     //debugPrint("threshold $accuracyThreshold");
//     double closestFrequency = Frequencies.frequencies[selectedNote] ?? 0.0;
//     double accuracy = 0.0;
//
//     if (closestFrequency != 0.0) {
//       //get how "distant" the actual frequency is from the desired one
//       double frequencyDiff = selectedFrequency - closestFrequency;
//
//       //tolerance of 1.5hz
//       if (frequencyDiff.abs() < accuracyThreshold) {
//         accuracy = 100.0 - frequencyDiff.abs();
//       } else {
//         accuracy = 0.0; //if the difference is higher than num hz then the accuracy is none
//       }
//     }
//     return accuracy;
//   }
//
//   static List<double> updateSamples(double frequency, int sampleRate) {
//     const int sampleCount = 1024;
//     List<double> newSamples = List.generate(sampleCount, (i) {
//       double time = i / sampleRate;
//       return sin(2 * pi * frequency * time);
//     });
//
//     return newSamples;
//   }
//
// }
//
//
//
//
//
//
//
//
//
//
//
//
//




// List<Widget> _generateTicks() {
//   return List.generate(widget.max - widget.min + 1, (index) {
//     final currentValue = widget.min + index;
//     final isSelected = currentValue == _selectedValue;
//
//     return Container(
//         margin: EdgeInsets.symmetric(horizontal: widget.ticksMargin),
//         width: widget.ticksWidth,
//         height: isSelected ? widget.ticksHeight+10 : widget.ticksHeight,
//         decoration: BoxDecoration(
//           color: isSelected ? widget.activeColor : widget.inactiveColor,
//           borderRadius: BorderRadius.circular(2),
//         ),
//       );
//   });
// }



// @override
// void didUpdateWidget(ValueSlider oldWidget) {
//   super.didUpdateWidget(oldWidget);
//
//   //debugPrint("[Can Reset]: ${widget.canReset}");
//
//   if(context.read<CanResetCubit>().state) {
//     if (widget.initialPosition != oldWidget.initialPosition && _initialScrollDone) {
//       _scrollController.animateTo(
//         widget.initialPosition,
//         duration: const Duration(milliseconds: 500),
//         curve: Curves.easeInOut,
//       );
//     }
//
//     if (widget.selectedValue != oldWidget.selectedValue) {
//       _scrollToIndex(widget.selectedValue);
//     }
//     setState(() {
//
//     });
//   }
// }