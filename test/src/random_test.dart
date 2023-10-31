import 'package:test/test.dart';
import 'package:neatdart/src/random.dart';

void main() {
  test('random nextInt', () async {
    int result1 = Random.nextInt(5, 10);
    int result2 = Random.nextInt(5, 10);
    int result3 = Random.nextInt(5, 10);
    expect(result1, allOf(greaterThanOrEqualTo(5), lessThanOrEqualTo(10)));
    expect(result2, allOf(greaterThanOrEqualTo(5), lessThanOrEqualTo(10)));
    expect(result3, allOf(greaterThanOrEqualTo(5), lessThanOrEqualTo(10)));
    expect(result1 == result2 && result2 == result3, false);
  });

  test('random nextDouble', () async {
    double result1 = Random.nextDouble();
    double result2 = Random.nextDouble();
    double result3 = Random.nextDouble();
    expect(result1, allOf(greaterThanOrEqualTo(0), lessThan(1)));
    expect(result2, allOf(greaterThanOrEqualTo(0), lessThan(1)));
    expect(result3, allOf(greaterThanOrEqualTo(0), lessThan(1)));
    expect(result1 == result2 && result2 == result3, false);
  });

  test('random choice', () async {
    final options = [1,2,3,4,5];
    int result1 = Random.choice(options);
    int result2 = Random.choice(options);
    int result3 = Random.choice(options);
    expect(result1 == result2 && result2 == result3, false);
  });
}
