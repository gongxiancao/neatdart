import 'package:test/test.dart';
import 'package:neat_dart/src/reproduction.dart';
import 'package:neat_dart/src/population.dart';
import 'package:neat_dart/src/genome.dart';
import 'package:neat_dart/src/genes.dart';
import 'package:neat_dart/src/config.dart';
import 'package:neat_dart/src/species.dart';
import 'package:neat_dart/src/stagnation.dart';
import 'package:neat_dart/src/attributes.dart';
import 'package:neat_dart/src/aggregations.dart';
import 'package:neat_dart/src/reporting.dart';
import 'package:neat_dart/src/aggregation_function_set.dart';
import 'package:neat_dart/src/activation_function_set.dart';
import 'package:neat_dart/src/neuralnets/feed_forward_network.dart';

class XorFitnessDelegate implements FitnessDelegate {
  final List<List<double>> xorInputs;
  final List<List<double>> xorOutputs;

  XorFitnessDelegate({required this.xorInputs, required this.xorOutputs});

  void evaluateGenome({required Genome genome, required Config config}) {
    genome.fitness = 4.0;
    final net = FeedForwardNetwork.create(genome: genome, config: config);
    for (final (index, xi) in xorInputs.indexed) {
      final output = net.activate(xi);
      final xo = xorOutputs[index];
      // print('output: $output, xo: $xo');
      genome.fitness = genome.fitness! - (output[0] - xo[0]) * (output[0] - xo[0]);
    }
    // print('genome.fitness: ${genome.fitness}');
  }

  @override
  void evaluate({required Iterable<Genome> genomes, required Config config}) {
    for (final genome in genomes) {
      evaluateGenome(genome: genome, config: config);
    }
  }
}

void main() {
  final xorInputs = [[0.0, 0.0], [0.0, 1.0], [1.0, 0.0], [1.0, 1.0]];
  final xorOutputs = [   [0.0],     [1.0],     [1.0],     [0.0]];

  // Load configuration.
  final config = Config(
      noFitnessTermination: false,
      fitnessThreshold: 3.9,
      popSize: 150,
      resetOnExtinction: false,
      genome: GenomeConfig(
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
          feedForward: true,
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
          aggregationFunctionDefs: AggregationFunctionSet.create(),
          activationDefs: ActivationFunctionSet.create()
      ),
      reproduction: ReproductionConfig(
          elitism: 2,
          survivalThreshold: 0.2,
          minSpeciesSize: 2
      ),
      stagnation: StagnationConfig(
          speciesFitnessFunc: maxAggregation,
          maxStagnation: 20,
          speciesElitism: 2
      ),
      speciesSet: SpeciesSetConfig(
          compatibilityThreshold: 3.0
      ),
      fitnessCriterion: maxAggregation
  );

  test('xor genomeEvaluate', () async {
    const genomeData = {
      "connections" : [
        {
          "key" : {
            "inputKey" : 136,
            "outputKey" : 0
          },
          "enabled" : true,
          "weight" : -4
        },
        {
          "key" : {
            "inputKey" : 1515,
            "outputKey" : 136
          },
          "enabled" : true,
          "weight" : 2.3333334922790527
        },
        {
          "key" : {
            "inputKey" : -2,
            "outputKey" : 136
          },
          "enabled" : false,
          "weight" : 1.3333334922790527
        },
        {
          "key" : {
            "inputKey" : 404,
            "outputKey" : 1039
          },
          "enabled" : true,
          "weight" : -0.33333337306976318
        },
        {
          "key" : {
            "inputKey" : -2,
            "outputKey" : 1515
          },
          "enabled" : true,
          "weight" : 2
        },
        {
          "key" : {
            "inputKey" : -1,
            "outputKey" : 0
          },
          "enabled" : false,
          "weight" : -1
        },
        {
          "key" : {
            "inputKey" : 1039,
            "outputKey" : 0
          },
          "enabled" : true,
          "weight" : -1
        },
        {
          "key" : {
            "inputKey" : -2,
            "outputKey" : 1039
          },
          "enabled" : true,
          "weight" : 0.33333331346511841
        },
        {
          "key" : {
            "inputKey" : 404,
            "outputKey" : 0
          },
          "enabled" : true,
          "weight" : 2
        },
        {
          "key" : {
            "inputKey" : 404,
            "outputKey" : 136
          },
          "enabled" : true,
          "weight" : -2.3333334922790527
        },
        {
          "key" : {
            "inputKey" : -1,
            "outputKey" : 404
          },
          "enabled" : true,
          "weight" : -3.3333334922790527
        },
        {
          "key" : {
            "inputKey" : -1,
            "outputKey" : 136
          },
          "enabled" : true,
          "weight" : -0.66666674613952637
        },
        {
          "key" : {
            "inputKey" : -2,
            "outputKey" : 404
          },
          "enabled" : true,
          "weight" : 6.3333334922790527
        }
      ],
      "key" : 7573,
      "nodes" : [
        {
          "key" : 1515,
          "response" : 1,
          "aggregation" : "sum",
          "bias" : -2,
          "activation" : "sigmoid"
        },
        {
          "key" : 0,
          "response" : 1,
          "aggregation" : "sum",
          "bias" : 1,
          "activation" : "sigmoid"
        },
        {
          "key" : 404,
          "response" : 1,
          "aggregation" : "sum",
          "bias" : -3.6666667461395264,
          "activation" : "sigmoid"
        },
        {
          "key" : 136,
          "response" : 1,
          "aggregation" : "sum",
          "bias" : 0,
          "activation" : "sigmoid"
        },
        {
          "key" : 1039,
          "response" : 1,
          "aggregation" : "sum",
          "bias" : 0,
          "activation" : "sigmoid"
        }
      ],
      "fitness" : 0
    };
    final genome = Genome.fromJson(genomeData);
    final fitnessDelegate = XorFitnessDelegate(xorInputs: xorInputs, xorOutputs: xorOutputs);
    fitnessDelegate.evaluateGenome(genome: genome, config: config);
    expect(genome.fitness, closeTo(3.9, 0.1));
  });

  test('xor xor', () async {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.

    // Create the population, which is the top-level object for a NEAT run.
    final reporter = StdOutReporter();
    final p = Population(config: config, reporter: reporter);

    final fitnessDelegate = XorFitnessDelegate(xorInputs: xorInputs, xorOutputs: xorOutputs);
    // Run for up to 100 generations.
    final winner = p.run(fitnessDelegate: fitnessDelegate, generations: 100);

    expect(winner.fitness, closeTo(3.9, 0.1));
  });
}
