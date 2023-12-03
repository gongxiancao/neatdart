import 'package:test/test.dart';
import 'package:neat_dart/src/aggregations.dart';

void main() {
  test('aggregations productAggregation', () async {
    double result = productAggregation(<double>[1, 2, 3]);
    expect(result, 6.0);
  });

  test('aggregations sumAggregation', () async {
    double result = sumAggregation([1, 2, 3]);
    expect(result, 6.0);
  });

  test('aggregations maxAggregation', () async {
    double result = maxAggregation([1, 2, 3]);
    expect(result, 3.0);
  });

  test('aggregations minAggregation', () async {
    double result = minAggregation([1, 2, 3]);
    expect(result, 1.0);
  });

  test('aggregations maxabsAggregation', () async {
    double result = maxabsAggregation([1, 2, -3]);
    expect(result, -3.0);
  });

  test('aggregations medianAggregation', () async {
    double result = medianAggregation([1, 2, 3]);
    expect(result, 2.0);

    result = medianAggregation([1, 2, 3, 4]);
    expect(result, 2.5);

    result = medianAggregation([3, 1, 2, 4]);
    expect(result, 2.5);
  });

  test('aggregations meanAggregation', () async {
    double result = meanAggregation([1, 2, 3]);
    expect(result, 2.0);

    result = meanAggregation([1, 2]);
    expect(result, 1.5);
  });
}
