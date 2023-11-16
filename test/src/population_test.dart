import 'package:test/test.dart';
import 'package:neatdart/src/genome.dart';
import 'package:neatdart/src/config.dart';
import 'package:neatdart/src/genes.dart';
import 'package:neatdart/src/reproduction.dart';
import 'package:neatdart/src/population.dart';
import 'package:neatdart/src/attributes.dart';
import 'package:neatdart/src/species.dart';
import 'package:neatdart/src/stagnation.dart';
import 'package:neatdart/src/aggregation_function_set.dart';
import 'package:neatdart/src/activation_function_set.dart';
import 'package:neatdart/src/aggregations.dart';
import 'package:neatdart/src/reporting.dart';

class TestFitnessDelegate implements FitnessDelegate {
  @override
  void evaluate({required Iterable<Genome> genomes, required Config config}) {
    for (final genome in genomes) {
      genome.fitness = 1.0;
    }
  }
}

void main() {
  test('population validFitnessCriterion', () async {
    final aggregationSet = AggregationFunctionSet.create();
    for (final c in ["max", "min", "mean"]) {
      // Load configuration.
      final config = Config(
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
          aggregationFunctionDefs: aggregationSet,
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
        fitnessCriterion: aggregationSet[c]!
      );

      final reporter = StdOutReporter();
      final p = Population(config: config, reporter: reporter);
      final fitnessDelegate = TestFitnessDelegate();
      p.run(fitnessDelegate: fitnessDelegate, generations: 10);
    }
  });
}
