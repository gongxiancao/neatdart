import 'aggregations.dart';

typedef AggregationFunction = double Function(Iterable<double> x);

class AggregationFunctionSet {
  static Map<String, AggregationFunction> create() {
    var functions = <String, AggregationFunction>{};
    functions["product"] = productAggregation;
    functions["sum"] = sumAggregation;
    functions["max"] = maxAggregation;
    functions["min"] = minAggregation;
    functions["maxabs"] = maxabsAggregation;
    functions["median"] = medianAggregation;
    functions["mean"] = meanAggregation;
    return functions;
  }
}
