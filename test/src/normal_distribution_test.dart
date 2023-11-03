import 'package:test/test.dart';
import 'package:neatdart/src/normal_distribution.dart';

void main() {
  test('normal_distribution next', () {
    final dist = NormalDistribution(mean: 20, deviation: 5);
    for (int i = 0; i < 20; i ++) {
      double x = dist.next();
      print('${' ' * x.toInt()}x');
    }
  });
}