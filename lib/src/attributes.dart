import "dart:math";
import "normal_distribution.dart";
import "random_utils.dart";

class BaseAttribute {
}

enum DistributionType {
  none, normal, uniform
}

class FloatAttributeConfig {
  final double stdev;
  final double mean;
  final DistributionType initType;
  final double maxValue;
  final double minValue;
  final double mutatePower;
  final double mutateRate;
  final double replaceRate;

  final NormalDistribution _initGaussianDistribution;
  final NormalDistribution _mutateDistribution;

  FloatAttributeConfig({
    required this.mean,
    required this.stdev,
    required this.initType,
    required this.maxValue,
    required this.minValue,
    required this.mutatePower,
    required this.mutateRate,
    required this.replaceRate
  }):
    _initGaussianDistribution = NormalDistribution(mean: mean, deviation: stdev),
    _mutateDistribution = NormalDistribution(mean: 0, deviation: mutatePower);

  double clamp(double value) {
    return max(min(value, maxValue), minValue);
  }

  double initValue() {
    switch (initType) {
      case DistributionType.normal:
        return clamp(_initGaussianDistribution.next());
      case DistributionType.uniform:
        final newMinValue = max(minValue, (mean - (2 * stdev)));
        final newMaxValue = min(maxValue, (mean + (2 * stdev)));
        return newMinValue + _mutateDistribution.next() * (newMaxValue - newMinValue);
      default:
        return mean;
    }
  }

  double mutateValue(double value) {
    final r = RandomUtils.nextDouble();
    if (r < mutateRate) {
      return clamp(value + _mutateDistribution.next());
    }

    // use the same random to get the same effect: random() < replace_rate
    if (r < mutateRate + replaceRate) {
      return initValue();
    }

    return value;
  }
}

class FloatAttribute extends BaseAttribute {

  double initValue(FloatAttributeConfig config) {
    return config.initValue();
  }

  double mutateValue(double value, FloatAttributeConfig config) {
    return config.mutateValue(value);
  }
}

class BoolAttributeConfig {
  bool? defaultValue;
  final double mutateRate;
  final double rateToTrueAdd;
  final double rateToFalseAdd;

  BoolAttributeConfig({
    this.defaultValue,
    required this.mutateRate,
    required this.rateToTrueAdd,
    required this.rateToFalseAdd
  });

  bool initValue() {
    return defaultValue ?? RandomUtils.nextDouble() < 0.5;
  }

  bool mutateValue(bool value) {
    var newMutateRate = mutateRate;
    if (value) {
      newMutateRate += rateToFalseAdd;
    } else {
      newMutateRate += rateToTrueAdd;
    }

    if (newMutateRate > 0) {
      final r = RandomUtils.nextDouble();
      if (r < newMutateRate) {
        // NOTE: we choose a random value here so that the mutation rate has the
        // same exact meaning as the rates given for the string and bool
        // attributes (the mutation operation *may* change the value but is not
        // guaranteed to do so).
        return RandomUtils.nextDouble() < 0.5;
      }
    }

    return value;
  }
}

class BoolAttribute extends BaseAttribute {
  bool initValue(BoolAttributeConfig config) {
    return config.initValue();
  }

  bool mutateValue(bool value, BoolAttributeConfig config) {
    return config.mutateValue(value);
  }
}

class StringAttributeConfig {
  final List<String> options;
  final String? defaultValue;
  final double mutateRate;
  StringAttributeConfig({
    required this.options,
    String? defaultValue,
    required this.mutateRate
  }): defaultValue = defaultValue != null && options.contains(defaultValue!) ? defaultValue : null;

  String initValue() {
    return defaultValue ?? RandomUtils.choice(options);
  }

  String mutateValue(String value) {
  if (mutateRate > 0) {
  final r = RandomUtils.nextDouble();
    if (r < mutateRate) {
      return RandomUtils.choice(options);
    }
  }
  return value;
  }
}


/// Class for string attributes such as the aggregation function of a node,
/// which are selected from a list of options.
class StringAttribute extends BaseAttribute {
  String initValue(StringAttributeConfig config) {
    return config.initValue();
  }

  String mutateValue(String value, StringAttributeConfig config) {
  return config.mutateValue(value);
  }
}

