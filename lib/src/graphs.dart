import 'genes.dart';

class Graphs {
  ///
  /// Returns true if the addition of the 'test' connection would create a cycle,
  /// assuming that no cycle already exists in the graph represented by 'connections'.
  ///
  static bool createsCycle(List<ConnectionGeneKey> connections, ConnectionGeneKey test) {
    final i = test.inputKey;
    final o = test.outputKey;
    if (i == o) {
      return true;
    }

    final visited = <int>{};
    while (true) {
      var numAdded = 0;
      for (final key in connections) {
        final a = key.inputKey;
        final b = key.outputKey;
        if (visited.contains(a) && !visited.contains(b)) {
          if (b == i) {
            return true;
          }
          visited.add(b);
          numAdded += 1;
        }
      }
      if (numAdded == 0) {
        return false;
      }
    }
  }

  ///  Collect the nodes whose state is required to compute the final network output(s).
  ///  :param inputs: list of the input identifiers
  ///  :param outputs: list of the output node identifiers
  ///  :param connections: list of (input, output) connections in the network.
  ///  NOTE: It is assumed that the input identifier set and the node identifier set are disjoint.
  ///  By convention, the output node ids are always the same as the output index.
  ///
  ///  Returns a set of identifiers of required nodes.
  static Set<int> requiredForOutput(List<int> inputs, List<int> outputs, List<ConnectionGeneKey> connections) {
    var required = Set<int>.from(outputs);
    var s = Set<int>.from(outputs);
    while (true) {
    // Find nodes not in S whose output is consumed by a node in s.
      var t = <int>{};
      for (final key in connections) {
        if(s.contains(key.outputKey) && !s.contains(key.inputKey)) {
          t.add(key.inputKey);
        }
      }

      if (t.isEmpty) {
        break;
      }
      final layerNodes = <int>{};
      for (final x in t) {
        if (!inputs.contains(x)) {
          layerNodes.add(x);
        }
      }

      if (layerNodes.isEmpty) {
        break;
      }

      required = required.union(layerNodes);
      s = s.union(t);
    }

    return required;
  }


  ///
  ///  Collect the layers whose members can be evaluated in parallel in a feed-forward network.
  ///  :param inputs: list of the network input nodes
  ///  :param outputs: list of the output node identifiers
  ///  :param connections: list of (input, output) connections in the network.
  ///
  ///  Returns a list of layers, with each layer consisting of a set of node identifiers.
  ///  Note that the returned layers do not contain nodes whose output is ultimately
  ///  never used to compute the final network output.
  static List<Set<int>> feedForwardLayers(List<int> inputs, List<int> outputs, List<ConnectionGeneKey> connections) {
    final required = requiredForOutput(inputs, outputs, connections);

    final layers = <Set<int>>[];
    var s = Set<int>.from(inputs);
    while (true) {
      // Find candidate nodes c for the next layer.  These nodes should connect
      // a node in s to a node not in s.
      final c = <int>{};
      for (final k in connections) {
        if (s.contains(k.inputKey) && !s.contains(k.outputKey)) {
          c.add(k.outputKey);
        }
      }

      // Keep only the used nodes whose entire input set is contained in s.
      final t = <int>{};
      for (final n in c) {
        if (required.contains(n)) {
          var hasOtherInput = false;
          for (final k in connections) {
            if (k.outputKey == n && !s.contains(k.inputKey)) {
              hasOtherInput = true;
            }
          }
          if(!hasOtherInput) {
            t.add(n);
          }
        }
      }

      if (t.isEmpty) {
        break;
      }

      layers.add(t);
      s = s.union(t);
    }

    // if (!validateLayers(inputs, outputs, connections, layers)) {
    //   print("meet invalid layers");
    // }
    return layers;
  }

  ///
  ///  Collect the layers whose members can be evaluated in parallel in a recurrent network.
  ///  :param inputs: list of the network input nodes
  ///  :param outputs: list of the output node identifiers
  ///  :param connections: list of (input, output) connections in the network.
  ///
  ///  Returns a list of layers, with each layer consisting of a set of node identifiers.
  ///  Note that the returned layers do not contain nodes whose output is ultimately
  ///  never used to compute the final network output.
  ///
  static List<Set<int>> recurrentLayers(List<int> inputs, List<int> outputs, List<ConnectionGeneKey> connections) {
    final required = requiredForOutput(inputs, outputs, connections);

    final layers = <Set<int>>[];
    var s = Set<int>.from(inputs);
    while (true) {
      // Find candidate nodes c for the next layer.  These nodes should connect
      // a node in s to a node not in s.
      final t = <int>{};
      for (final k in connections) {
        final i = k.inputKey;
        final o = k.outputKey;
        if (!required.contains(o) && !required.contains(i)) {
          continue;
        }
        if (s.contains(i) && !s.contains(o)) {
          t.add(o);
        }
      }

      if (t.isEmpty) {
        break;
      }

      layers.add(t);
      s = s.union(t);
    }
    // if !validateLayers(inputs, outputs, connections, layers) {
    //     print("meet invalid layers")
    // }
    return layers;
  }

  static bool validateLayers(List<int> inputs, List<int> outputs, List<ConnectionGeneKey> connections, List<Set<int>> layers) {
    final layerNodes = <int>{};
    for (final layer in layers) {
      for (final node in layer) {
        layerNodes.add(node);
      }
    }

    final inputNodes = <int>{};
    for (final input in inputs) {
      inputNodes.add(input);
    }

    for (final output in outputs) {
      if (!layerNodes.contains(output)) {
        return false;
      }
    }

    for (final connection in connections) {
      if ((!inputNodes.contains(connection.inputKey) && !layerNodes.contains(connection.inputKey)) || !layerNodes.contains(connection.outputKey)) {
        return false;
      }
    }
    return true;
  }
}
