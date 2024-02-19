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
}

class Context {
  final Config config;
  final double Function(List<double>) fitnessCriterion;
  final Map<String, double Function(Iterable<double>)> aggregationFunctionDefs;
  final Map<String, double Function(double)> activationDefs;
  final GenomeContext genome;
  final StagnationContext stagnation;
  Context({
    required this.config,
    required this.aggregationFunctionDefs,
    required this.activationDefs
  }): fitnessCriterion = aggregationFunctionDefs[config.fitnessCriterion]!,
      genome = GenomeContext(config: config.genome, aggregationFunctionDefs: aggregationFunctionDefs, activationDefs: activationDefs),
      stagnation = StagnationContext(config: config.stagnation, aggregationFunctionDefs: aggregationFunctionDefs);
}