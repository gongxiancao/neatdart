import 'genome.dart';
import 'config.dart';
import 'reporting.dart';
import 'reproduction.dart';
import 'species.dart';
import 'stagnation.dart';

abstract class FitnessDelegate {
  void evaluate({required Iterable<Genome> genomes, required GenomeContext context});
}

class InvalidConfigException implements Exception {
  final String message;
  InvalidConfigException(this.message);
}

class RuntimeException implements Exception {
  final String message;
  RuntimeException(this.message);
}

class CompleteExtinctionException implements Exception {
}

/// This class implements the core evolution algorithm:
///  1. Evaluate fitness of all genomes.
///  2. Check to see if the termination criterion is satisfied; exit if it is.
///  3. Generate the next generation from the current population.
///  4. Partition the new generation into species based on genetic similarity.
///  5. Go to 1.
class Population {
  final Context context;
  Config get config => context.config;
  final BaseReporter reporter;
  int generation = 0;
  late Map<int, Genome> population;
  final SpeciesSet species;
  Genome? bestGenome;
  Reproduction reproduction;

  Population({required this.context, required this.reporter})
    : reproduction = Reproduction(config: context.config.reproduction, reporter: reporter,
        stagnation: Stagnation(context: context.stagnation, reporter: reporter)),
      species = SpeciesSet(config: context.config.speciesSet, reporter: reporter)
  {
    population = reproduction.createNew(context.genome.config, context.genome.state, context.config.popSize);
    species.speciate(config: context.config, population: population, generation: generation);
  }

  /// Runs NEAT's genetic algorithm for at most n generations.  If n
  /// is None, run until solution is found or extinction occurs.
  ///
  /// The user-provided fitness_function must take only two arguments:
  ///     1. The population as a list of (genome id, genome) tuples.
  ///     2. The current configuration object.
  ///
  /// The return value of the fitness function is ignored, but it must assign
  /// a Python float to the `fitness` member of each genome.
  ///
  /// The fitness function is free to maintain external state, perform
  /// evaluations in parallel, etc.
  ///
  /// It is assumed that fitness_function does not modify the list of genomes,
  /// the genomes themselves (apart from updating the fitness member),
  /// or the configuration object.
  Genome run({required FitnessDelegate fitnessDelegate, required int generations}) {
    if (config.noFitnessTermination && generations <= 0) {
      throw InvalidConfigException('Cannot have no generational limit with no fitness termination');
    }

    int k = 0;
    while (generations <= 0 || k ++ < generations) {
      reporter.startGeneration(generation);

      // Evaluate all genomes using the user-provided function.
      fitnessDelegate.evaluate(genomes: population.values, context: context.genome);
      // Gather and report statistics.
      Genome? best = getBestGenome();

      reporter.postEvaluate(config: config, population: population, speciesSet: species, bestGenome: best!);

      // Track the best genome ever seen.
      if (bestGenome == null || best.fitness! > bestGenome!.fitness!) {
        bestGenome = best;
      }
      reporter.endGeneration(config: config, generation: generation, population: population, speciesSet: species);

      if (checkFitnessThreshold()) {
        break;
      }

      nextGeneration();
    }

    if (config.noFitnessTermination) {
      reporter.foundSolution(config: config, generation: generation, bestGenome: bestGenome!);
    }

    return bestGenome!;
  }

  Genome? getBestGenome() {
    // Gather and report statistics.
    Genome? best;
    for (final g in population.values) {
      if (g.fitness == null) {
        throw RuntimeException('Fitness not assigned to genome ${g.key}');
      }

      if (best == null || g.fitness! > best.fitness!) {
        best = g;
      }
    }
    return best;
  }

  bool checkFitnessThreshold() {
    // End if the fitness threshold is reached.
    final fitnesses = <double>[];
    for (final g in population.values) {
      fitnesses.add(g.fitness!);
    }

    final fv = context.fitnessCriterion(fitnesses);
    if (config.fitnessThreshold != 0 && fv >= config.fitnessThreshold) {
      return true;
    }
    return false;
  }

  void nextGeneration() {
    // Gather and report statistics.
    ++generation;
    Genome? best;
    for (final g in population.values) {
      if (g.fitness == null) {
        throw RuntimeException('Fitness not assigned to genome ${g.key}');
      }

      if (best == null || g.fitness! > best.fitness!) {
        best = g;
      }
    }

    // Track the best genome ever seen.
    if (bestGenome == null || best!.fitness! > bestGenome!.fitness!) {
      bestGenome = best;
    }

    // Create the next generation from the current generation.
    population = reproduction.reproduce(context: context, speciesSet: species,
        popSize: config.popSize, generation: generation);

    // Check for complete extinction.
    if (species.species.isEmpty) {
      reporter.completeExtinction();

      // If requested by the user, create a completely new population,
      // otherwise raise an exception.
      if (config.resetOnExtinction) {
        population = reproduction.createNew(context.genome.config, context.genome.state,  config.popSize);
      } else {
        throw CompleteExtinctionException();
      }
    }

    // Divide the new population into species.
    species.speciate(
        config: config, population: population, generation: generation);
  }
}
