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
  final double Function(List<double>) fitnessCriterion;

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
