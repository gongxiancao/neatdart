import 'package:neat_dart/src/species.dart';
import 'dart:math';
import 'math_utils.dart';
import 'reporting.dart';

class StagnationConfig {
  final String speciesFitness;
  final int maxStagnation;
  final int speciesElitism;
  StagnationConfig({
    required this.speciesFitness,
    required this.maxStagnation,
    required this.speciesElitism,
  });

  factory StagnationConfig.fromJson(Map<String, dynamic> data) {
    if (data case {
      'speciesFitness': String speciesFitness,
      'maxStagnation': int maxStagnation,
      'speciesElitism': int speciesElitism,
    }) {
      return StagnationConfig(
        speciesFitness: speciesFitness,
        maxStagnation: maxStagnation,
        speciesElitism: speciesElitism,
      );
    }
    throw FormatException('Invalid JSON: $data');
  }

  Map<String, dynamic> toJson() => {
    'speciesFitness': speciesFitness,
    'maxStagnation': maxStagnation,
    'speciesElitism': speciesElitism,
  };

  @override
  bool operator == (Object other) =>
    other is StagnationConfig &&
    other.runtimeType == runtimeType &&
    other.speciesFitness == speciesFitness &&
    other.maxStagnation == maxStagnation &&
    other.speciesElitism == speciesElitism;

  @override
  int get hashCode => Object.hash(
    speciesFitness,
    maxStagnation,
    speciesElitism,
  );
}

class StagnationContext {
  final StagnationConfig config;
  final double Function(List<double>) speciesFitness;
  final Map<String, double Function(Iterable<double>)> aggregationFunctionDefs;
  StagnationContext({
    required this.config,
    required this.aggregationFunctionDefs
  }): speciesFitness = aggregationFunctionDefs[config.speciesFitness]!;
}

/// Keeps track of whether species are making progress and helps remove ones that are not.
class Stagnation {
  final StagnationContext context;
  StagnationConfig get config => context.config;
  final BaseReporter reporter;

  Stagnation({required this.context, required this.reporter});

  /// Required interface method. Updates species fitness history information,
  /// checking for ones that have not improved in maxStagnation generations,
  /// and - unless it would result in the number of species dropping below the configured
  /// speciesElitism parameter if they were removed,
  /// in which case the highest-fitness species are spared -
  /// returns a list with stagnant species marked for removal.
  List<(int, Species, bool)> update(
      {required SpeciesSet speciesSet, required int generation}) {
    final speciesData = <(int, Species)>[];
    for (final entry in speciesSet.species.entries) {
      final sid = entry.key;
      final s = entry.value;
      final prevFitness = s.fitnessHistory.isNotEmpty
          ? s.fitnessHistory.reduce(max)
          : -double.maxFinite;

      s.fitness = context.speciesFitness(s.getFitnesses());
      s.fitnessHistory.add(s.fitness!);
      s.adjustedFitness = null;
      if (s.fitness! > prevFitness) {
        s.lastImproved = generation;
      }

      speciesData.add((sid, s));
    }

    // Sort in ascending fitness order.
    speciesData.sort(((int, Species) a, (int, Species) b) =>
        sign(a.$2.fitness! - b.$2.fitness!));

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
