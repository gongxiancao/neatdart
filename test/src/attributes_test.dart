import 'package:test/test.dart';
import 'package:neatdart/src/attributes.dart';

void main() {
  test('FloatAttributeConfig test', () {
    final config = FloatAttributeConfig(
      mean: 10,
      stdev: 5,
      initType: DistributionType.normal,
      minValue: 0,
      maxValue: 20,
      mutatePower: 2,
      mutateRate: 0.5,
      replaceRate: 0.6
    );
    double value = config.initValue();
    double newValue = config.mutateValue(value);
    expect(newValue, allOf(greaterThanOrEqualTo(config.minValue), lessThanOrEqualTo(config.maxValue)));
    newValue = config.mutateValue(newValue);
    newValue = config.mutateValue(newValue);
    expect(newValue, isNot(equals(value)));
  });

  test('BoolAttributeConfig test', () {
    final config = BoolAttributeConfig(
        defaultValue: false,
        mutateRate: 0.5,
        rateToTrueAdd: 0.3,
        rateToFalseAdd: 0.2,
    );
    bool value = config.initValue();
    int mutateTimes = 0;
    for (int i = 0; i < 100; ++i) {
      bool newValue = config.mutateValue(value);
      if (newValue != value) {
        mutateTimes ++;
      }
    }
    expect(mutateTimes, allOf(greaterThan(0), lessThan(100)));
  });

  test('StringAttributeConfig test', () {
    final config = StringAttributeConfig(
      options: ["a", "b", "c"],
      defaultValue: "d",
      mutateRate: 0.5,
    );
    String value = config.initValue();
    expect(value, isNot(equals("d")));
    int mutateTimes = 0;
    for (int i = 0; i < 100; ++i) {
      String newValue = config.mutateValue(value);
      if (newValue != value) {
        mutateTimes ++;
      }
    }
    expect(mutateTimes, allOf(greaterThan(0), lessThan(100)));
  });


}
