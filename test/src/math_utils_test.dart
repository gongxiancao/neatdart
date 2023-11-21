import 'package:test/test.dart';
import 'package:neatdart/src/math_utils.dart';

void main() {
  test('math_utils sign', () async {
    expect(sign(-0.1), -1);
    expect(sign(0.1), 1);
    expect(sign(0.0), 0);
    expect(sign(-0.0), 0);
  });

  test('math_utils sum', () async {
    int result = sum<int>([1, 2]);
    expect(result, 3);
  });

  test('math_utils sum double list', () async {
    double result = sum<double>([]);
    expect(result, 0.0);
  });

  test('math_utils sum empty list', () async {
    int result = sum<int>([]);
    expect(result, 0);
  });

  test('math_utils mean', () async {
    double result = mean(<double>[1.0, 2.0, 3.0]);
    expect(result, 2);
  });

  test('math_utils variance', () async {
    double result = variance(<double>[1.0, 2.0, 3.0]);
    expect(result, closeTo(0.66666666, 0.0000001));
  });

  test('math_utils stdev', () async {
    double result = stdev(<double>[1.0, 2.0, 3.0]);
    expect(result, closeTo(0.816496580927726, 0.0000001));
  });
}
