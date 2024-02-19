import 'package:test/test.dart';
import 'package:neat_dart/src/activations.dart';
import 'package:neat_dart/src/aggregations.dart';
import 'package:neat_dart/src/neural_network.dart';
import 'package:neat_dart/src/nn/recurrent_network.dart';


void main() {
  test('recurrent_network unconnected', () async {
    // Unconnected network with no inputs and one output neuron.
    final r = RecurrentNetwork(
        inputNodes: [],
        outputNodes: [0],
        nodeEvals: [
          NeuralNetworkNode(
              id: 0,
              activationFunction: sigmoidActivation,
              aggregationFunction: sumAggregation,
              bias: 0.0,
              response: 1.0,
              inputs: []
          )
        ]
    );

    expect(r.active, 0);
    expect(r.values.length, 2);
    expect(r.values[0].length, 1);
    expect(r.values[1].length, 1);

    var result = r.activate([]);

    expect(r.active, 1);
    expect(r.values[1][0], closeTo(0.5, 0.001));
    expect(result[0], r.values[1][0]);

    result = r.activate([]);

    expect(r.active, 0);
    expect(r.values[0][0], closeTo(0.5, 0.001));
    expect(result[0], r.values[0][0]);
  });

  test('recurrent_network basic', () async {
    // Very simple network with one connection of weight one to a single sigmoid output node.
    final r = RecurrentNetwork(
        inputNodes: [-1],
        outputNodes: [0],
        nodeEvals: [
          NeuralNetworkNode(
              id: 0,
              activationFunction: sigmoidActivation,
              aggregationFunction: sumAggregation,
              bias: 0.0,
              response: 1.0,
              inputs: [
                NeuralNetworkInput(
                    nodeId: -1,
                    weight: 1.0
                )
              ]
          )
        ]
    );

    expect(r.active, 0);
    expect(r.values.length, 2);
    expect(r.values[0].length, 2);
    expect(r.values[1].length, 2);

    var result = r.activate([0.2]);

    expect(r.active, 1);
    expect(r.values[1][-1], 0.2);
    expect(r.values[1][0], closeTo(0.731, 0.001));
    expect(result[0], r.values[1][0]);

    result = r.activate([0.4]);

    expect(r.active, 0);
    expect(r.values[0][-1], 0.4);
    expect(r.values[0][0], closeTo(0.881, 0.001));
    expect(result[0], r.values[0][0]);
  });
}
