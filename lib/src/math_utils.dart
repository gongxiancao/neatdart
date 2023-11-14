import 'dart:math';

T abs<T extends num>(T a) {
  if (a < 0) {
    return (-a) as T;
  }
  return a;
}

T sum<T extends num>(Iterable<T> numbers) {
  T result = 0.0 is T ? (0.0 as T) : (0 as T);
  for (final i in numbers) {
    result = (result + i) as T;
  }
  return result;
}

double mean(Iterable<double> array) {
  return sum<double>(array) / array.length;
}

double variance(Iterable<double> array) {
  var m = mean(array);
  var squareSum = 0.0;
  for (final v in array) {
    squareSum += ((v - m) * (v - m));
  }
  return squareSum / array.length;
}

double stdev(Iterable<double> array) {
  return sqrt(variance(array));
}
