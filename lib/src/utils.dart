import 'dart:math';

class Utils {
  static T sum<T extends num>(Iterable<T> numbers) {
    T result = 0.0 is T ? (0.0 as T) : (0 as T);
    for (final i in numbers) {
      result = (result + i) as T;
    }
    return result;
  }

  static double mean(Iterable<double> array) {
    return sum<double>(array) / array.length;
  }

  static double variance(Iterable<double> array) {
    var m = mean(array);
    var squareSum = 0.0;
    for (final v in array) {
      squareSum += ((v - m) * (v - m));
    }
    return squareSum / array.length;
  }

  static double stdev(Iterable<double> array) {
    return sqrt(variance(array));
  }
}
