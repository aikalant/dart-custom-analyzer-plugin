import 'package:dart_custom_analyzer_plugin/src/analyzer/options/options.dart';
import 'package:dart_custom_analyzer_plugin/src/analyzer/rule/rule.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

import '../../../test_utils.dart';

void main() {
  group('SimpleRuleVisitor', () {
    test('initializes with correct values', () {
      const documentationUrl = 'documentationUrl';
      final rule = MockRule();
      final result = MockResult();
      final config = RuleConfig(documentationUrl: documentationUrl);
      final visitor =
          SimpleRuleVisitor(rule: rule, result: result, config: config);

      const path = 'filename.dart';
      when(() => result.path).thenReturn(path);

      expect(visitor.rule, same(rule));
      expect(visitor.config, same(config));
      expect(visitor.result, same(result));
      expect(visitor.errors, isEmpty);
      expect(visitor.fileUrl, path);
      expect(visitor.documentationUrl, documentationUrl);
    });
  });
}
