import 'package:test/test.dart';
import 'package:neatdart/src/reproduction.dart';

void main() {
  test('reproduction spawnAdjust1', () async {
    final adjustedFitness = <double>[1.0, 0.0];
    final previousSizes = <int>[20, 20];
    final popSize = 40;
    final minSpeciesSize = 10;
    var spawn = Reproduction.computeSpawn(adjustedFitnesses: adjustedFitness, previousSizes: previousSizes, popSize: popSize, minSpeciesSize: minSpeciesSize);
    expect(spawn, [27, 13]);

    spawn = Reproduction.computeSpawn(adjustedFitnesses: adjustedFitness, previousSizes: spawn, popSize: popSize, minSpeciesSize: minSpeciesSize);
    expect(spawn, [30, 10]);

    spawn = Reproduction.computeSpawn(adjustedFitnesses: adjustedFitness, previousSizes: spawn, popSize: popSize, minSpeciesSize: minSpeciesSize);
    expect(spawn, [31, 10]);

    spawn = Reproduction.computeSpawn(adjustedFitnesses: adjustedFitness, previousSizes: spawn, popSize: popSize, minSpeciesSize: minSpeciesSize);
    expect(spawn, [31, 10]);
  });

  test('reproduction spawnAdjust2', () async {
    final adjustedFitness = <double>[0.5, 0.5];
    final previousSizes = <int>[20, 20];
    final popSize = 40;
    final minSpeciesSize = 10;

    final spawn = Reproduction.computeSpawn(adjustedFitnesses: adjustedFitness, previousSizes: previousSizes, popSize: popSize, minSpeciesSize: minSpeciesSize);
    expect(spawn, [20, 20]);
  });

  test('reproduction spawnAdjust3', () async {
    final adjustedFitness = <double>[0.5, 0.5];
    final previousSizes = <int>[30, 10];
    final popSize = 40;
    final minSpeciesSize = 10;

    var spawn = Reproduction.computeSpawn(adjustedFitnesses: adjustedFitness, previousSizes: previousSizes, popSize: popSize, minSpeciesSize: minSpeciesSize);
    expect(spawn, [25, 15]);

    spawn = Reproduction.computeSpawn(adjustedFitnesses: adjustedFitness, previousSizes: spawn, popSize: popSize, minSpeciesSize: minSpeciesSize);
    // due to number precision difference, the expect value is different from python
    expect(spawn, [22, 18]);

    spawn = Reproduction.computeSpawn(adjustedFitnesses: adjustedFitness, previousSizes: spawn, popSize: popSize, minSpeciesSize: minSpeciesSize);
    expect(spawn, [21, 19]);

    spawn = Reproduction.computeSpawn(adjustedFitnesses: adjustedFitness, previousSizes: spawn, popSize: popSize, minSpeciesSize: minSpeciesSize);
    expect(spawn, [20, 20]);

    spawn = Reproduction.computeSpawn(adjustedFitnesses: adjustedFitness, previousSizes: spawn, popSize: popSize, minSpeciesSize: minSpeciesSize);
    expect(spawn, [20, 20]);
  });
}
