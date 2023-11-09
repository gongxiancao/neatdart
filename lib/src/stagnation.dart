import 'package:neatdart/src/species.dart';
import 'dart:math';
import 'reporting.dart';

class StagnationConfig {
  final double Function(List<double>) speciesFitnessFunc;
  final int maxStagnation;
  final int speciesElitism;
  StagnationConfig({
    required this.speciesFitnessFunc,
    required this.maxStagnation,
    required this.speciesElitism
  });
}

/// Keeps track of whether species are making progress and helps remove ones that are not.
class Stagnation {
  final StagnationConfig config;
  final ReporterSet reporters;

  Stagnation({required this.config, required this.reporters});

  /// Required interface method. Updates species fitness history information,
  /// checking for ones that have not improved in maxStagnation generations,
  /// and - unless it would result in the number of species dropping below the configured
  /// speciesElitism parameter if they were removed,
  /// in which case the highest-fitness species are spared -
  /// returns a list with stagnant species marked for removal.
  List<(int, Species, bool)> update({required SpeciesSet speciesSet, required int generation}) {
    final speciesData = <(int, Species)>[];
    for (final entry in speciesSet.species.entries) {
      final sid = entry.key;
      final s = entry.value;
      final prevFitness = s.fitnessHistory.isNotEmpty ? s.fitnessHistory.reduce(max) : -double.maxFinite;

      s.fitness = config.speciesFitnessFunc(s.getFitnesses());
      s.fitnessHistory.add(s.fitness!);
      s.adjustedFitness = null;
      if (prevFitness == null || s.fitness! > prevFitness!) {
        s.lastImproved = generation;
      }

      speciesData.add((sid, s));
    }

    // Sort in ascending fitness order.
    speciesData.sort(((int, Species) a, (int, Species) b) => (a.$2.fitness! - b.$2.fitness!).toInt());

    final result = <(int, Species, bool)>[];
    final speciesFitnesses = <double>[];
    var numNonStagnant = speciesData.length;
    for (final (idx, (sid, s)) in speciesData.indexed) {
    // Override stagnant state if marking this species as stagnant would
    // result in the total number of species dropping below the limit.
    // Because species are in ascending fitness order, less fit species
    // will be marked as stagnant first.
      final stagnantTime = generation - s.lastImproved;
      var isStagnant = false;
      if (numNonStagnant > config.speciesElitism) {
        isStagnant = stagnantTime >= config.maxStagnation;
      }

      // if your fitness is at top config.speciesElitism, you are spared
      if ((speciesData.length - idx) <= config.speciesElitism) {
        isStagnant = false;
      }

      if (isStagnant) {
        numNonStagnant -= 1;
      }

      result.add((sid, s, isStagnant));
      speciesFitnesses.add(s.fitness!);
    }

    return result;
  }
}
