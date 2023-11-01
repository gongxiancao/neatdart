import 'dart:math' as math;

class NormalDistribution {
  NormalDistribution({required this.mean, required this.deviation});
  final source = math.Random();
  final double mean;
  final double deviation;

  // Box-Muller algorithm.
  double next() {
    final u1 = source.nextDouble(),
        u2 = source.nextDouble(),
        r = math.sqrt(-2 * math.log(u1)),
        t = 2 * math.pi * u2;
    return r * math.cos(t) * deviation + mean;
  }
}