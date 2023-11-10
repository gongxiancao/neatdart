
abstract class NeuralNetwork {
  List<double> activate(List<double> inputs);
}

class NeuralNetworkInput {
  final int nodeId;
  final double weight;
  NeuralNetworkInput({
    required this.nodeId,
    required this.weight});
}

class NeuralNetworkNode {
  final int id;
  final double Function(double) activationFunction;
  final double Function(List<double>) aggregationFunction;
  final double bias;
  final double response;
  final List<NeuralNetworkInput> inputs;
  NeuralNetworkNode({
    required this.id,
    required this.activationFunction,
    required this.aggregationFunction,
    required this.bias,
    required this.response,
    required this.inputs,
  });
}