import 'package:test/test.dart';
import 'package:neat_dart/src/random_utils.dart';

void main() {
  test('RandomUtils nextInt', () async {
    int result1 = RandomUtils.nextInt(5, 10);
    int result2 = RandomUtils.nextInt(5, 10);
    int result3 = RandomUtils.nextInt(5, 10);
    expect(result1, allOf(greaterThanOrEqualTo(5), lessThanOrEqualTo(10)));
    expect(result2, allOf(greaterThanOrEqualTo(5), lessThanOrEqualTo(10)));
    expect(result3, allOf(greaterThanOrEqualTo(5), lessThanOrEqualTo(10)));
    expect(result1 == result2 && result2 == result3, false);
  });

  test('RandomUtils nextDouble', () async {
    double result1 = RandomUtils.nextDouble();
    double result2 = RandomUtils.nextDouble();
    double result3 = RandomUtils.nextDouble();
    expect(result1, allOf(greaterThanOrEqualTo(0), lessThan(1)));
    expect(result2, allOf(greaterThanOrEqualTo(0), lessThan(1)));
    expect(result3, allOf(greaterThanOrEqualTo(0), lessThan(1)));
    expect(result1 == result2 && result2 == result3, false);
  });

  test('RandomUtils choice', () async {
    final options = [1,2,3,4,5];
    int result1 = RandomUtils.choice(options);
    int result2 = RandomUtils.choice(options);
    int result3 = RandomUtils.choice(options);
    expect(result1 == result2 && result2 == result3, false);
  });
}
