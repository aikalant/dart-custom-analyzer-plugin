import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer_plugin/protocol/protocol_common.dart';
import 'package:dart_custom_analyzer_plugin/src/analyzer/options/options.dart';
import 'package:dart_custom_analyzer_plugin/src/analyzer/rule/rule_visitor.dart';
import 'package:dart_custom_analyzer_plugin/src/analyzer/rules/rules.dart';
import 'package:mocktail/mocktail.dart';
import 'package:recase/recase.dart';
import 'package:test/test.dart';

class MockResult extends Mock implements ResolvedUnitResult {}

void main() {
  group('NoBareStrings', () {
    test('instantiates with correct values', () {
      final rule = NoBareStrings();

      // Rule id should be snake_case version of the rule's class name,
      // without the `_rule` suffix.
      expect(
        rule.id,
        rule.runtimeType.toString().replaceAll('Rule', '').snakeCase,
      );

      expect(
        rule.message,
        isA<String>().having((s) => s.length, 'length', greaterThan(0)),
      );

      expect(
        rule.correction,
        isA<String?>(),
      );

      expect(
        rule.severity,
        isA<AnalysisErrorSeverity>(),
      );

      final result = MockResult();
      final config = RuleConfig();

      expect(
        rule.getVisitor(result, config),
        isA<RuleVisitor>()
            .having((visitor) => visitor.rule, 'rule', same(rule))
            .having((visitor) => visitor.result, 'result', same(result))
            .having((visitor) => visitor.config, 'config', same(config)),
      );
    });
  });
}
