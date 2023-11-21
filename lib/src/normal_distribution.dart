import 'dart:math' as math;

class NormalDistribution {
  final math.Random source;
  final double mean;
  final double deviation;

  NormalDistribution({required this.source, required this.mean, required this.deviation});

  // Box-Muller algorithm.
  double next() {
    final u1 = source.nextDouble(),
        u2 = source.nextDouble(),
        r = math.sqrt(-2 * math.log(u1)),
        t = 2 * math.pi * u2;
    return r * math.cos(t) * deviation + mean;
  }
}