import 'genome.dart';
import 'species.dart';
import 'config.dart';

abstract class BaseReporter {
  void startGeneration(int generation);
  void endGeneration({required Config config, required Map<int, Genome> population, required SpeciesSet speciesSet});
  void postEvaluate({required Config config, required Map<int, Genome> population, required SpeciesSet speciesSet, required Genome bestGenome});
  void postReproduction({required Config config, required Map<int, Genome> population, required SpeciesSet speciesSet});
  void completeExtinction();
  void foundSolution({required Config config, required int generation, required Genome bestGenome});
  void speciesStagnant({required int sid, required Species species});
  void info(String message);
}

class StdOutReporter implements BaseReporter {
  @override
  void startGeneration(int generation) {
    print('startGeneration $generation');
  }

  @override
  void endGeneration({required Config config, required Map<int, Genome> population, required SpeciesSet speciesSet}) {
    print('endGeneration');
  }

  @override
  void postEvaluate({required Config config, required Map<int, Genome> population, required SpeciesSet speciesSet, required Genome bestGenome}) {
    print('postEvaluate');
  }

  @override
  void postReproduction({required Config config, required Map<int, Genome> population, required SpeciesSet speciesSet}) {
    print('postReproduction');
  }

  @override
  void completeExtinction() {
    print('completeExtinction');
  }

  @override
  void foundSolution({required Config config, required int generation, required Genome bestGenome}) {
    print('foundSolution');
  }

  @override
  void speciesStagnant({required int sid, required Species species}) {
    print('speciesStagnant');
  }

  @override
  void info(String message) {
    print('info $message');
  }
}


/// Keeps track of the set of reporters
/// and gives methods to dispatch them at appropriate points.
class ReporterSet implements BaseReporter {
  final reporters = <BaseReporter>[];

  void add(BaseReporter reporter) {
    reporters.add(reporter);
  }

  @override
  void startGeneration(int generation) {
    for (final reporter in reporters) {
      reporter.startGeneration(generation);
    }
  }

  @override
  void endGeneration({required Config config, required Map<int, Genome> population, required SpeciesSet speciesSet}) {
    for (final reporter in reporters) {
      reporter.endGeneration(config: config, population: population, speciesSet: speciesSet);
    }
  }

  @override
  void postEvaluate({required Config config, required Map<int, Genome> population, required SpeciesSet speciesSet, required Genome bestGenome}) {
    for (final reporter in reporters) {
      reporter.postEvaluate(config: config, population: population, speciesSet: speciesSet, bestGenome: bestGenome);
    }
  }

  @override
  void postReproduction({required Config config, required Map<int, Genome> population, required SpeciesSet speciesSet}) {
    for (final reporter in reporters) {
      reporter.postReproduction(config: config, population: population, speciesSet: speciesSet);
    }
  }

  @override
  void completeExtinction() {
    for (final reporter in reporters) {
    reporter.completeExtinction();
    }
  }

  @override
  void foundSolution({required Config config, required int generation, required Genome bestGenome}) {
    for (final reporter in reporters) {
      reporter.foundSolution(config: config, generation: generation, bestGenome: bestGenome);
    }
  }

  @override
  void speciesStagnant({required int sid, required Species species}) {
    for (final reporter in reporters) {
      reporter.speciesStagnant(sid: sid, species: species);
    }
  }

  @override
  void info(String message) {
    for (final reporter in reporters) {
      reporter.info(message);
    }
  }
}
