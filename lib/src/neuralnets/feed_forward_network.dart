import '../neural_network.dart';
import '../genome.dart';
import '../config.dart';
import '../genes.dart';
import '../graphs.dart';

class FeedForwardNetwork implements NeuralNetwork {
  final List<int> inputNodes;
  final List<int> outputNodes;
  final List<NeuralNetworkNode> nodeEvals;
  final values = <int, double>{};

  FeedForwardNetwork(
      {required this.inputNodes,
      required this.outputNodes,
      required this.nodeEvals}) {
    for (final input in inputNodes) {
      values[input] = 0.0;
    }

    for (final output in outputNodes) {
      values[output] = 0.0;
    }

    for (final node in nodeEvals) {
      values[node.id] = 0.0;
    }
  }

  @override
  List<double> activate(List<double> inputs) {
    if (inputNodes.length != inputs.length) {
      throw InvalidArgumentException(
          'Expected ${inputNodes.length} inputs, got ${inputs.length}');
    }
    for (final (index, id) in inputNodes.indexed) {
      final input = inputs[index];
      values[id] = input;
    }

    for (final (idx, i) in inputNodes.indexed) {
      values[i] = inputs[idx];
    }

    for (final node in nodeEvals) {
      final nodeInputs = <double>[];
      for (final input in node.inputs) {
        nodeInputs.add(values[input.nodeId]! * input.weight);
      }
      final s = node.aggregationFunction(nodeInputs);
      values[node.id] = node.activationFunction(node.bias + node.response * s);
    }
    final outputs = <double>[];
    for (final id in outputNodes) {
      outputs.add(values[id]!);
    }
    return outputs;
  }

  /// Receives a genome and returns its phenotype (a FeedForwardNetwork).
  static FeedForwardNetwork create(
      {required Genome genome, required Config config}) {
    final connections = <ConnectionGeneKey>[];
    for (final cg in genome.connections.values) {
      if (cg.enabled == true) {
        connections.add(cg.key);
      }
    }

    final layers = Graphs.feedForwardLayers(
        inputs: config.genome.inputKeys,
        outputs: config.genome.outputKeys,
        connections: connections);

    var nodeEvals = <NeuralNetworkNode>[];
    for (final layer in layers) {
      for (final node in layer) {
        final inputs = <NeuralNetworkInput>[];
        for (final connKey in connections) {
          final inode = connKey.inputKey;
          final onode = connKey.outputKey;
          if (onode == node) {
            final cg = genome.connections[connKey];
            inputs.add(NeuralNetworkInput(nodeId: inode, weight: cg!.weight!));
          }
        }

        final ng = genome.nodes[node]!;
        final aggregationFunction =
            config.genome.aggregationFunctionDefs[ng.aggregation]!;
        final activationFunction = config.genome.activationDefs[ng.activation]!;
        nodeEvals.add(NeuralNetworkNode(
            id: node,
            activationFunction: activationFunction,
            aggregationFunction: aggregationFunction,
            bias: ng.bias!,
            response: ng.response!,
            inputs: inputs));
      }
    }

    return FeedForwardNetwork(
        inputNodes: config.genome.inputKeys,
        outputNodes: config.genome.outputKeys,
        nodeEvals: nodeEvals);
  }
}
