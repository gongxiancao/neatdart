import 'package:test/test.dart';
import 'package:neat_dart/src/activations.dart';

void main() {
  test('activations sigmoidActivation', () async {
    double result = sigmoidActivation(0);
    expect(result, 0.5);

    result = sigmoidActivation(0.1);
    expect(result, closeTo(0.6, 0.1));

    result = sigmoidActivation(100);
    expect(result, 1);
  });

  test('activations tanActivation', () async {
    double result = tanActivation(0);
    expect(result, 0);

    result = tanActivation(0.1);
    expect(result, closeTo(0.2, 0.1));

    result = tanActivation(1);
    expect(result, closeTo(-0.7, 0.1));
  });
}
