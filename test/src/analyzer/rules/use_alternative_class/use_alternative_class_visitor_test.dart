import 'dart:collection';

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer_plugin/protocol/protocol_common.dart';
import 'package:dart_custom_analyzer_plugin/src/analyzer/options/options.dart';
import 'package:dart_custom_analyzer_plugin/src/analyzer/rule/rule.dart';
import 'package:dart_custom_analyzer_plugin/src/analyzer/rules/use_alternative_class/use_alternative_class_visitor.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

import '../../../../test_utils.dart';

const mockNamedConstructor = 'create';

class _AllowedMockConstructorName extends Mock implements ConstructorName {}

class _DisallowedMockConstructorName extends Mock implements ConstructorName {
  _DisallowedMockConstructorName();
  _DisallowedMockConstructorName.create() : _constructor = mockNamedConstructor;

  String? _constructor;

  @override
  String toString() {
    if (_constructor == null) {
      return super.toString();
    }
    return '${super.toString()}.$_constructor';
  }
}

const allowedMockClassName = '_AllowedMockConstructorName';
const disallowedClassName = '_DisallowedMockConstructorName';

void main() {
  group('UseAlternativeClassVisitor', () {
    test(
      'instantiates with correct values when config is empty',
      () {
        final rule = MockRule();
        final result = MockResult();
        final config = RuleConfig();

        final visitor = UseAlternativeClassVisitor(
          rule: rule,
          result: result,
          config: config,
        );

        expect(visitor.rule, same(rule));
        expect(visitor.result, same(result));
        expect(visitor.config, same(config));
      },
    );

    group('visitConstructorName', () {
      final error = AnalysisError(
        AnalysisErrorSeverity.ERROR,
        AnalysisErrorType.HINT,
        Location('file.dart', 0, 0, 0, 0),
        'error message',
        'code',
      );

      tearDownAll(() => generateError = defaultGenerateError);

      test('does not add error for allowed class', () {
        final constructorName = _AllowedMockConstructorName();

        when(() => constructorName.name).thenReturn(null);
        generateError = testGenerateError(error);

        final visitor = createVisitor()..visitConstructorName(constructorName);

        expect(visitor.errors, isEmpty);
      });

      test('does not add error for class in allowed list ', () {
        final constructorName = _DisallowedMockConstructorName();
        final config = RuleConfig()
          ..options = <String, Object>{
            UseAlternativeClassVisitor.alternativeKey: 
              UnmodifiableMapView(<String, String>{disallowedClassName: 'AlternativeClass'}),
            UseAlternativeClassVisitor.allowedClassesKey: [disallowedClassName],
          };

        when(() => constructorName.name).thenReturn(null);
        generateError = testGenerateError(error);

        final visitor = createVisitor(config)..visitConstructorName(constructorName);

        expect(visitor.errors, isEmpty);
      });
      
      test('adds error for disallowed class', () {
        final constructorName = _DisallowedMockConstructorName();

        when(() => constructorName.name).thenReturn(null);
        generateError = testGenerateError(error);

        final visitor = createVisitor()..visitConstructorName(constructorName);

        expect(visitor.errors.single.error, same(error));
      });

      test('adds error for disallowed class with constructor', () {
        final constructorName = _DisallowedMockConstructorName.create();
        final simpleId = MockSimpleIdentifier();

        when(() => simpleId.name).thenReturn(mockNamedConstructor);
        when(() => simpleId.length).thenReturn(mockNamedConstructor.length);
        when(() => constructorName.name).thenReturn(simpleId);

        generateError = testGenerateError(error);

        final visitor = createVisitor()..visitConstructorName(constructorName);
        expect(visitor.errors.single.error, same(error));
      });
    });
  });
}

UseAlternativeClassVisitor createVisitor([RuleConfig? config]) {
  config ??= RuleConfig()..options[UseAlternativeClassVisitor.alternativeKey] =
    UnmodifiableMapView(<String, String>{disallowedClassName: 'AlternativeClass'});
  final rule = MockRule();
  final result = MockResult();

  return UseAlternativeClassVisitor(
    rule: rule,
    result: result,
    config: config,
  );
}
