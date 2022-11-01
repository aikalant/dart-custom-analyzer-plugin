import 'package:dart_custom_analyzer_plugin/src/analyzer/rule/rule.dart';
import 'package:dart_custom_analyzer_plugin/src/analyzer/rules/rules.dart';
import 'package:test/test.dart';

void main() {
  group('has a list of rules', () {
    test('rules are not empty', () {
      expect(rules, isA<List<Rule>>());
      expect(rules, isNotEmpty);
    });
  });
}
