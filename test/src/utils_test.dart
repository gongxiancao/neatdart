import 'package:neatdart/src/utils.dart';
import 'package:test/test.dart';

void main() {
  test('utils sum', () async {
    int result = Utils.sum<int>([1, 2]);
    expect(result, 3);
  });

  test('utils sum double list', () async {
    double result = Utils.sum<double>([]);
    expect(result, 0.0);
  });

  test('utils sum empty list', () async {
    int result = Utils.sum<int>([]);
    expect(result, 0);
  });

  test('utils mean', () async {
    double result = Utils.mean(<double>[1.0, 2.0, 3.0]);
    expect(result, 2);
  });

  test('utils variance', () async {
    double result = Utils.variance(<double>[1.0, 2.0, 3.0]);
    expect(result, closeTo(0.66666666, 0.0000001));
  });

  test('utils stdev', () async {
    double result = Utils.stdev(<double>[1.0, 2.0, 3.0]);
    expect(result, closeTo(0.816496580927726, 0.0000001));
  });
}
