import 'genome.dart';
import 'species.dart';
import 'stagnation.dart';
import 'reproduction.dart';

class Config {
  final bool noFitnessTermination;
  final double fitnessThreshold;
  final int popSize;
  final bool resetOnExtinction;
  final GenomeConfig genome;
  final ReproductionConfig reproduction;
  final StagnationConfig stagnation;
  final SpeciesSetConfig speciesSet;
  final String fitnessCriterion;

  Config({
    required this.noFitnessTermination,
    required this.fitnessThreshold,
    required this.popSize,
    required this.resetOnExtinction,
    required this.genome,
    required this.reproduction,
    required this.stagnation,
    required this.speciesSet,
    required this.fitnessCriterion,
  });

  factory Config.fromJson(Map<String, dynamic> data) {
    if (data case {
      'noFitnessTermination': bool noFitnessTermination,
      'fitnessThreshold': double fitnessThreshold,
      'popSize': int popSize,
      'resetOnExtinction': bool resetOnExtinction,
      'genome': Map<String, dynamic> genome,
      'reproduction': Map<String, dynamic> reproduction,
      'stagnation': Map<String, dynamic> stagnation,
      'speciesSet': Map<String, dynamic> speciesSet,
      'fitnessCriterion': String fitnessCriterion,
    }) {
      return Config(
        noFitnessTermination: noFitnessTermination,
        fitnessThreshold: fitnessThreshold,
        popSize: popSize,
        resetOnExtinction: resetOnExtinction,
        genome: GenomeConfig.fromJson(genome),
        reproduction: ReproductionConfig.fromJson(reproduction),
        stagnation: StagnationConfig.fromJson(stagnation),
        speciesSet: SpeciesSetConfig.fromJson(speciesSet),
        fitnessCriterion: fitnessCriterion,
      );
    }
    throw FormatException('Invalid JSON: $data');
  }

  Map<String, dynamic> toJson() => {
    'noFitnessTermination': noFitnessTermination,
    'fitnessThreshold': fitnessThreshold,
    'popSize': popSize,
    'resetOnExtinction': resetOnExtinction,
    'genome': genome.toJson(),
    'reproduction': reproduction.toJson(),
    'stagnation': stagnation.toJson(),
    'speciesSet': speciesSet.toJson(),
    'fitnessCriterion': fitnessCriterion,
  };

  @override
  bool operator == (Object other) =>
    other is Config &&
    other.runtimeType == runtimeType &&
    other.noFitnessTermination == noFitnessTermination &&
    other.fitnessThreshold == fitnessThreshold &&
    other.popSize == popSize &&
    other.resetOnExtinction == resetOnExtinction &&
    other.genome == genome &&
    other.reproduction == reproduction &&
    other.stagnation == stagnation &&
    other.speciesSet == speciesSet &&
    other.fitnessCriterion == fitnessCriterion;

  @override
  int get hashCode => Object.hash(
    noFitnessTermination,
    fitnessThreshold,
    popSize,
    resetOnExtinction,
    genome,
    reproduction,
    stagnation,
    speciesSet,
    fitnessCriterion,
  );
}

class State {
  final GenomeState genome;
  State({
    genome
  }): genome = genome ?? GenomeState();

  factory State.fromJson(Map<String, dynamic> data) {
    if (data case {
    'genome': Map<String, dynamic> genome,
    }) {
      return State(
        genome: GenomeState.fromJson(genome),
      );
    }
    throw FormatException('Invalid JSON: $data');
  }

  Map<String, dynamic> toJson() => {
    'genome': genome.toJson(),
  };

  @override
  bool operator == (Object other) =>
      other is State &&
          other.runtimeType == runtimeType &&
          other.genome == genome;

  @override
  int get hashCode => genome.hashCode;
}

class Context {
  final Config config;
  final State state;
  final double Function(List<double>) fitnessCriterion;
  final Map<String, double Function(Iterable<double>)> aggregationFunctionDefs;
  final Map<String, double Function(double)> activationDefs;
  final GenomeContext genome;
  final StagnationContext stagnation;
  Context({
    required this.config,
    required this.state,
    required this.aggregationFunctionDefs,
    required this.activationDefs
  }): fitnessCriterion = aggregationFunctionDefs[config.fitnessCriterion]!,
      genome = GenomeContext(config: config.genome, state: state.genome, aggregationFunctionDefs: aggregationFunctionDefs, activationDefs: activationDefs),
      stagnation = StagnationContext(config: config.stagnation, aggregationFunctionDefs: aggregationFunctionDefs);
}