import 'dart:math';
import 'utils.dart';

double productAggregation(Iterable<double> x) {
  double r = 1.0;
  for (final i in x) {
    r *= i;
  }
  return r;
}

double sumAggregation(Iterable<double> x) {
  double r = 0.0;
  for (final i in x) {
    r += i;
  }
  return r;
}

double maxAggregation(Iterable<double> x) {
  return x.reduce(max);
}

double minAggregation(Iterable<double> x) {
  return x.reduce(min);
}

double maxabsAggregation(Iterable<double> x) {
  double r = 0.0;
  return x.reduce((value, element) {
    double a = abs(element);
    if (r < a) {
      r = a;
      return element;
    }
    return value;
  });
}

double medianAggregation(Iterable<double> x) {
  int n = x.length;
  if (n <= 2) {
    return meanAggregation(x);
  }
  var values = x.toList(growable: false);
  values.sort();
  var i = n ~/ 2;
  if ((n % 2) == 1) {
    return values[i];
  }
  return (values[i - 1] + values[i]) / 2;
}

double meanAggregation(Iterable<double> x) {
  return sumAggregation(x) / x.length;
}
