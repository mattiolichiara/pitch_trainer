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