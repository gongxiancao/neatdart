import 'genome.dart';
import 'stagnation.dart';
import 'reporting.dart';
import 'math_utils.dart';
import 'dart:math';
import 'config.dart';
import 'species.dart';
import 'random_utils.dart';

class ReproductionConfig {
  final int elitism;
  final double survivalThreshold;
  final int minSpeciesSize;

  ReproductionConfig({
    required this.elitism,
    required this.survivalThreshold,
    required this.minSpeciesSize,
  });
}

class Reproduction {
   final ReproductionConfig config;
   int genomeIndexer = 0;
   final BaseReporter reporter;
   final Stagnation stagnation;
   final ancestors = <int, (int, int)>{};

   Reproduction({
     required this.config,
     required this.reporter,
     required this.stagnation
   });

  int nextGenomeKey() {
    genomeIndexer += 1;
    return genomeIndexer;
  }

  Map<int, Genome> createNew(GenomeConfig genomeConfig, int popSize) {
    final newGenomes = <int, Genome>{};
    for (int i = 0; i < popSize; ++i) {
      final key = nextGenomeKey();
      final g = Genome(key);
      g.configureNew(genomeConfig);
      newGenomes[key] = g;
    }

    return newGenomes;
  }

  /// Compute the proper number of offspring per species (proportional to fitness).
  static List<int> computeSpawn({
    required List<double> adjustedFitnesses,
    required List<int> previousSizes,
    required int popSize,
    required int minSpeciesSize
  }) {
    final afSum = sum(adjustedFitnesses);

    final spawnAmounts = <int>[];
    for (final (index, af) in adjustedFitnesses.indexed) {
      final ps = previousSizes[index];
      final s = afSum > 0 ? max(minSpeciesSize, af / afSum * popSize) : minSpeciesSize;

      final double d = (s - ps) * 0.5;
      final int c = d.round();
      int spawn = ps;
      if (abs(c) > 0) {
        spawn += c;
      } else if (d > 0) {
        spawn += 1;
      } else if (d < 0) {
        spawn -= 1;
      }

      spawnAmounts.add(spawn);
    }

    // Normalize the spawn amounts so that the next generation is roughly
    // the population size requested by the user.
    final totalSpawn = sum(spawnAmounts);
    final norm = popSize / totalSpawn.toDouble();
    var spawnAmountsTuned = <int>[];
    for (final n in spawnAmounts) {
      spawnAmountsTuned.add(max(minSpeciesSize, (n * norm).round()));
    }

    return spawnAmountsTuned;
  }

  /// Handles creation of genomes, either from scratch or by sexual or
  /// asexual reproduction from parents.
  Map<int, Genome> reproduce({
    required Config config,
    required SpeciesSet speciesSet,
    required int popSize,
    required int generation
  }) {

    // TODO: I don't like this modification of the species and stagnation objects,
    // because it requires internal knowledge of the objects.

    // Filter out stagnated species, collect the set of non-stagnated
    // species members, and compute their average adjusted fitness.
    // The average adjusted fitness scheme (normalized to the interval
    // [0, 1]) allows the use of negative fitness values without
    // interfering with the shared fitness scheme.

    final allFitnesses = <double>[];
    final remainingSpecies = <Species>[];
    for (final (stagSid, stagS, stagnant) in stagnation.update(speciesSet: speciesSet, generation: generation)) {
      if (stagnant) {
        reporter.speciesStagnant(sid: stagSid, species: stagS);
      } else {
        for (final m in stagS.members!.values) {
          allFitnesses.add(m.fitness!);
        }

        remainingSpecies.add(stagS);
      }
    }
    // The above comment was not quite what was happening - now getting fitnesses
    // only from members of non-stagnated species.

    // No species left.
    if (remainingSpecies.isEmpty) {
      speciesSet.species = <int, Species>{};
      return <int, Genome>{};
    }

    // Find minimum/maximum fitness across the entire population, for use in
    // species adjusted fitness computation.
    final minFitness = allFitnesses.reduce(min);
    final maxFitness = allFitnesses.reduce(max);
    // Do not allow the fitness range to be zero, as we divide by it below.
    // TODO: The ``1.0`` below is rather arbitrary, and should be configurable.
    final fitnessRange = max(1.0, maxFitness - minFitness);

    var adjustedFitnesses = <double>[];
    for (final afs in remainingSpecies) {
      // Compute adjusted fitness.
      final speciesFitnesses = afs.members!.values.map((Genome g) => g.fitness!);
      final msf = mean(speciesFitnesses);
      final af = (msf - minFitness) / fitnessRange;
      afs.adjustedFitness = af;
      adjustedFitnesses.add(af);
    }

    final avgAdjustedFitness = mean(adjustedFitnesses);
    reporter.info('Average adjusted fitness: $avgAdjustedFitness');

    // Compute the number of new members for each species in the new generation.
    final previousSizes = remainingSpecies.map((Species s) => s.members!.length);

    int minSpeciesSize = this.config.minSpeciesSize;
    // Isn't the effective minSpeciesSize going to be max(minSpeciesSize,
    // self.reproduction_config.elitism)? That would probably produce more accurate tracking
    // of population sizes and relative fitnesses... doing. TODO: document.
    minSpeciesSize = max(minSpeciesSize, this.config.elitism);
    final spawnAmounts = Reproduction.computeSpawn(
      adjustedFitnesses: adjustedFitnesses,
      previousSizes: List<int>.from(previousSizes),
      popSize: popSize,
      minSpeciesSize: minSpeciesSize
    );

    final newPopulation = <int, Genome>{};
    speciesSet.species = <int, Species>{};
    for (final (index, s) in remainingSpecies.indexed) {
      // If elitism is enabled, each species always at least gets to retain its elites.
      var spawn = spawnAmounts[index];
      spawn = max(spawn, this.config.elitism);
      assert(spawn > 0);

      // The species has at least one member for the next generation, so retain it.
      // oldMembers has structure [MapEntry<int, Genome>)]
      var oldMembers = List<MapEntry<int, Genome>>.from(s.members!.entries);
      s.members = <int, Genome>{};
      speciesSet.species[s.key] = s;

      // Sort members in order of descending fitness.
      oldMembers.sort((MapEntry<int, Genome> a, MapEntry<int, Genome> b) => (b.value.fitness! - a.value.fitness!).toInt());

      // Transfer elites to new generation.
      if (this.config.elitism > 0) {
        int count = min(this.config.elitism, oldMembers.length);
        for (int i = 0; i < count; i ++) {
          final m = oldMembers[i];
          newPopulation[m.key] = m.value;
          spawn -= 1;
        }
      }

      if (spawn <= 0) {
        continue;
      }

      // Only use the survival threshold fraction to use as parents for the next generation.
      var reproCutoff = (this.config.survivalThreshold * oldMembers.length).ceil();
      // Use at least two parents no matter what the threshold fraction result is.
      reproCutoff = max(reproCutoff, 2);
      oldMembers = oldMembers.sublist(0, reproCutoff);

      // Randomly choose parents and produce the number of offspring allotted to the species.
      while (spawn > 0) {
        spawn -= 1;

        final kv1 = RandomUtils.choice(oldMembers);
        final parent1Id = kv1.key, parent1 = kv1.value;
        final kv2 = RandomUtils.choice(oldMembers);
        final parent2Id = kv2.key, parent2 = kv2.value;

        // Note that if the parents are not distinct, crossover will produce a
        // genetically identical clone of the parent (but with a different ID).
        final gid = nextGenomeKey();
        final child = Genome(gid);
        child.configureCrossover(parent1, parent2, config.genome);
        child.mutate(config.genome);
        newPopulation[gid] = child;
        ancestors[gid] = (parent1Id, parent2Id);
      }
    }

    return newPopulation;
  }

}
