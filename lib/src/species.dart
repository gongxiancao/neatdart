import 'genome.dart';
import 'config.dart';
import 'math_utils.dart';
import 'reporting.dart';

class Species {
  final int key;
  final int created;
  int lastImproved;
  Genome? representative;
  Map<int, Genome>? members;
  double? fitness;
  double? adjustedFitness;
  final fitnessHistory = <double>[];

  Species(
    this.key,
    int generation
  ): created = generation, lastImproved = generation;

  void update({required Genome representative, required Map<int, Genome> members}) {
    this.representative = representative;
    this.members = members;
  }

  List<double> getFitnesses() {
    final fitnesses = <double>[];
    for (final m in members!.values) {
      fitnesses.add(m.fitness!);
    }
    return fitnesses;
  }
}

class GenomeDistanceCacheKey {
  final int key1;
  final int key2;
  GenomeDistanceCacheKey(this.key1, this.key2);
}

class GenomeDistanceCache {
   final GenomeConfig config;
   final distances = <GenomeDistanceCacheKey, double>{};
   int hits = 0;
   int misses = 0;

   GenomeDistanceCache(this.config);

  double get(Genome genome1, Genome genome2) {
    final g1 = genome1.key;
    final g2 = genome2.key;
    final key = GenomeDistanceCacheKey(g1, g2);
    var d = distances[key];
    if (d == null) {
      // Distance is not already computed.
      d = genome1.distance(other: genome2, config: config);
      distances[key] = d;
      distances[GenomeDistanceCacheKey(g2, g1)] = d;
      misses += 1;
    } else {
      hits += 1;
    }

    return d;
  }
}

class SpeciesSetConfig {
  final double compatibilityThreshold;
  SpeciesSetConfig({required this.compatibilityThreshold});
}

/// Encapsulates the default speciation scheme.
class SpeciesSet {

  final SpeciesSetConfig config;
  var species = <int, Species>{};
  final BaseReporter reporter;
  int indexer = 0;
  Map<int, int>? genomeToSpecies;

  SpeciesSet({required this.config, required this.reporter});

  int nextId() {
    indexer += 1;
    return indexer;
  }

  /// Place genomes into species by genetic similarity.
  ///
  /// Note that this method assumes the current representatives of the species are from the old
  /// generation, and that after speciation has been performed, the old representatives should be
  /// dropped and replaced with representatives from the new generation.  If you violate this
  /// assumption, you should make sure other necessary parts of the code are updated to reflect
  /// the new behavior.
  void speciate({required Config config, required Map<int, Genome> population, required int generation}) {
    final compatibilityThreshold = this.config.compatibilityThreshold;

    // Find the best representatives for each existing species.
    final unspeciated = Set<int>.from(population.keys);
    final distances = GenomeDistanceCache(config.genome);
    final newRepresentatives = <int, int>{};
    var newMembers = <int, List<int>>{};
    for (final entry in species.entries) {
      final sid = entry.key;
      final s = entry.value;
      final candidates = <(double, Genome)>[];
      for (final gid in unspeciated) {
        final g = population[gid]!;
        final d = distances.get(s.representative!, g);
        candidates.add((d, g));
      }

      // The new representative is the genome closest to the current representative.
      final dg = candidates.reduce((value, element) => value.$1 < element.$1 ? value : element);

      final newRep = dg.$2;
      final newRid = newRep.key;
      newRepresentatives[sid] = newRid;
      newMembers[sid] = [newRid];
      unspeciated.remove(newRid);
    }

    // Partition population into species based on genetic similarity.
    for (final gid in unspeciated) {
      final g = population[gid]!;

      // Find the species with the most similar representative.
      var candidates = <(double, int)>[];
      for (final entry in newRepresentatives.entries) {
        final sid = entry.key;
        final rid = entry.value;
        final rep = population[rid]!;
        final d = distances.get(rep, g);
        if (d < compatibilityThreshold) {
          candidates.add((d, sid));
        }
      }

      if (candidates.isNotEmpty) {
        final dg = candidates.reduce((value, element) => value.$1 < element.$1 ? value : element);
        final sid = dg.$2;
        newMembers[sid]!.add(gid);
      } else {
        // No species is similar enough, create a new species, using
        // this genome as its representative.
        final sid = nextId();
        newRepresentatives[sid] = gid;
        newMembers[sid] = [gid];
      }
    }

    // Update species collection based on new speciation.
    genomeToSpecies = <int, int>{};
    for (final entry in newRepresentatives.entries) {
      final sid = entry.key;
      final rid = entry.value;
      var s = species[sid];
      if (s == null) {
        s = Species(sid, generation);
        species[sid] = s;
      }

      final members = newMembers[sid]!;
      for (final gid in members) {
        genomeToSpecies![gid] = sid;
      }

      var memberDict = <int, Genome>{};
      for (final gid in members) {
        memberDict[gid] = population[gid]!;
      }
      s.update(representative: population[rid]!, members: memberDict);
    }

    final gdmean = mean(distances.distances.values);
    final gdstdev = stdev(distances.distances.values);
    reporter.info('Mean genetic distance $gdmean, standard deviation $gdstdev');
  }
}
