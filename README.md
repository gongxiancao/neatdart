
NEAT is a method developed by Kenneth O. Stanley for evolving arbitrary neural networks. NEAT-Dart is a pure Dart implementation of NEAT, with no dependencies other than the Dart standard library.


## Usage


```dart
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

  // Create the population, which is the top-level object for a NEAT run.
  final reporter = StdOutReporter();
  final p = Population(config: config, reporter: reporter);

  final fitnessDelegate = XorFitnessDelegate(xorInputs: xorInputs, xorOutputs: xorOutputs);
  // Run for up to 100 generations.
  final winner = p.run(fitnessDelegate: fitnessDelegate, generations: 100);
  print('${winner.fitness}');
}
```
