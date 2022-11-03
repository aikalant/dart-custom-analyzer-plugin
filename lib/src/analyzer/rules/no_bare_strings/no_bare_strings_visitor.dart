import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer_plugin/protocol/protocol_generated.dart';
import 'package:meta/meta.dart';

import '../../options/options.dart';
import '../../rule/rule_visitor.dart';
import '../../rule/utils.dart';

class NoBareStringsVisitor extends RecursiveRuleVisitor {
  NoBareStringsVisitor({
    required super.rule,
    required super.result,
    required super.config,
  }) {
    _parseConfig(config);
  }

  /// Unicode alphabetical regex (`\p{L}` matches a single code point in the
  /// category "letter").
  static final alphabeticalRegex = RegExp(r'\p{L}+', unicode: true);

  static const allowedConstructorInvocationsKey =
      'allowed_constructor_invocations';
  static const allowedMethodInvocationsKey = 'allowed_method_invocations';
  static const allowedClassesKey = 'allowed_classes';
  static const allowedMethodBodiesKey = 'allowed_method_bodies';
  static const allowedStringsKey = 'allowed_strings';

  late final Set<String> allowedConstructorInvocations;
  late final Set<String> allowedMethodInvocations;
  late final Set<String> allowedClasses;
  late final Set<String> allowedMethodBodies;
  late final Set<String> allowedStrings;

  void _parseConfig(RuleConfig config) {
    final allowedConstructorsList =
        config.options[allowedConstructorInvocationsKey];
    allowedConstructorInvocations = allowedConstructorsList is List<Object>
        ? allowedConstructorsList.whereType<String>().toSet()
        : const {};

    final allowedMethodsList = config.options[allowedMethodInvocationsKey];
    allowedMethodInvocations = allowedMethodsList is List<Object>
        ? allowedMethodsList.whereType<String>().toSet()
        : const {};

    final allowedClassesList = config.options[allowedClassesKey];
    allowedClasses = allowedClassesList is List<Object>
        ? allowedClassesList.whereType<String>().toSet()
        : const {};

    final allowedMethodBodiesList = config.options[allowedMethodBodiesKey];
    allowedMethodBodies = allowedMethodBodiesList is List<Object>
        ? allowedMethodBodiesList.whereType<String>().toSet()
        : const {};

    final allowedStringsList = config.options[allowedStringsKey];
    allowedStrings = allowedStringsList is List<Object>
        ? allowedStringsList.whereType<String>().toSet()
        : const {};
  }

  @override
  void visitStringInterpolation(StringInterpolation node) {
    check(
      node,
      node.elements.whereType<InterpolationString>().map((e) => e.value).join(),
    );
  }

  @override
  void visitSimpleStringLiteral(SimpleStringLiteral node) {
    check(node, node.value);
  }

  /// Logs an error if the given [SimpleStringLiteral] or [StringInterpolation]
  /// [node] with the given [stringValue] exists within a non-allowed AST node
  /// ancestor.
  ///
  /// i.e., a bare string was found in a location that it is not allowed, such
  /// as Text('bare string').
  @visibleForTesting
  void check(AstNode node, String stringValue) {
    if (node.thisOrAncestorMatching(
              (ancestorNode) => isAllowedAncestor(node, ancestorNode),
            ) ==
            null &&
        _containsAlphabeticChars(stringValue)) {
      errors.add(
        AnalysisErrorFixes(
          generateError(
            rule: rule,
            result: result,
            node: node,
            hasFix: false,
            documentationUrl: documentationUrl,
          ),
          // fixes: [],
        ),
      );
    }
  }

  /// Determines if the given [node] is an allowed ancestor. Allowed ancestors
  /// are ignored by the rule. When [node] is a method invocation, [stringNode]
  /// is checked to make sure that it is a child of the method invocation's
  /// arguments.
  @visibleForTesting
  bool isAllowedAncestor(AstNode stringNode, AstNode node) {
    // cant use switch(node.runtimeType) because node is actually
    // "xxxImpl" types, which are internal to the analyzer package
    // so we have to use this if/else statement
    if (node is Directive || node is Assertion || node is ThrowExpression) {
      return true;
    } else if (node is InstanceCreationExpression) {
      // need to strip generic stuff
      final typeName = node.constructorName.type2.name.name;
      final constructor = node.constructorName.name?.name;
      final constructorName =
          constructor == null ? typeName : '$typeName.$constructor';
      return allowedConstructorInvocations.any(constructorName.endsWith);
    } else if (node is MethodInvocation) {
      final methodName = node.methodName.name;
      return (allowedMethodInvocations.contains(methodName)) &&
          // make sure the string is a child of the argument list, not the
          // object calling the method
          stringNode.thisOrAncestorMatching(
                (ancestorNode) => identical(ancestorNode, node.argumentList),
              ) !=
              null;
    } else if (node is MethodDeclaration) {
      final methodName = node.name.name;
      return allowedMethodBodies.contains(methodName);
    } else if (node is FunctionDeclaration) {
      final functionName = node.name.name;
      return allowedMethodBodies.contains(functionName);
    } else if (node is ClassDeclaration) {
      final className = node.name.name;
      return allowedClasses.contains(className);
    }
    return false;
  }

  /// Remove all allowed strings within [stringValue] and determine if
  /// [stringValue] has any unicode letter characters left over. Used to ignore
  /// non-alphabetic strings like GUIDs, numeric identifier strings, currencies,
  /// etc.
  bool _containsAlphabeticChars(String stringValue) {
    var str = stringValue;
    allowedStrings
        .forEach((allowedString) => str = str.replaceAll(allowedString, ''));
    return str.contains(alphabeticalRegex);
  }
}
