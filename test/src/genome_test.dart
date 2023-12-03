import 'package:test/test.dart';
import 'package:neat_dart/src/config.dart';
import 'package:neat_dart/src/genome.dart';
import 'package:neat_dart/src/genes.dart';
import 'package:neat_dart/src/attributes.dart';
import 'package:neat_dart/src/aggregation_function_set.dart';
import 'package:neat_dart/src/activation_function_set.dart';
import 'package:neat_dart/src/reproduction.dart';
import 'package:neat_dart/src/stagnation.dart';
import 'package:neat_dart/src/species.dart';
import 'package:neat_dart/src/aggregations.dart';

void main() {
  Config? config;
  Config? config2;
  setUp(() async {
    config = Config(
      noFitnessTermination: false,
      fitnessThreshold: 0.9,
      popSize: 150,
      resetOnExtinction: false,
      genome: GenomeConfig(
        numInputs: 2,
        numOutputs: 1,
        numHidden: 0,
        initialConnection: InitialConnection.fullNodirect,
        connectionFraction: 0.0,
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
            maxValue: 30.0,
            minValue: -30.0,
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
          speciesElitism: 1
      ),
      speciesSet: SpeciesSetConfig(
          compatibilityThreshold: 3.0
      ),
      fitnessCriterion: maxAggregation
    );

    config2 = Config(
      noFitnessTermination: false,
      fitnessThreshold: 0.9,
      popSize: 150,
      resetOnExtinction: true,
      genome: GenomeConfig(
        numInputs: 2,
        numOutputs: 1,
        numHidden: 0,
        initialConnection: InitialConnection.partialNodirect,
        connectionFraction: 0.5,
        singleStructuralMutation: true,
        structuralMutationSurer: true,
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
            options: ["sigmoid", "tanh", "relu"],
            defaultValue: "random",
            mutateRate: 0.5
          ),
          aggregation: StringAttributeConfig(
            options: ["sum", "product", "max", "min", "maxabs", "median", "mean"],
            defaultValue: "random",
            mutateRate: 0.5
          ),
          compatibilityWeightCoefficient: 0.5
        ),
        connection: ConnectionGeneConfig(
          weight: FloatAttributeConfig(
            mean: 0.0,
            stdev: 1.0,
            initType: DistributionType.uniform,
            maxValue: 30.0,
            minValue: -30.0,
            mutatePower: 0.5,
            mutateRate: 0.8,
            replaceRate: 0.1
          ),
          enabled: BoolAttributeConfig(
            defaultValue: true,
            mutateRate: 0.05,
            rateToTrueAdd: 0.5,
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
        speciesElitism: 0
      ),
      speciesSet: SpeciesSetConfig(
        compatibilityThreshold: 3.0
      ),
      fitnessCriterion: maxAggregation
    );
  });

  // Unconnected network with only input and output nodes.
  test('genome unconnectedNoHidden', () async {
    final gid = 42;
    final genomeConfig = config!.genome;
    genomeConfig.initialConnection = InitialConnection.none;
    genomeConfig.numHidden = 0;

    final g = Genome(gid);
    expect(gid, g.key);
    g.configureNew(genomeConfig);

    expect(Set<int>.from(g.nodes.keys), {0});
    expect(g.connections.length, 0);
  });

  // Unconnected network with hidden nodes.
  test('genome unconnectedHidden', () async {
    final gid = 42;
    final genomeConfig = config!.genome;
    genomeConfig.initialConnection = InitialConnection.none;
    genomeConfig.numHidden = 2;

    final g = Genome(gid);
    expect(gid, g.key);
    g.configureNew(genomeConfig);

    expect(Set<int>.from(g.nodes.keys), {0, 1, 2});
    expect(g.connections.length, 0);
  });

  /// fs_neat with no hidden nodes
  /// (equivalent to fs_neat_hidden and fs_neat_nohidden with no hidden nodes).
  test('genome fsNeatNoHidden', () async {
    final gid = 42;
    final genomeConfig = config!.genome;
    genomeConfig.initialConnection = InitialConnection.fsNeatNohidden;
    genomeConfig.numHidden = 0;

    final g = Genome(gid);
    expect(gid, g.key);
    g.configureNew(genomeConfig);

    expect(Set<int>.from(g.nodes.keys), {0});
    expect(g.connections.length, 1);
  });

  /// fs_neat not connecting hidden nodes.
  test('genome fsNeatNohidden', () async {
    final gid = 42;
    final genomeConfig = config!.genome;
    genomeConfig.initialConnection = InitialConnection.fsNeatNohidden;
    genomeConfig.numHidden = 2;

    final g = Genome(gid);
    expect(gid, g.key);
    g.configureNew(genomeConfig);

    expect(Set<int>.from(g.nodes.keys), {0, 1, 2});
    expect(g.connections.length, 1);
  });

  /// fs_neat with connecting hidden nodes.
  test('genome fsNeatHidden', () async {
    final gid = 42;
    final genomeConfig = config!.genome;
    genomeConfig.initialConnection = InitialConnection.fsNeatHidden;
    genomeConfig.numHidden = 2;

    final g = Genome(gid);
    expect(gid, g.key);
    g.configureNew(genomeConfig);

    expect(Set<int>.from(g.nodes.keys), {0, 1, 2});
    expect(g.connections.length, 3);;
  });

  /// full with no hidden nodes
  /// (equivalent to full_nodirect and full_direct with no hidden nodes)
  test('genome fullyConnectedNoHidden', () async {
    final gid = 42;
    final genomeConfig = config!.genome;
    genomeConfig.initialConnection = InitialConnection.fullNodirect;
    genomeConfig.numHidden = 0;

    final g = Genome(gid);
    expect(gid, g.key);
    g.configureNew(genomeConfig);

    expect(Set<int>.from(g.nodes.keys), {0});
    expect(g.connections.length, 2);

    // Check that each input is connected to the output node
    for (final i in genomeConfig.inputKeys) {
      expect(g.connections[ConnectionGeneKey(i, 0)], isNot(equals(null)));
    }
  });

  /// full with no direct input-output connections, only via hidden nodes.
  test('genome fullyConnectedHiddenNodirect', () async {
    final gid = 42;
    final genomeConfig = config!.genome;
    genomeConfig.initialConnection = InitialConnection.fullNodirect;
    genomeConfig.numHidden = 2;

    final g = Genome(gid);
    expect(gid, g.key);
    g.configureNew(genomeConfig);

    expect(Set<int>.from(g.nodes.keys), {0, 1, 2});
    expect(g.connections.length, 6);

    // Check that each input is connected to each hidden node.
    for (final i in genomeConfig.inputKeys) {
      for (final h in [1, 2]) {
        expect(g.connections[ConnectionGeneKey(i, h)], isNot(equals(null)));
      }
    }
    // Check that each hidden node is connected to the output.
    for (final h in [1, 2]) {
      expect(g.connections[ConnectionGeneKey(h, 0)], isNot(equals(null)));
    }

    // Check that inputs are not directly connected to the output
    for (final i in genomeConfig.inputKeys) {
      expect(g.connections[ConnectionGeneKey(i, 0)], null);
    }
  });

  /// full with direct input-output connections (and also via hidden hodes).
  test('genome fullyConnectedHiddenDirect', () async {
    final gid = 42;
    final genomeConfig = config!.genome;
    genomeConfig.initialConnection = InitialConnection.fullDirect;
    genomeConfig.numHidden = 2;

    final g = Genome(gid);
    expect(gid, g.key);
    g.configureNew(genomeConfig);

    print('$g');
    expect(Set<int>.from(g.nodes.keys), {0, 1, 2});
    expect(g.connections.length, 8);

    // Check that each input is connected to each hidden node.
    for (final i in genomeConfig.inputKeys) {
      for (final h in [1, 2]) {
        expect(g.connections[ConnectionGeneKey(i, h)], isNot(equals(null)));
      }
    }

    // Check that each hidden node is connected to the output.
    for (final h in [1, 2]) {
      expect(g.connections[ConnectionGeneKey(h, 0)], isNot(equals(null)));
    }

    // Check that inputs are directly connected to the output
    for (final i in genomeConfig.inputKeys) {
      expect(g.connections[ConnectionGeneKey(i, 0)], isNot(equals(null)));
    }
  });


  /// partial with no hidden nodes
  /// (equivalent to partial_nodirect and partial_direct with no hidden nodes)
  test('genome partiallyConnectedNoHidden', () async {
    final gid = 42;
    final genomeConfig = config2!.genome;
    genomeConfig.initialConnection = InitialConnection.partialNodirect;
    genomeConfig.connectionFraction = 0.5;
    genomeConfig.numHidden = 0;

    final g = Genome(gid);
    expect(gid, g.key);
    g.configureNew(genomeConfig);

    expect(Set<int>.from(g.nodes.keys), {0});
    expect(g.connections.length, lessThan(2));
  });

  /// partial with no direct input-output connections, only via hidden nodes.
  test('genome partiallyConnectedHiddenNodirect', () async {
    final gid = 42;
    final genomeConfig = config!.genome;
    genomeConfig.initialConnection = InitialConnection.partialNodirect;
    genomeConfig.connectionFraction = 0.5;
    genomeConfig.numHidden = 2;

    final g = Genome(gid);
    expect(gid, g.key);
    g.configureNew(genomeConfig);

    expect(Set<int>.from(g.nodes.keys), {0, 1, 2});
    expect(g.connections.length, lessThan(6));
  });

  /// partial with (potential) direct input-output connections
  /// (and also, potentially, via hidden hodes).
  test('genome partiallyConnectedHiddenDirect', () async {
    final gid = 42;
    final genomeConfig = config!.genome;
    genomeConfig.initialConnection = InitialConnection.partialDirect;
    genomeConfig.connectionFraction = 0.5;
    genomeConfig.numHidden = 2;

    final g = Genome(gid);
    expect(gid, g.key);
    g.configureNew(genomeConfig);

    expect(Set<int>.from(g.nodes.keys), {0, 1, 2});
    expect(g.connections.length, lessThan(8));
  });
}
