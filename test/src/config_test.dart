import 'package:neat_dart/neat_dart.dart';
import 'package:test/test.dart';

void main() {
  test('Config test', () {
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
    final configJson = config.toJson();
    final newConfig = Config.fromJson(configJson);
    expect(newConfig, equals(config));
  });
}
