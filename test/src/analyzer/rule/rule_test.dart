import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer_plugin/protocol/protocol_common.dart';
import 'package:analyzer_plugin/protocol/protocol_generated.dart';
import 'package:dart_custom_analyzer_plugin/src/analyzer/options/options.dart';
import 'package:dart_custom_analyzer_plugin/src/analyzer/rule/rule.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

import '../../../test_utils.dart';

class TestRule extends Rule {
  TestRule({required this.id, required this.message, required this.visitor});

  @override
  RuleVisitor getVisitor(ResolvedUnitResult result, RuleConfig config) =>
      visitor;

  @override
  final String id;

  @override
  final String message;

  final RuleVisitor visitor;
}

void main() {
  group('Rule', () {
    test('initializes with correct values', () {
      final visitor = MockVisitor();
      final result = MockResult();
      final unit = MockCompilationUnit();
      final config = RuleConfig();

      final errors = <AnalysisErrorFixes>[];

      when(() => visitor.errors).thenReturn(errors);
      when(() => result.unit).thenReturn(unit);
      when(() => unit.visitChildren(visitor));

      final rule = TestRule(id: 'id', message: 'message', visitor: visitor);
      expect(rule.id, 'id');
      expect(rule.message, 'message');
      expect(rule.correction, null);
      expect(rule.severity, AnalysisErrorSeverity.WARNING);
      expect(rule.type, AnalysisErrorType.LINT);
      expect(rule.getVisitor(result, config), isA<RuleVisitor>());
      expect(rule.check(result, config), same(errors));
    });
  });
}
