import 'genes.dart';
import 'dart:math';
import 'graphs.dart';
import 'random_utils.dart';

enum InitialConnection {
  none,
  fsNeatNohidden,
  fsNeatHidden,
  fullNodirect,
  fullDirect,
  partialNodirect,
  partialDirect,
}

class GenomeSize {
  int numNodes;
  int numEnabledConnections;
  GenomeSize(this.numNodes, this.numEnabledConnections);
}

class GenomeConfig {
  int numInputs;
  int numOutputs;
  int numHidden;
  InitialConnection initialConnection;
  double connectionFraction;
  bool singleStructuralMutation;
  bool structuralMutationSurer;
  double compatibilityDisjointCoefficient;
  double nodeAddProb;
  double nodeDeleteProb;
  double connAddProb;
  double connDeleteProb;
  bool recurrent;
  NodeGeneConfig node;
  ConnectionGeneConfig connection;

  List<int> inputKeys;
  List<int> outputKeys;

  var outputKeysIndex = <int, bool>{};

  GenomeConfig({
    required this.numInputs,
    required this.numOutputs,
    required this.numHidden,
    required this.initialConnection,
    required this.connectionFraction,
    required this.singleStructuralMutation,
    required this.structuralMutationSurer,
    required this.compatibilityDisjointCoefficient,
    required this.nodeAddProb,
    required this.nodeDeleteProb,
    required this.connAddProb,
    required this.connDeleteProb,
    required this.recurrent,
    required this.node,
    required this.connection,
  }): inputKeys = [], outputKeys = [] {

    // By convention, input pins have negative keys, and the output
    // pins have keys 0,1,...

    for (int i = 0; i < numInputs; ++i) {
      inputKeys.add(-i - 1);
    }

    for (int i = 0; i < numOutputs; ++i) {
      outputKeys.add(i);
    }

    for (var key in outputKeys) {
      outputKeysIndex[key] = true;
    }
  }

  factory GenomeConfig.fromJson(Map<String, dynamic> data) {
    if (data case {
      'numInputs': int numInputs,
      'numOutputs': int numOutputs,
      'numHidden': int numHidden,
      'initialConnection': String initialConnection,
      'connectionFraction': double connectionFraction,
      'singleStructuralMutation': bool singleStructuralMutation,
      'structuralMutationSurer': bool structuralMutationSurer,
      'compatibilityDisjointCoefficient': double compatibilityDisjointCoefficient,
      'nodeAddProb': double nodeAddProb,
      'nodeDeleteProb': double nodeDeleteProb,
      'connAddProb': double connAddProb,
      'connDeleteProb': double connDeleteProb,
      'recurrent': bool recurrent,
      'node': Map<String, dynamic> node,
      'connection': Map<String, dynamic> connection,
    }) {
      return GenomeConfig(
        numInputs: numInputs,
        numOutputs: numOutputs,
        numHidden: numHidden,
        initialConnection: InitialConnection.values.byName(initialConnection),
        connectionFraction: connectionFraction,
        singleStructuralMutation: singleStructuralMutation,
        structuralMutationSurer: structuralMutationSurer,
        compatibilityDisjointCoefficient: compatibilityDisjointCoefficient,
        nodeAddProb: nodeAddProb,
        nodeDeleteProb: nodeDeleteProb,
        connAddProb: connAddProb,
        connDeleteProb: connDeleteProb,
        recurrent: recurrent,
        node: NodeGeneConfig.fromJson(node),
        connection: ConnectionGeneConfig.fromJson(connection),
      );
    }
    throw FormatException('Invalid JSON: $data');
  }

  Map<String, dynamic> toJson() => {
    'numInputs': numInputs,
    'numOutputs': numOutputs,
    'numHidden': numHidden,
    'initialConnection': initialConnection.name,
    'connectionFraction': connectionFraction,
    'singleStructuralMutation': singleStructuralMutation,
    'structuralMutationSurer': structuralMutationSurer,
    'compatibilityDisjointCoefficient': compatibilityDisjointCoefficient,
    'nodeAddProb': nodeAddProb,
    'nodeDeleteProb': nodeDeleteProb,
    'connAddProb': connAddProb,
    'connDeleteProb': connDeleteProb,
    'recurrent': recurrent,
    'node': node.toJson(),
    'connection': connection.toJson(),
  };

  @override
  bool operator == (Object other) =>
    other is GenomeConfig &&
    other.runtimeType == runtimeType &&
    other.numInputs == numInputs &&
    other.numOutputs == numOutputs &&
    other.numHidden == numHidden &&
    other.initialConnection == initialConnection &&
    other.connectionFraction == connectionFraction &&
    other.singleStructuralMutation == singleStructuralMutation &&
    other.structuralMutationSurer == structuralMutationSurer &&
    other.compatibilityDisjointCoefficient == compatibilityDisjointCoefficient &&
    other.nodeAddProb == nodeAddProb &&
    other.nodeDeleteProb == nodeDeleteProb &&
    other.connAddProb == connAddProb &&
    other.connDeleteProb == connDeleteProb &&
    other.recurrent == recurrent &&
    other.node == node &&
    other.connection == connection;

  @override
  int get hashCode => Object.hash(
    numInputs,
    numOutputs,
    numHidden,
    initialConnection,
    connectionFraction,
    singleStructuralMutation,
    structuralMutationSurer,
    compatibilityDisjointCoefficient,
    nodeAddProb,
    nodeDeleteProb,
    connAddProb,
    connDeleteProb,
    recurrent,
    node,
    connection,
  );
}

class GenomeState {
  int nodeIndexer;
  GenomeState({
    this.nodeIndexer = 0,
  });

  factory GenomeState.fromJson(Map<String, dynamic> data) {
    if (data case {
      'nodeIndexer': int nodeIndexer,
    }) {
      return GenomeState(
          nodeIndexer: nodeIndexer
      );
    }
    throw FormatException('Invalid JSON: $data');
  }

  Map<String, dynamic> toJson() => {
    'nodeIndexer': nodeIndexer,
  };

  @override
  bool operator == (Object other) =>
      other is GenomeState &&
          other.runtimeType == runtimeType &&
          other.nodeIndexer == nodeIndexer;

  @override
  int get hashCode => nodeIndexer.hashCode;
}

class GenomeContext {
  final GenomeConfig config;
  final GenomeState state;
  final Map<String, double Function(Iterable<double>)> aggregationFunctionDefs;
  final Map<String, double Function(double)> activationDefs;
  GenomeContext({
    required this.config,
    required this.state,
    required this.aggregationFunctionDefs,
    required this.activationDefs
  }) {
    state.nodeIndexer = state.nodeIndexer == 0 ? config.outputKeys.reduce(max) : state.nodeIndexer;
  }
}

class Genome {
  // dictionary for non-input nodes, as input nodes don't have any properties, no way to evolve them.
  final int key;
  final nodes = <int, NodeGene>{};
  final connections = <ConnectionGeneKey, ConnectionGene>{};
  double? fitness;

  Genome(this.key);

  /// According to the paper, the innovation number should be global
  int getNewNodeKey(GenomeState state) {
    return ++state.nodeIndexer;
  }

  factory Genome.fromJson(Map<String, dynamic> data) {
    if (data case {
      'key': int key,
      'nodes': List<Map<String,dynamic>> nodes,
      'connections': List<Map<String, dynamic>> connections,
      'fitness': num? fitness
    }) {
      final genome = Genome(key);
      for (final nodeData in nodes) {
        final node = NodeGene.fromJson(nodeData);
        genome.nodes[node.key] = node;
      }
      for (final connectionData in connections) {
        final connection = ConnectionGene.fromJson(connectionData);
        genome.connections[connection.key] = connection;
      }
      genome.fitness = fitness?.toDouble();
      return genome;
    }
    throw FormatException('Invalid JSON: $data');
  }

  Map<String, dynamic> toJson() => {
    'key': key,
    'nodes': List<Map<String, dynamic>>.from(nodes.values.map((e) => e.toJson())),
    'connections': List<Map<String, dynamic>>.from(connections.values.map((e) => e.toJson())),
    'fitness': fitness
  };

  NodeGene createNode(NodeGeneConfig config, int key) {
    final node = NodeGene(key);
    node.initAttributes(config);
    return node;
  }

  ConnectionGene createConnection(ConnectionGeneConfig config, ConnectionGeneKey key) {
    final connection = ConnectionGene(key);
    connection.initAttributes(config);
    return connection;
  }

  ConnectionGene createConnectionWithNodeKeys(ConnectionGeneConfig config, int inputKey, int outputKey) {
    return createConnection(config, ConnectionGeneKey(inputKey, outputKey));
  }

  /// Configure a new genome based on the given configuration.
  void configureNew(GenomeConfig config, GenomeState state) {
    // Create node genes for the output pins.
    for (var nodeKey in config.outputKeys) {
      nodes[nodeKey] = createNode(config.node, nodeKey);
    }

    // Add hidden nodes if requested.
    if (config.numHidden > 0) {
      for (int i = 0; i < config.numHidden; ++i) {
        final nodeKey = getNewNodeKey(state);
        assert(nodes[nodeKey] == null);
        final node = createNode(config.node, nodeKey);
        nodes[nodeKey] = node;
      }
    }

    // Add connections based on initial connectivity type.
    switch (config.initialConnection) {
      case InitialConnection.none:
        break;
      case InitialConnection.fsNeatNohidden:
        connectFsNeatNohidden(config);
      case InitialConnection.fsNeatHidden:
        connectFsNeatHidden(config);
      case InitialConnection.fullNodirect:
        connectFullNodirect(config);
      case InitialConnection.fullDirect:
        connectFullDirect(config);
      case InitialConnection.partialNodirect:
        connectPartialNodirect(config);
      case InitialConnection.partialDirect:
        connectPartialDirect(config);
    }
  }

  /// Configure a new genome by crossover from two parent genomes.
  void configureCrossover(Genome genome1, Genome genome2, GenomeConfig config) {
    final isGenome1Better = genome1.fitness! > genome2.fitness!;
    final parent1 = isGenome1Better ? genome1 : genome2;
    final parent2 = isGenome1Better ? genome2 : genome1;

    // Inherit connection genes
    for (var entry in parent1.connections.entries) {
      final key = entry.key;
      final cg1 = entry.value;
      final cg2 = parent2.connections[key];
      if (cg2 == null) {
        // Excess or disjoint gene: copy from the fittest parent.
        connections[key] = cg1.copy();
      } else {
        // Homologous gene: combine genes from both parents.
        connections[key] = cg1.crossover(cg2);
      }
    }

    // Inherit node genes
    final parent1Set = parent1.nodes;
    final parent2Set = parent2.nodes;

    for (var entry in parent1Set.entries) {
      final key = entry.key;
      final ng1 = entry.value;
      final ng2 = parent2Set[key];
      if (ng2 == null) {
        // Extra gene: copy from the fittest parent
        nodes[key] = ng1.copy();
      } else {
        // Homologous gene: combine genes from both parents.
        nodes[key] = ng1.crossover(ng2);
      }
    }
  }

  /// Randomly connect one input to all output nodes
  /// (FS-NEAT without connections to hidden, if any).
  /// Originally connect_fs_neat.
  void connectFsNeatNohidden(GenomeConfig config) {
    final inputKey = RandomUtils.choice(config.inputKeys);
    for (var outputKey in config.outputKeys) {
      final connection = createConnectionWithNodeKeys(config.connection, inputKey, outputKey);
      connections[connection.key] = connection;
    }
  }

  /// Randomly connect one input to all hidden and output nodes
  /// (FS-NEAT with connections to hidden, if any).
  connectFsNeatHidden(GenomeConfig config) {
    final inputKey = RandomUtils.choice(config.inputKeys);
    for (var outputKey in nodes.keys) {
      final connection = createConnectionWithNodeKeys(config.connection, inputKey, outputKey);
      connections[connection.key] = connection;
    }
  }

  /// Compute connections for a fully-connected feed-forward genome--each
  /// input connected to all hidden nodes
  /// (and output nodes if ``direct`` is set or there are no hidden nodes),
  /// each hidden node connected to all output nodes.
  /// (Recurrent genomes will also include node self-connections.)
  List<ConnectionGeneKey> computeFullConnections(bool direct, GenomeConfig config) {
    final hidden = <int>[];
    for (var i in nodes.keys) {
      if (config.outputKeysIndex[i] == null) {
        hidden.add(i);
      }
    }

    final output = config.outputKeys;
    final connections = <ConnectionGeneKey>[];
    if (hidden.isNotEmpty) {
      for (var inputId in config.inputKeys) {
        for (var h in hidden) {
          connections.add(ConnectionGeneKey(inputId, h));
        }
      }
      for (var h in hidden) {
        for (var outputId in output) {
          connections.add(ConnectionGeneKey(h, outputId));
        }
      }
    }
    if (direct || hidden.isEmpty) {
      for (var inputId in config.inputKeys) {
        for (var outputId in output) {
          connections.add(ConnectionGeneKey(inputId, outputId));
        }
      }
    }

    // For recurrent genomes, include node self-connections.
    if (config.recurrent) {
      final hiddenNodes = Set<int>.from(nodes.keys).difference(Set<int>.from(config.outputKeys));
      for (var i in hiddenNodes) {
        connections.add(ConnectionGeneKey(i, i));
      }
    }

    return connections;
  }

  /// Create a fully-connected genome
  /// (except without direct input-output unless no hidden nodes).
  void connectFullNodirect(GenomeConfig config) {
    for (var key in computeFullConnections(false, config)) {
      final connection = createConnection(config.connection, key);
      connections[key] = connection;
    }
  }

  /// Create a fully-connected genome
  /// (except without direct input-output unless no hidden nodes).
  void connectFullDirect(GenomeConfig config) {
    for (var key in computeFullConnections(true, config)) {
      final connection = createConnection(config.connection, key);
      connections[key] = connection;
    }
  }

  void connectPartial(bool direct, GenomeConfig config) {
    final allConnections = computeFullConnections(false, config);
    allConnections.shuffle();

    final numToAdd = min((allConnections.length * config.connectionFraction).round(), allConnections.length);
    for (var i = 0; i < numToAdd; ++i) {
      final key = allConnections[i];
      final connection = createConnection(config.connection, key);
      connections[key] = connection;
    }
  }

  /// Create a fully-connected genome, including direct input-output connections.
  void connectPartialNodirect(GenomeConfig config) {
    connectPartial(false, config);
  }

  /// Create a partially-connected genome,
  /// including (possibly) direct input-output connections.
  void connectPartialDirect(GenomeConfig config) {
    connectPartial(true, config);
  }

  /// Mutates this genome.
  void mutate(GenomeConfig config, GenomeState state) {
    // print('mutate $key');
    if (config.singleStructuralMutation) {
      final div = max(1, (config.nodeAddProb + config.nodeDeleteProb + config.connAddProb + config.connDeleteProb));
      final r = RandomUtils.nextDouble();
      if (r < (config.nodeAddProb / div)) {
        mutateAddNode(config, state);
      } else if (r < ((config.nodeAddProb + config.nodeDeleteProb) / div)) {
        mutateDeleteNode(config);
      } else if (r < ((config.nodeAddProb + config.nodeDeleteProb + config.connAddProb)/div)) {
        mutateAddConnection(config);
      } else if (r < ((config.nodeAddProb + config.nodeDeleteProb + config.connAddProb + config.connDeleteProb)/div)) {
        mutateDeleteConnection();
      }
    } else {
      if (RandomUtils.nextDouble() < config.nodeAddProb) {
        mutateAddNode(config, state);
      }

      if (RandomUtils.nextDouble() < config.nodeDeleteProb) {
        mutateDeleteNode(config);
      }

      if (RandomUtils.nextDouble() < config.connAddProb) {
        mutateAddConnection(config);
      }

      if (RandomUtils.nextDouble() < config.connDeleteProb) {
        mutateDeleteConnection();
      }
    }

    // Mutate connection genes.
    for (final cg in connections.values) {
      cg.mutate(config.connection);
    }

    // Mutate node genes (bias, response, etc.).
    for (final ng in nodes.values) {
      ng.mutate(config.node);
    }
  }

  void mutateAddNode(GenomeConfig config, GenomeState state) {
    if (connections.isEmpty) {
      if (config.structuralMutationSurer) {
        mutateAddConnection(config);
      }
      return;
    }

    // Choose a random connection to split
    final connToSplit = RandomUtils.choice(connections.values);
    final newNodeId = getNewNodeKey(state);

    final ng = createNode(config.node, newNodeId);
    nodes[newNodeId] = ng;

    // Disable this connection and create two new connections joining its nodes via
    // the given node.  The new node+connections have roughly the same behavior as
    // the original connection (depending on the activation function of the new node).
    connToSplit.enabled = false;

    addConnection(config: config, inputKey: connToSplit.key.inputKey, outputKey: newNodeId, weight: 1.0, enabled: true);
    addConnection(config: config, inputKey: newNodeId, outputKey: connToSplit.key.outputKey, weight: connToSplit.weight!, enabled: true);
  }

  void addConnection({
    required GenomeConfig config,
    required int inputKey,
    required int outputKey,
    required double weight,
    required bool enabled,
  }) {
    final key = ConnectionGeneKey(inputKey, outputKey);
    final connection = ConnectionGene(key);
    connection.initAttributes(config.connection);
    connection.weight = weight;
    connection.enabled = enabled;
    connections[key] = connection;
  }

  /// Attempt to add a new connection, the only restriction being that the output
  /// node cannot be one of the network input pins.
  void mutateAddConnection(GenomeConfig config) {
    final possibleOutputs = Set<int>.from(nodes.keys);
    final outNode = RandomUtils.choice(possibleOutputs);

    final possibleInputs = possibleOutputs.union(Set<int>.from(config.inputKeys)).difference(Set<int>.from(config.outputKeys));
    final inNode = RandomUtils.choice(possibleInputs);

  // Don't duplicate connections.
    final key = ConnectionGeneKey(inNode, outNode);
    final cg = connections[key];
    if (cg != null) {
      // TODO: Should this be using mutation to/from rates? Hairy to configure...
      if (config.structuralMutationSurer) {
        cg.enabled = true;
      }
      return;
    }

    // Don't allow connections between two output nodes
    if (config.outputKeysIndex[inNode] != null && config.outputKeysIndex[outNode] != null) {
      return;
    }

    // No need to check for connections between input nodes:
    // they cannot be the output end of a connection (see above).

    // Avoid creating cycles.
    if (Graphs.createsCycle(List<ConnectionGeneKey>.from(connections.keys), key, config.recurrent)) {
      return;
    }

    final newCg = createConnectionWithNodeKeys(config.connection, inNode, outNode);
    connections[newCg.key] = newCg;
  }

  int mutateDeleteNode(GenomeConfig config) {
    // Do nothing if there are no non-output nodes.
    var availableNodes = <int>[];
    // input nodes have no genes, so just need to test for output nodes
    for (final key in nodes.keys) {
      if (config.outputKeysIndex[key] == null) {
        availableNodes.add(key);
      }
    }

    if (availableNodes.isEmpty) {
      return -1;
    }

    final delKey = RandomUtils.choice(availableNodes);

    final connectionsToDelete = <ConnectionGeneKey>[];
    for (final key in connections.keys) {
      if (delKey == key.inputKey || delKey == key.outputKey) {
        connectionsToDelete.add(key);
      }
    }

    for (final key in connectionsToDelete) {
      connections.remove(key);
    }

    nodes.remove(delKey);

    return delKey;
  }

  void mutateDeleteConnection() {
    if (connections.isNotEmpty) {
      final key = RandomUtils.choice(connections.keys);
      connections.remove(key);
    }
  }

  /// Returns the genetic distance between this genome and the other. This distance value
  /// is used to compute genome compatibility for speciation.
  double distance({
    required Genome other,
    required GenomeConfig config
  }) {
    // Compute node gene distance component.
    double nodeDistance = 0.0;
    if (nodes.isNotEmpty || other.nodes.isNotEmpty) {
      int disjointNodes = 0;
      for (final k2 in other.nodes.keys) {
        if (nodes[k2] == null) {
          disjointNodes += 1;
        }
      }

      for (final entry in nodes.entries) {
        final k1 = entry.key;
        final n1 = entry.value;
        final n2 = other.nodes[k1];
        if (n2 == null) {
          disjointNodes += 1;
        } else {
          // Homologous genes compute their own distance value.
          nodeDistance += n1.distance(n2, config.node);
        }
      }

      final maxNodes = max(nodes.length, other.nodes.length);
      nodeDistance = (nodeDistance + (config.compatibilityDisjointCoefficient * disjointNodes)) / maxNodes;
    }

    // Compute connection gene differences.
    double connectionDistance = 0.0;
    if (connections.isNotEmpty || other.connections.isNotEmpty) {
      int disjointConnections = 0;
      for (final k2 in other.connections.keys) {
        if (connections[k2] == null) {
          disjointConnections += 1;
        }
      }

      for (final entry in connections.entries) {
        final k1 = entry.key;
        final c1 = entry.value;
        final c2 = other.connections[k1];
        if (c2 == null) {
          disjointConnections += 1;
        } else {
          // Homologous genes compute their own distance value.
          connectionDistance += c1.distance(c2, config.connection);
        }
      }

      final maxConn = max(connections.length, other.connections.length);
      connectionDistance = (connectionDistance + (config.compatibilityDisjointCoefficient * disjointConnections)) / maxConn;
    }
    return nodeDistance + connectionDistance;
  }

  /// Returns genome 'complexity', taken to be (number of nodes, number of enabled connections)
  GenomeSize size() {
    int numEnabledConnections = 0;
    for (final cg in connections.values) {
      if (cg.enabled == true) {
        numEnabledConnections += 1;
      }
    }

    return GenomeSize(nodes.length, numEnabledConnections);
  }
}
