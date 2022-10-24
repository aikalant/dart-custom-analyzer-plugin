import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer_plugin/protocol/protocol_common.dart';
import 'package:dart_custom_analyzer_plugin/src/analyzer/options/options.dart';
import 'package:dart_custom_analyzer_plugin/src/analyzer/rule/rule.dart';
import 'package:dart_custom_analyzer_plugin/src/analyzer/rules/no_material_cupertino_imports/no_material_cupertino_imports_visitor.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

import '../../../../test_utils.dart';

void main() {
  group('NoMaterialCupertinoImportsVisitor', () {
    test(
      'instantiates with correct values',
      () {
        final rule = MockRule();
        final result = MockResult();
        final config = RuleConfig();

        final visitor = NoMaterialCupertinoImportsVisitor(
          rule: rule,
          result: result,
          config: config,
        );

        expect(visitor.rule, same(rule));
        expect(visitor.result, same(result));
        expect(visitor.config, same(config));
      },
    );

    group('visitImportDirective', () {
      const goodImportUri = "'package:some_package/some_package.dart'";

      final error = AnalysisError(
        AnalysisErrorSeverity.ERROR,
        AnalysisErrorType.HINT,
        Location('file.dart', 0, 0, 0, 0),
        'error message',
        'code',
      );

      late Rule rule;
      late ResolvedUnitResult result;
      late RuleConfig config;
      late ImportDirective node;
      late StringLiteral importUri;

      setUp(() {
        rule = MockRule();
        result = MockResult();
        config = RuleConfig();
        node = MockImportDirective();
        importUri = MockStringLiteral();
      });

      test('does nothing if no import uri', () {
        when(() => importUri.toSource()).thenReturn('');
        when(() => node.uri).thenReturn(importUri);

        final visitor = NoMaterialCupertinoImportsVisitor(
          rule: rule,
          result: result,
          config: config,
        )..visitImportDirective(node);

        expect(visitor.errors, isEmpty);
      });

      test('does nothing if import uri is not material or cupertino', () {
        when(() => importUri.toSource()).thenReturn(goodImportUri);
        when(() => node.uri).thenReturn(importUri);

        final visitor = NoMaterialCupertinoImportsVisitor(
          rule: rule,
          result: result,
          config: config,
        )..visitImportDirective(node);

        expect(visitor.errors, isEmpty);
      });

      tearDownAll(() => generateError = defaultGenerateError);

      test('triggers warning for material imports', () {
        when(() => importUri.toSource())
            .thenReturn(NoMaterialCupertinoImportsVisitor.material);
        when(() => importUri.offset).thenReturn(0);
        when(() => importUri.length).thenReturn(0);
        when(() => node.uri).thenReturn(importUri);
        when(() => result.path).thenReturn('file.dart');

        generateError = testGenerateError(error);

        final visitor = NoMaterialCupertinoImportsVisitor(
          rule: rule,
          result: result,
          config: config,
        )..visitImportDirective(node);

        expect(visitor.errors, isNotEmpty);
        expect(visitor.errors.first.error, same(error));
        expect(visitor.errors.first.fixes.first.change.edits, isNotEmpty);
      });

      test('triggers warning for cupertino imports', () {
        when(() => importUri.toSource())
            .thenReturn(NoMaterialCupertinoImportsVisitor.cupertino);
        when(() => importUri.offset).thenReturn(0);
        when(() => importUri.length).thenReturn(0);
        when(() => node.uri).thenReturn(importUri);
        when(() => result.path).thenReturn('file.dart');

        generateError = testGenerateError(error);

        final visitor = NoMaterialCupertinoImportsVisitor(
          rule: rule,
          result: result,
          config: config,
        )..visitImportDirective(node);

        expect(visitor.errors, isNotEmpty);
        expect(visitor.errors.first.error, same(error));
        expect(visitor.errors.first.fixes.first.change.edits, isNotEmpty);
      });
    });
  });
}
