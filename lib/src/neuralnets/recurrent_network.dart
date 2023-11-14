import '../neural_network.dart';
import '../genome.dart';
import '../config.dart';
import '../genes.dart';
import '../graphs.dart';

class RecurrentNetwork implements NeuralNetwork {
  final List<int> inputNodes;
  final List<int> outputNodes;
  final List<NeuralNetworkNode> nodeEvals;
  final values = <Map<int, double>>[<int, double>{}, <int, double>{}];
  int active = 0;

  RecurrentNetwork({
    required this.inputNodes,
    required this.outputNodes,
    required this.nodeEvals
  }) {

    for (final v in values) {
      for (final input in inputNodes) {
        v[input] = 0.0;
      }

      for (final output in outputNodes) {
        v[output] = 0.0;
      }

      for (final node in nodeEvals) {
        v[node.id] = 0.0;
        
        for (final input in node.inputs) {
          v[input.nodeId] = 0.0;
        }
      }
    }
  }

  void reset() {
    for (final v in values) {
      for (final key in v.keys) {
        v[key] = 0.0;
      }
    }
    active = 0;
  }

  @override
  List<double> activate(List<double> inputs) {
    if (inputNodes.length != inputs.length) {
      throw InvalidArgumentException('Expected ${inputNodes.length} inputs, got ${inputs.length}');
    }

    final ivalues = values[active];
    final ovalues = values[1 - active];
    active = 1 - active;

    for (final (idx, i) in inputNodes.indexed) {
      ivalues[i] = inputs[idx];
      ovalues[i] = inputs[idx];
    }

    for (final node in nodeEvals) {
      final nodeInputs = <double>[];
      for (final input in node.inputs) {
        nodeInputs.add(ivalues[input.nodeId]! * input.weight);
      }
      double s = node.aggregationFunction(nodeInputs);
      ovalues[node.id] = node.activationFunction(node.bias + node.response * s);
    }

    final outputs = <double>[];
    for (final i in outputNodes) {
      outputs.add(ovalues[i]!);
    }
    return outputs;
  }

  static RecurrentNetwork create({required Genome genome, required Config config}) {
    // Receives a genome and returns its phenotype (a RecurrentNetwork).
    final genomeConfig = config.genome;
    final required = Graphs.requiredForOutput(
        inputs: genomeConfig.inputKeys,
        outputs: genomeConfig.outputKeys,
        connections: List<ConnectionGeneKey>.from(genome.connections.keys)
    );

    // Gather inputs and expressed connections.
    final nodeInputs = <int, List<NeuralNetworkInput>>{};
    for (final cg in genome.connections.values) {
      if (cg.enabled != true) {
          continue;
      }

      final i = cg.key.inputKey;
      final o = cg.key.outputKey;
      if (!required.contains(o) && !required.contains(i)) {
          continue;
      }

      if (!nodeInputs.containsKey(o)) {
          nodeInputs[o] = [NeuralNetworkInput(nodeId: i, weight: cg.weight!)];
      } else {
          nodeInputs[o]!.add(NeuralNetworkInput(nodeId: i, weight: cg.weight!));
      }
    }

    final nodeEvals = <NeuralNetworkNode>[];
    for (final entry in nodeInputs.entries) {
      final nodeKey = entry.key;
      final inputs = entry.value;
      final node = genome.nodes[nodeKey]!;
      final activationFunction = genomeConfig.activationDefs[node.activation];
      final aggregationFunction = genomeConfig.aggregationFunctionDefs[node.aggregation];
      nodeEvals.add(NeuralNetworkNode(
        id: nodeKey,
        activationFunction: activationFunction!,
        aggregationFunction: aggregationFunction!,
        bias: node.bias!,
        response: node.response!,
        inputs: inputs
      ));
    }
    return RecurrentNetwork(
        inputNodes: genomeConfig.inputKeys,
        outputNodes: genomeConfig.outputKeys,
        nodeEvals: nodeEvals);
  }
}