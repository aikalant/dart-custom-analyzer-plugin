import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/syntactic_entity.dart';
import 'package:analyzer_plugin/protocol/protocol_common.dart';
import 'package:dart_custom_analyzer_plugin/src/analyzer/rule/rule.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

/// A function which receives an [AstNode] and returns either true or false.
typedef Predicate = bool Function(AstNode);

ErrorGenerator testGenerateError(AnalysisError error) => ({
      required Rule rule,
      required ResolvedUnitResult result,
      required SyntacticEntity node,
      required bool hasFix,
      String? documentationUrl,
    }) =>
        error;

/// Setup a mock [node] to invoke the predicate callback with the given
/// [ancestor] when the system under test invokes
/// [AstNode.thisOrAncestorMatching] on the [node].
///
/// Provided for convenience to make setting up mock nodes easier.
void whenThisOrAncestorMatching(AstNode node, AstNode ancestor) {
  when(() => node.thisOrAncestorMatching(any(that: isA<Predicate>())))
      .thenAnswer((invocation) {
    final predicate = invocation.positionalArguments.first as Predicate;
    return predicate(ancestor) ? ancestor : null;
  });
}

// Normally wouldn't recommend sharing mocks because it can lead to unused mocks
// sticking around longer than needed as code is refactored, but with new rules
// being added which will need to mock various AST nodes alongside the fact that
// the analyzer AST api is not likely to change drastically, it makes more sense
// to reuse AST node mocks in this scenario.
//
// A further improvement might be to separate all AST node mocks into a separate
// AST test utility package.

class MockRule extends Mock implements Rule {}

class MockVisitor extends Mock implements RuleVisitor {}

class MockCompilationUnit extends Mock implements CompilationUnit {}

class MockResult extends Mock implements ResolvedUnitResult {}

class MockImportDirective extends Mock implements ImportDirective {}

class MockSimpleStringLiteral extends Mock implements SimpleStringLiteral {}

class MockStringLiteral extends Mock implements StringLiteral {}

class MockStringInterpolation extends Mock implements StringInterpolation {}

class MockInterpolationString extends Mock implements InterpolationString {}

class MockDirective extends Mock implements Directive {}

class MockAssertion extends Mock implements Assertion {}

class MockThrowExpression extends Mock implements ThrowExpression {}

class MockNode extends Mock implements AstNode {}

class MockNodeList<T extends AstNode> extends Mock implements NodeList<T> {}

class MockInstanceCreationExpression extends Mock
    implements InstanceCreationExpression {}

class MockClassDeclaration extends Mock implements ClassDeclaration {}

class MockConstructorName extends Mock implements ConstructorName {}

class MockSimpleIdentifier extends Mock implements SimpleIdentifier {}

class MockNamedType extends Mock implements NamedType {}

class MockMethodDeclaration extends Mock implements MethodDeclaration {}

class MockMethodInvocation extends Mock implements MethodInvocation {}

class MockFunctionDeclaration extends Mock implements FunctionDeclaration {}

class MockArgumentList extends Mock implements ArgumentList {}
