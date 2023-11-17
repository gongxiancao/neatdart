import 'package:test/test.dart';
import 'dart:math';
import 'package:neatdart/src/graphs.dart';
import 'package:neatdart/src/genes.dart';
import 'package:neatdart/src/random_utils.dart';

void main() {
  test('graphs createsCycle', () async {
    expect(Graphs.createsCycle(ConnectionGeneKey.fromTuples([(0, 1), (1, 2), (2, 3)]), ConnectionGeneKey(0, 0)), true);

    expect(Graphs.createsCycle(ConnectionGeneKey.fromTuples([(0, 1), (1, 2), (2, 3)]), ConnectionGeneKey(1, 0)), true);
    expect(Graphs.createsCycle(ConnectionGeneKey.fromTuples([(0, 1), (1, 2), (2, 3)]), ConnectionGeneKey(0, 1)), false);

    expect(Graphs.createsCycle(ConnectionGeneKey.fromTuples([(0, 1), (1, 2), (2, 3)]), ConnectionGeneKey(2, 0)), true);
    expect(Graphs.createsCycle(ConnectionGeneKey.fromTuples([(0, 1), (1, 2), (2, 3)]), ConnectionGeneKey(0, 2)), false);

    expect(Graphs.createsCycle(ConnectionGeneKey.fromTuples([(0, 1), (1, 2), (2, 3)]), ConnectionGeneKey(3, 0)), true);
    expect(Graphs.createsCycle(ConnectionGeneKey.fromTuples([(0, 1), (1, 2), (2, 3)]), ConnectionGeneKey(0, 3)), false);

    expect(Graphs.createsCycle(ConnectionGeneKey.fromTuples([(0, 2), (1, 3), (2, 3), (4, 2)]), ConnectionGeneKey(3, 4)), true);
    expect(Graphs.createsCycle(ConnectionGeneKey.fromTuples([(0, 2), (1, 3), (2, 3), (4, 2)]), ConnectionGeneKey(4, 3)), false);
  });

  test('graphs requiredForOutput', () async {
    var inputs = [0, 1];
    var outputs = [2];
    var connections = ConnectionGeneKey.fromTuples([(0, 2), (1, 2)]);
    var required = Graphs.requiredForOutput(inputs: inputs, outputs: outputs, connections: connections);
    expect({2}, required);

    inputs = [0, 1];
    outputs = [2];
    connections = ConnectionGeneKey.fromTuples([(0, 3), (1, 4), (3, 2), (4, 2)]);
    required = Graphs.requiredForOutput(inputs: inputs, outputs: outputs, connections: connections);
    expect({2, 3, 4}, required);

    inputs = [0, 1];
    outputs = [3];
    connections = ConnectionGeneKey.fromTuples([(0, 2), (1, 2), (2, 3)]);
    required = Graphs.requiredForOutput(inputs: inputs, outputs: outputs, connections: connections);
    expect({2, 3}, required);

    inputs = [0, 1];
    outputs = [4];
    connections = ConnectionGeneKey.fromTuples([(0, 2), (1, 2), (1, 3), (2, 3), (2, 4), (3, 4)]);
    required = Graphs.requiredForOutput(inputs: inputs, outputs: outputs, connections: connections);
    expect({2, 3, 4}, required);

    inputs = [0, 1];
    outputs = [4];
    connections = ConnectionGeneKey.fromTuples([(0, 2), (1, 3), (2, 3), (3, 4), (4, 2)]);
    required = Graphs.requiredForOutput(inputs: inputs, outputs: outputs, connections: connections);
    expect({2, 3, 4}, required);

    inputs = [0, 1];
    outputs = [4];
    connections = ConnectionGeneKey.fromTuples([(0, 2), (1, 2), (1, 3), (2, 3), (2, 4), (3, 4), (2, 5)]);
    required = Graphs.requiredForOutput(inputs: inputs, outputs: outputs, connections: connections);
    expect({2, 3, 4}, required);
  });

  test('graphs fuzzRequired', () async {
    for (int i = 0; i < 1000; ++i) {
      final nHidden = RandomUtils.nextInt(10, 100);
      final nIn = RandomUtils.nextInt(1, 10);
      final nOut = RandomUtils.nextInt(1, 10);

      final nodesSet = <int>{};
      final total = nIn + nOut + nHidden;
      for (int i = 0; i < total; ++i) {
        nodesSet.add(RandomUtils.nextInt(0, 1000));
      }
      final nodes = List<int>.from(nodesSet);
      nodes.shuffle();

      final inputs = nodes.sublist(0, min(nIn, nodes.length));
      final outputs = nodes.sublist(nIn, min(nIn + nOut, nodes.length));
      var connections = <ConnectionGeneKey>[];
      for (int i = nHidden * 2; i > 0; --i) {
        final a = RandomUtils.choice(nodes);
        final b = RandomUtils.choice(nodes);
        if (a == b) {
         continue;
        }
        if (inputs.contains(a) && inputs.contains(b)) {
          continue;
        }
        if (outputs.contains(a) && outputs.contains(b)) {
          continue;
        }
        connections.add(ConnectionGeneKey(a, b));
      }

      final required = Graphs.requiredForOutput(inputs: inputs, outputs: outputs, connections: connections);
      for (final o in outputs) {
        expect(required.contains(o), true);
      }
    }
  });

  test('graphs feedForwardLayers', () async {
    var inputs = [0, 1];
    var outputs = [2];
    var connections = ConnectionGeneKey.fromTuples([(0, 2), (1, 2)]);
    var layers = Graphs.feedForwardLayers(inputs: inputs, outputs: outputs, connections: connections);
    expect([{2}], layers);

    inputs = [0, 1];
    outputs = [3];
    connections = ConnectionGeneKey.fromTuples([(0, 2), (1, 2), (2, 3)]);
    layers = Graphs.feedForwardLayers(inputs: inputs, outputs: outputs, connections: connections);
    expect([{2}, {3}], layers);

    inputs = [0, 1];
    outputs = [4];
    connections = ConnectionGeneKey.fromTuples([(0, 2), (1, 2), (1, 3), (2, 3), (2, 4), (3, 4)]);
    layers = Graphs.feedForwardLayers(inputs: inputs, outputs: outputs, connections: connections);
    expect([{2}, {3}, {4}], layers);

    inputs = [0, 1, 2, 3];
    outputs = [11, 12, 13];
    connections = ConnectionGeneKey.fromTuples([(0, 4), (1, 4), (1, 5), (2, 5), (2, 6), (3, 6), (3, 7),
      (4, 8), (5, 8), (5, 9), (5, 10), (6, 10), (6, 7),
      (8, 11), (8, 12), (8, 9), (9, 10), (7, 10),
      (10, 12), (10, 13)]);
    layers = Graphs.feedForwardLayers(inputs: inputs, outputs: outputs, connections: connections);
    expect([{4, 5, 6}, {8, 7}, {9, 11}, {10}, {12, 13}], layers);

    inputs = [0, 1, 2, 3];
    outputs = [11, 12, 13];
    connections = ConnectionGeneKey.fromTuples([(0, 4), (1, 4), (1, 5), (2, 5), (2, 6), (3, 6), (3, 7),
      (4, 8), (5, 8), (5, 9), (5, 10), (6, 10), (6, 7),
      (8, 11), (8, 12), (8, 9), (9, 10), (7, 10),
      (10, 12), (10, 13),
      (3, 14), (14, 15), (5, 16), (10, 16)]);
    layers = Graphs.feedForwardLayers(inputs: inputs, outputs: outputs, connections: connections);
    expect([{4, 5, 6}, {8, 7}, {9, 11}, {10}, {12, 13}], layers);
  });

  test('graphs fuzzFeedForwardLayers', () async {
    for (int i = 0; i < 1000; ++i) {
      final nHidden = RandomUtils.nextInt(10, 100);
      final nIn = RandomUtils.nextInt(1, 10);
      final nOut = RandomUtils.nextInt(1, 10);

      final nodesSet = <int>{};
      for (int i = nIn + nOut + nHidden; i > 0; --i) {
        nodesSet.add(RandomUtils.nextInt(0, 1000));
      }
      final nodes = List<int>.from(nodesSet);
      nodes.shuffle();

      final inputs = nodes.sublist(0, nIn);
      final outputs = nodes.sublist(nIn, nIn + nOut);
      final connections = <ConnectionGeneKey>[];
      for (int i = nHidden * 2; i > 0; --i) {
        final a = RandomUtils.choice(nodes);
        final b = RandomUtils.choice(nodes);
        if (a == b) {
          continue;
        }
        if (inputs.contains(a) && inputs.contains(b)) {
          continue;
        }
        if (outputs.contains(a) && outputs.contains(b)) {
          continue;
        }
        connections.add(ConnectionGeneKey(a, b));
      }

      Graphs.feedForwardLayers(inputs: inputs, outputs: outputs, connections: connections);
    }
  });

  test('graphs recurrentLayers', () async {
    var inputs = [0, 1];
    var outputs = [2, 3];
    var connections = ConnectionGeneKey.fromTuples([(0, 2), (1, 2), (1, 4), (4, 3), (3,4)]);
    var layers = Graphs.recurrentLayers(inputs: inputs, outputs: outputs, connections: connections);
    expect([{4, 2}, {3}], layers);

    inputs = [-1, -2, -3, -4, -5, -6, -7];
    outputs = [0, 1, 2, 3];
    connections = ConnectionGeneKey.fromTuples([
      (-6, 2),
      (-7, 1),
      (-4, 1),
      (-3, 1),
      (-6, 0),
      (-3, 3),
      (2, 2),
      (-1, 1),
      (-7, 3),
      (-1, 0),
      (1, 1),
      (0, 0),
      (-4, 2),
      (-2, 2),
      (-1, 2),
      (-4, 3),
      (-5, 0),
      (-7, 2),
      (-7, 0),
      (-5, 3),
      (-6, 1),
      (-6, 3),
      (-3, 2),
      (-3, 0),
      (-2, 9),
      (-2, 3),
      (-1, 3),
      (-5, 1),
      (-2, 1),
      (-5, 2)
    ]);
    layers = Graphs.recurrentLayers(inputs: inputs, outputs: outputs, connections: connections);
    expect([{3, 2, 0, 1}], layers);
  });

}
