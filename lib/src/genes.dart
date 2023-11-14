import 'attributes.dart';
import 'random_utils.dart';
import 'math_utils.dart';

class BaseGene<T> {
  final T key;
  BaseGene(this.key);
}

class NodeGeneConfig {
  final FloatAttributeConfig bias;
  final FloatAttributeConfig response;
  final StringAttributeConfig activation;
  final StringAttributeConfig aggregation;
  final double compatibilityWeightCoefficient;
  NodeGeneConfig({
    required this.bias,
    required this.response,
    required this.activation,
    required this.aggregation,
    required this.compatibilityWeightCoefficient
  });
}

class NodeGene extends BaseGene<int> {
  double? bias;
  double? response;
  String? activation;
  String? aggregation;

  NodeGene(int key): super(key);

  void initAttributes(NodeGeneConfig config) {
    bias = config.bias.initValue();
    response = config.response.initValue();
    activation = config.activation.initValue();
    aggregation = config.aggregation.initValue();
  }

  void mutate(NodeGeneConfig config) {
    bias = config.bias.mutateValue(bias!);
    response = config.response.mutateValue(response!);
    activation = config.activation.mutateValue(activation!);
    aggregation = config.aggregation.mutateValue(aggregation!);
  }

  NodeGene copy() {
    final newGene = NodeGene(key);
    newGene.bias = bias;
    newGene.response = response;
    newGene.activation = activation;
    newGene.aggregation = aggregation;
    return newGene;
  }

  /// Creates a new gene randomly inheriting attributes from its parents.
  NodeGene crossover(NodeGene gene2) {
    final newGene = NodeGene(key);
    newGene.bias = RandomUtils.nextDouble() < 0.5 ? bias : gene2.bias;
    newGene.response = RandomUtils.nextDouble() < 0.5 ? response : gene2.response;
    newGene.activation = RandomUtils.nextDouble() < 0.5 ? activation : gene2.activation;
    newGene.aggregation = RandomUtils.nextDouble() < 0.5 ? aggregation : gene2.aggregation;
    return newGene;
  }

  double distance(NodeGene other, NodeGeneConfig config) {
    var d = abs(bias! - other.bias!) + abs(response! - other.response!);
    if (activation != other.activation) {
      d += 1.0;
    }
    if (aggregation != other.aggregation) {
      d += 1.0;
    }
    return d * config.compatibilityWeightCoefficient;
  }
}

class ConnectionGeneConfig {
  final FloatAttributeConfig weight;
  final BoolAttributeConfig enabled;
  final double compatibilityWeightCoefficient;
  ConnectionGeneConfig({
    required this.weight,
    required this.enabled,
    required this.compatibilityWeightCoefficient
  });
}

class ConnectionGeneKey {
  int inputKey;
  int outputKey;

  ConnectionGeneKey(this.inputKey, this.outputKey);

  static List<ConnectionGeneKey> fromTuples(List<(int, int)> tuples) {
    final result = <ConnectionGeneKey>[];
    for (final (input, output) in tuples) {
      result.add(ConnectionGeneKey(input, output));
    }
    return result;
  }
}

class ConnectionGene extends BaseGene<ConnectionGeneKey> {
  double? weight;
  bool? enabled;

  ConnectionGene(ConnectionGeneKey key): super(key);

  void initAttributes(ConnectionGeneConfig config) {
    weight = config.weight.initValue();
    enabled = config.enabled.initValue();
  }

  void mutate(ConnectionGeneConfig config) {
    weight = config.weight.mutateValue(weight!);
    enabled = config.enabled.mutateValue(enabled!);
  }

  ConnectionGene copy() {
    final newGene = ConnectionGene(key);
    newGene.weight = weight;
    newGene.enabled = enabled;
    return newGene;
  }

  /// Creates a new gene randomly inheriting attributes from its parents.
  ConnectionGene crossover(ConnectionGene gene2) {
    final newGene = ConnectionGene(key);
    newGene.weight = RandomUtils.nextDouble() < 0.5 ? weight : gene2.weight;
    newGene.enabled = RandomUtils.nextDouble() < 0.5 ? enabled : gene2.enabled;
    return newGene;
  }

  double distance(ConnectionGene other, ConnectionGeneConfig config) {
    var d = abs(weight! - other.weight!);
    if (enabled != other.enabled) {
      d += 1.0;
    }
    return d * config.compatibilityWeightCoefficient;
  }
}
