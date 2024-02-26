import 'package:neat_dart/neat_dart.dart';
import 'package:test/test.dart';
import 'package:neat_dart/src/activations.dart';
import 'package:neat_dart/src/aggregations.dart';
import 'package:neat_dart/src/neural_network.dart';
import 'package:neat_dart/src/nn/feed_forward_network.dart';


void main() {
  test('feed_forward_network unconnected', () async {
    // Unconnected network with no inputs and one output neuron.
    final r = FeedForwardNetwork(
      inputNodes: [],
      outputNodes: [0],
      nodeEvals: [
        NeuralNetworkNode(
          id: 0,
          activationFunction: sigmoidActivation,
          aggregationFunction: sumAggregation,
          bias: 0.0,
          response: 0.0,
          inputs: []
        )
      ]
    );

    expect(r.values[0], 0.0);

    var result = r.activate([]);

    expect(r.values[0]!, closeTo(0.5, 0.001));
    expect(result[0], r.values[0]);

    result = r.activate([]);

    expect(r.values[0]!, closeTo(0.5, 0.001));
    expect(result[0], r.values[0]);
  });

  test('feed_forward_network basic', () async {
    // Very simple network with one connection of weight one to a single sigmoid output node.
    final r = FeedForwardNetwork(
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

    expect(r.values[0], 0.0);

    var result = r.activate([0.2]);

    expect(r.values[-1], 0.2);
    expect(r.values[0]!, closeTo(0.731, 0.001));
    expect(result[0], r.values[0]);

    result = r.activate([0.4]);

    expect(r.values[-1], 0.4);
    expect(r.values[0]!, closeTo(0.881, 0.001));
    expect(result[0], r.values[0]);
  });

  test('feed_forward_network create recurrent', () async {
    final genome = Genome.fromJson({
      "key":271,
      "nodes":[
        {"key":0,"bias":1.5743833678079289,"response":1.0,"activation":"sigmoid","aggregation":"sum"},
        {"key":24,"bias":1.568008604844422,"response":1.0,"activation":"sigmoid","aggregation":"sum"}
      ],
      "connections":[
        {"key":{"inputKey":-2,"outputKey":0},"weight":-2.200709306667263,"enabled":true},
        {"key":{"inputKey":0,"outputKey":0},"weight":1.131089768821733,"enabled":false},
        {"key":{"inputKey":0,"outputKey":24},"weight":1.3779269036034585,"enabled":true},
        {"key":{"inputKey":24,"outputKey":0},"weight":1.1725223120680397,"enabled":true},
        {"key":{"inputKey":24,"outputKey":24},"weight":0.7437908062729364,"enabled":true}
      ],
      "fitness":4.0
    });
    final config = GenomeConfig(
      numInputs: 2,
      numOutputs: 1,
      numHidden: 0,
      initialConnection: InitialConnection.fullNodirect,
      connectionFraction: 0,
      singleStructuralMutation: false,
      structuralMutationSurer: false,
      compatibilityDisjointCoefficient: 1.0,
      nodeAddProb: 0.2,
      nodeDeleteProb: 0.2,
      connAddProb: 0.5,
      connDeleteProb: 0.5,
      feedForward: false,
      node: NodeGeneConfig(
          bias: FloatAttributeConfig(
              mean: 0.0,
              stdev: 1.0,
              initType: DistributionType.normal,
              maxValue: 30.0,
              minValue: -30.0,
              mutatePower: 0.5,
              mutateRate: 0.7,
              replaceRate: 0.1
          ),
          response: FloatAttributeConfig(
              mean: 1.0,
              stdev: 0.0,
              initType: DistributionType.normal,
              maxValue: 30.0,
              minValue: -30.0,
              mutatePower: 0.0,
              mutateRate: 0.0,
              replaceRate: 0.0
          ),
          activation: StringAttributeConfig(
              options: ["sigmoid"],
              defaultValue: "sigmoid",
              mutateRate: 0.0
          ),
          aggregation: StringAttributeConfig(
              options: ["sum"],
              defaultValue: "sum",
              mutateRate: 0.0
          ),
          compatibilityWeightCoefficient: 0.5
      ),
      connection: ConnectionGeneConfig(
          weight: FloatAttributeConfig(
              mean: 0.0,
              stdev: 1.0,
              initType: DistributionType.normal,
              maxValue: 30,
              minValue: -30,
              mutatePower: 0.5,
              mutateRate: 0.8,
              replaceRate: 0.1
          ),
          enabled: BoolAttributeConfig(
              defaultValue: true,
              mutateRate: 0.01,
              rateToTrueAdd: 0.0,
              rateToFalseAdd: 0.0
          ),
          compatibilityWeightCoefficient: 0.5
      ),
    );
    final nn = FeedForwardNetwork.create(genome: genome, context: GenomeContext(config: config, state: GenomeState(), aggregationFunctionDefs: AggregationFunctionSet.instance, activationDefs: ActivationFunctionSet.instance));
    print('nn: inputNodes: ${nn.inputNodes}, outputNodes: ${nn.outputNodes}, nodeEvals:${nn.nodeEvals}, values:${nn.values}');
  });
}
