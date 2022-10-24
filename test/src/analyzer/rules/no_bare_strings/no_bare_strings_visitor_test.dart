import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer_plugin/protocol/protocol_common.dart';
import 'package:dart_custom_analyzer_plugin/src/analyzer/options/options.dart';
import 'package:dart_custom_analyzer_plugin/src/analyzer/rule/utils.dart';
import 'package:dart_custom_analyzer_plugin/src/analyzer/rules/no_bare_strings/no_bare_strings_visitor.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

import '../../../../test_utils.dart';

void main() {
  group('NoBareStringsVisitor', () {
    test(
      'instantiates with correct values when config is empty',
      () {
        final rule = MockRule();
        final result = MockResult();
        final config = RuleConfig();

        final visitor = NoBareStringsVisitor(
          rule: rule,
          result: result,
          config: config,
        );

        expect(visitor.rule, same(rule));
        expect(visitor.result, same(result));
        expect(visitor.config, same(config));
      },
    );

    test('instantiates with correct values when config has values', () {
      final config = RuleConfig()
        ..options = <String, Object>{
          NoBareStringsVisitor.allowedConstructorInvocationsKey: ['A'],
          NoBareStringsVisitor.allowedMethodInvocationsKey: ['B'],
          NoBareStringsVisitor.allowedClassesKey: ['C'],
          NoBareStringsVisitor.allowedMethodBodiesKey: ['D'],
          NoBareStringsVisitor.allowedStringsKey: ['E'],
        };

      final visitor = createVisitor(config);

      expect(visitor.allowedConstructorInvocations, contains('A'));
      expect(visitor.allowedMethodInvocations, contains('B'));
      expect(visitor.allowedClasses, contains('C'));
      expect(visitor.allowedMethodBodies, contains('D'));
      expect(visitor.allowedStrings, contains('E'));
    });

    group('visitor', () {
      group('isAllowedAncestor', () {
        test('ignores directive nodes', () {
          final node = MockDirective();
          final stringNode = MockNode();
          final visitor = createVisitor();
          expect(visitor.isAllowedAncestor(stringNode, node), isTrue);
        });

        test('ignores assertion nodes', () {
          final node = MockDirective();
          final stringNode = MockNode();
          final visitor = createVisitor();
          expect(visitor.isAllowedAncestor(stringNode, node), isTrue);
        });

        test('ignores throw expression nodes', () {
          final node = MockThrowExpression();
          final stringNode = MockNode();
          final visitor = createVisitor();
          expect(visitor.isAllowedAncestor(stringNode, node), isTrue);
        });

        test(
          'ignores instance creation expressions that match allowed '
          'constructors',
          () {
            final node = MockInstanceCreationExpression();
            final stringNode = MockNode();
            final constructorName = MockConstructorName();
            final simpleId = MockSimpleIdentifier();
            final namedType = MockNamedType();
            const typeName = 'type';

            when(() => node.constructorName).thenReturn(constructorName);
            when(() => constructorName.name).thenReturn(simpleId);
            when(() => constructorName.type2).thenReturn(namedType);
            when(() => namedType.name).thenReturn(simpleId);
            when(() => simpleId.name).thenReturn(typeName);

            final config = RuleConfig()
              ..options = <String, Object>{
                NoBareStringsVisitor.allowedConstructorInvocationsKey: [
                  typeName
                ],
              };

            expect(
              createVisitor(config).isAllowedAncestor(stringNode, node),
              isTrue,
            );
            expect(
              createVisitor().isAllowedAncestor(stringNode, node),
              isFalse,
            );
          },
        );

        test('ignores allowed method invocations', () {
          final node = MockMethodInvocation();
          final stringNode = MockNode();
          final simpleId = MockSimpleIdentifier();
          final argumentList = MockArgumentList();
          const methodName = 'method';

          when(() => node.methodName).thenReturn(simpleId);
          when(() => simpleId.name).thenReturn(methodName);
          when(() => node.argumentList).thenReturn(argumentList);
          whenThisOrAncestorMatching(stringNode, argumentList);

          final config = RuleConfig()
            ..options = <String, Object>{
              NoBareStringsVisitor.allowedMethodInvocationsKey: [methodName],
            };

          expect(
            createVisitor(config).isAllowedAncestor(stringNode, node),
            isTrue,
          );
          expect(createVisitor().isAllowedAncestor(stringNode, node), isFalse);
        });

        test('ignores allowed method declarations', () {
          final node = MockMethodDeclaration();
          final stringNode = MockNode();
          final simpleId = MockSimpleIdentifier();
          const methodName = 'method';

          when(() => node.name).thenReturn(simpleId);
          when(() => simpleId.name).thenReturn(methodName);

          final config = RuleConfig()
            ..options = <String, Object>{
              NoBareStringsVisitor.allowedMethodBodiesKey: [methodName],
            };

          expect(
            createVisitor(config).isAllowedAncestor(stringNode, node),
            isTrue,
          );
          expect(createVisitor().isAllowedAncestor(stringNode, node), isFalse);
        });

        test('ignores allowed function declaration', () {
          final node = MockFunctionDeclaration();
          final stringNode = MockNode();
          final simpleId = MockSimpleIdentifier();
          const methodName = 'method';

          when(() => node.name).thenReturn(simpleId);
          when(() => simpleId.name).thenReturn(methodName);

          final config = RuleConfig()
            ..options = <String, Object>{
              NoBareStringsVisitor.allowedMethodBodiesKey: [methodName],
            };

          expect(
            createVisitor(config).isAllowedAncestor(stringNode, node),
            isTrue,
          );
          expect(createVisitor().isAllowedAncestor(stringNode, node), isFalse);
        });

        test('ignores allowed class declarations', () {
          final node = MockClassDeclaration();
          final stringNode = MockNode();
          final simpleId = MockSimpleIdentifier();
          const className = 'class';

          when(() => node.name).thenReturn(simpleId);
          when(() => simpleId.name).thenReturn(className);

          final config = RuleConfig()
            ..options = <String, Object>{
              NoBareStringsVisitor.allowedClassesKey: [className],
            };

          expect(
            createVisitor(config).isAllowedAncestor(stringNode, node),
            isTrue,
          );
          expect(createVisitor().isAllowedAncestor(stringNode, node), isFalse);
        });
      });

      group('visit methods', () {
        const method = 'method';
        const string = 'value';
        final error = AnalysisError(
          AnalysisErrorSeverity.ERROR,
          AnalysisErrorType.HINT,
          Location('file.dart', 0, 0, 0, 0),
          'error message',
          'code',
        );

        tearDownAll(() => generateError = defaultGenerateError);

        MockMethodDeclaration mockMethodDeclaration(String methodName) {
          final node = MockMethodDeclaration();
          final simpleId = MockSimpleIdentifier();
          const methodName = 'method';

          when(() => node.name).thenReturn(simpleId);
          when(() => simpleId.name).thenReturn(methodName);

          return node;
        }

        group('visitSimpleStringLiteral', () {
          test('does not add error for allowed nodes', () {
            final node = MockSimpleStringLiteral();

            final ancestor = mockMethodDeclaration(method);
            when(() => node.value).thenReturn(string);
            whenThisOrAncestorMatching(node, ancestor);

            final config = RuleConfig()
              ..options = <String, Object>{
                NoBareStringsVisitor.allowedMethodBodiesKey: [method],
              };

            final visitor = createVisitor(config)
              ..visitSimpleStringLiteral(node);

            expect(visitor.errors, isEmpty);
          });

          test('adds error for disallowed nodes', () {
            final node = MockSimpleStringLiteral();

            final ancestor = mockMethodDeclaration(method);
            when(() => node.value).thenReturn(string);
            whenThisOrAncestorMatching(node, ancestor);

            generateError = testGenerateError(error);

            final visitor = createVisitor()..visitSimpleStringLiteral(node);

            expect(visitor.errors.single.error, same(error));
          });
        });

        group('visitStringInterpolation', () {
          MockStringInterpolation mockStringInterpolation(List<String> values) {
            final node = MockStringInterpolation();
            final elements = <InterpolationElement>[];
            for (final value in values) {
              final element = MockInterpolationString();
              when(() => element.value).thenReturn(value);
              elements.add(element);
            }
            final nodeList = MockNodeList<InterpolationElement>();
            when(() => nodeList.whereType<InterpolationString>())
                .thenReturn(elements.whereType<InterpolationString>());
            when(() => node.elements).thenReturn(nodeList);
            return node;
          }

          test('does not add error for allowed nodes', () {
            final node = mockStringInterpolation(['a', 'b']);

            final ancestor = mockMethodDeclaration(method);
            whenThisOrAncestorMatching(node, ancestor);

            final config = RuleConfig()
              ..options = <String, Object>{
                NoBareStringsVisitor.allowedMethodBodiesKey: [method],
              };

            final visitor = createVisitor(config)
              ..visitStringInterpolation(node);

            expect(visitor.errors, isEmpty);
          });

          test('adds error for disallowed nodes', () {
            final node = mockStringInterpolation(['a', 'b']);

            final ancestor = mockMethodDeclaration(method);
            whenThisOrAncestorMatching(node, ancestor);

            generateError = testGenerateError(error);

            final visitor = createVisitor()..visitStringInterpolation(node);

            expect(visitor.errors.single.error, same(error));
          });
        });
      });
    });
  });
}

NoBareStringsVisitor createVisitor([RuleConfig? config]) {
  config ??= RuleConfig();
  final rule = MockRule();
  final result = MockResult();

  return NoBareStringsVisitor(
    rule: rule,
    result: result,
    config: config,
  );
}
