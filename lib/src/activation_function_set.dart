import 'activations.dart';

typedef ActivationFunction = double Function(double z);

class ActivationFunctionSet {
  static Map<String, ActivationFunction> instance = _create();
  static Map<String, ActivationFunction> _create() {
    var functions = <String, ActivationFunction>{};
    functions["sigmoid"] = sigmoidActivation;
    functions["tanh"] = tanActivation;
    functions["sin"] = sinActivation;
    functions["gauss"] = gaussActivation;
    functions["relu"] = reluActivation;
    functions["elu"] = eluActivation;
    functions["lelu"] = leluActivation;
    functions["selu"] = seluActivation;
    functions["softplus"] = softplusActivation;
    functions["identity"] = identityActivation;
    functions["clamped"] = clampedActivation;
    functions["inv"] = invActivation;
    functions["log"] = logActivation;
    functions["exp"] = expActivation;
    functions["abs"] = absActivation;
    functions["hat"] = hatActivation;
    functions["square"] = squareActivation;
    functions["cube"] = cubeActivation;
    return functions;
  }
}
