import 'package:test/test.dart';
import 'package:neat_dart/src/reproduction.dart';
import 'package:neat_dart/src/population.dart';
import 'package:neat_dart/src/genome.dart';
import 'package:neat_dart/src/genes.dart';
import 'package:neat_dart/src/graphs.dart';
import 'package:neat_dart/src/config.dart';
import 'package:neat_dart/src/species.dart';
import 'package:neat_dart/src/stagnation.dart';
import 'package:neat_dart/src/attributes.dart';
import 'package:neat_dart/src/reporting.dart';
import 'package:neat_dart/src/aggregation_function_set.dart';
import 'package:neat_dart/src/activation_function_set.dart';
import 'package:neat_dart/src/nn/feed_forward_network.dart';
import 'dart:convert';

class XorFeedForwardFitnessDelegate implements FitnessDelegate {
  final xorInputs = [[0.0, 0.0], [0.0, 1.0], [1.0, 0.0], [1.0, 1.0]];
  final xorOutputs = [   [0.0],     [1.0],     [1.0],     [0.0]];

  XorFeedForwardFitnessDelegate();

  void evaluateGenome({required Genome genome, required GenomeContext context}) {
    genome.fitness = 4.0;
    final net = FeedForwardNetwork.create(genome: genome, context: context);
    for (final (index, xi) in xorInputs.indexed) {
      final output = net.activate(xi);
      final xo = xorOutputs[index];
      // print('output: $output, xo: $xo');
      genome.fitness = genome.fitness! - (output[0] - xo[0]) * (output[0] - xo[0]);
    }
    // print('genome.fitness: ${genome.fitness}');
  }

  @override
  void evaluate({required Iterable<Genome> genomes, required GenomeContext context}) {
    for (final genome in genomes) {
      evaluateGenome(genome: genome, context: context);
    }
  }
}

class XorRecurrentFitnessDelegate implements FitnessDelegate {
  List<List<List<double>>> xorInputs = [
    [[0.0, 0.0], [0.0, 0.0], [0.0, 1.0]],
    [[0.0, 0.0], [1.0, 0.0], [0.0, 1.0]],
    [[1.0, 0.0], [1.0, 0.0], [0.0, 1.0]],
    [[1.0, 0.0], [0.0, 0.0], [0.0, 1.0]],
  ];
  List<List<double>> xorOutputs = [   [0.0],     [1.0],     [0.0],     [1.0]];

  bool log = false;

  XorRecurrentFitnessDelegate();

  void evaluateGenome({required Genome genome, required GenomeContext context}) {
    genome.fitness = 4.0;
    final net = FeedForwardNetwork.create(genome: genome, context: context);
    if (log) {
      print("begin evaluate ${genome.key}, hasRecurrentConnection: ${Graphs
          .hasRecurrentConnection(
          genome.connections.keys)}, Genome: ${jsonEncode(genome.toJson())}");
    }
    for (final (index, xi) in xorInputs.indexed) {
      List<double>? actualOutput;
      // recurrent network has memory so activating multiple times will produce
      // different results.
      for (final xii in xi) {
        if (log) {
          print("net: ${net.values}");
        }
        actualOutput = net.activate(xii);
        if (log) {
          print("input: $xii, output: $actualOutput");
        }
      }

      final expectedOutput = xorOutputs[index];
      // print('output: $output, xo: $xo');
      genome.fitness = genome.fitness! - (actualOutput![0] - expectedOutput[0]) * (actualOutput[0] - expectedOutput[0]);
    }
    if (log) {
      print('genome.fitness: ${genome.fitness}');
    }
  }

  @override
  void evaluate({required Iterable<Genome> genomes, required GenomeContext context}) {
    for (final genome in genomes) {
      evaluateGenome(genome: genome, context: context);
    }
  }
}

void main() {
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
          recurrent: false,
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
      ),
      reproduction: ReproductionConfig(
          elitism: 2,
          survivalThreshold: 0.2,
          minSpeciesSize: 2
      ),
      stagnation: StagnationConfig(
          speciesFitness: 'max',
          maxStagnation: 20,
          speciesElitism: 2
      ),
      speciesSet: SpeciesSetConfig(
          compatibilityThreshold: 3.0
      ),
      fitnessCriterion: 'max'
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
    final fitnessDelegate = XorFeedForwardFitnessDelegate();
    final context = GenomeContext(config: config.genome, state: GenomeState(), aggregationFunctionDefs: AggregationFunctionSet.instance, activationDefs: ActivationFunctionSet.instance);
    fitnessDelegate.evaluateGenome(genome: genome, context: context);
    expect(genome.fitness, closeTo(3.9, 0.1));
  });

  test('xor with recurrent = false', () async {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.

    // Create the population, which is the top-level object for a NEAT run.
    final context = Context(config: config, state: State(), aggregationFunctionDefs: AggregationFunctionSet.instance, activationDefs: ActivationFunctionSet.instance);
    final reporter = StdOutReporter();
    final p = Population(context: context, reporter: reporter);

    final fitnessDelegate = XorFeedForwardFitnessDelegate();
    // Run for up to 100 generations.
    final winner = p.run(fitnessDelegate: fitnessDelegate, generations: 100);

    expect(winner.fitness, closeTo(3.9, 0.1));
  });

  test('xor with recurrent recurrent = true ', () async {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
    final newConfig = Config.fromJson(config.toJson());
    newConfig.genome.recurrent = true;
    newConfig.fitnessThreshold = 3.9;
    // Create the population, which is the top-level object for a NEAT run.
    final context = Context(config: newConfig, state: State(), aggregationFunctionDefs: AggregationFunctionSet.instance, activationDefs: ActivationFunctionSet.instance);
    final reporter = StdOutReporter();
    final p = Population(context: context, reporter: reporter);

    final fitnessDelegate = XorRecurrentFitnessDelegate();
    // Run for up to 100 generations.
    final winner = p.run(fitnessDelegate: fitnessDelegate, generations: 100);
    fitnessDelegate.log = true;
    fitnessDelegate.evaluateGenome(genome: winner, context: context.genome);
    expect(winner.fitness, closeTo(3.9, 0.1));
  });
}
