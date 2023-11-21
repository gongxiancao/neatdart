import 'dart:math' as math;

class RandomUtils {
  static math.Random source = math.Random(1);
  static int nextInt(int lowerBound, int upperBound) {
    return source.nextInt(upperBound - lowerBound) + lowerBound;
  }
  static double nextDouble() {
    return source.nextDouble();
  }

  static T choice<T>(Iterable<T> options)  {
    final i = source.nextInt(options.length);
    return options.elementAt(i);
  }

}
