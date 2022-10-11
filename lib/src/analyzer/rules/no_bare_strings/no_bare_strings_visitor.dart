import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer_plugin/protocol/protocol_generated.dart';

import '../../options/options.dart';
import '../../rule/rule_visitor.dart';
import '../../rule/utils.dart';

class NoBareStringsVisitor extends SimpleRuleVisitor {
  NoBareStringsVisitor({
    required super.rule,
    required super.result,
    required super.config,
  }) {
    _parseConfig(config);
  }

  static final alphabeticalRegex = RegExp(r'\p{L}+', unicode: true);

  late final Set<String> _allowedConstructorInvocations;
  late final Set<String> _allowedMethodInvocations;
  late final Set<String> _allowedClasses;
  late final Set<String> _allowedMethodBodies;
  late final Set<String> _allowedStrings;

  void _parseConfig(RuleConfig config) {
    final allowedConstructorsList =
        config.options['allowed_constructor_invocations'];
    _allowedConstructorInvocations = allowedConstructorsList is List<Object>
        ? allowedConstructorsList.whereType<String>().toSet()
        : const {};

    final allowedFunctionsList = config.options['allowed_method_invocations'];
    _allowedMethodInvocations = allowedFunctionsList is List<Object>
        ? allowedFunctionsList.whereType<String>().toSet()
        : const {};

    final allowedClassesList = config.options['allowed_classes'];
    _allowedClasses = allowedClassesList is List<Object>
        ? allowedClassesList.whereType<String>().toSet()
        : const {};

    final allowedMethodBodiesList = config.options['allowed_method_bodies'];
    _allowedMethodBodies = allowedMethodBodiesList is List<Object>
        ? allowedMethodBodiesList.whereType<String>().toSet()
        : const {};

    final allowedStringsList = config.options['allowed_strings'];
    _allowedStrings = allowedStringsList is List<Object>
        ? allowedStringsList.whereType<String>().toSet()
        : const {};
  }

  @override
  void visitStringInterpolation(StringInterpolation node) {
    super.visitStringInterpolation(node);
    _check(
      node,
      node.elements.whereType<InterpolationString>().map((e) => e.value).join(),
    );
  }

  @override
  void visitSimpleStringLiteral(SimpleStringLiteral node) {
    super.visitSimpleStringLiteral(node);
    _check(node, node.value);
  }

  void _check(AstNode node, String stringValue) {
    if (node.thisOrAncestorMatching(
              (ancestorNode) => _isAllowedAncestor(node, ancestorNode),
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
          //fixes: [],
        ),
      );
    }
  }

  bool _isAllowedAncestor(AstNode stringNode, AstNode node) {
    // cant use switch(node.runtimeType) because node is actually
    // "xxxImpl" types, which are internal to the analyzer package
    // so we have to use this if/else statement
    if (node is Directive || node is Assertion || node is ThrowExpression) {
      return true;
    } else if (node is InstanceCreationExpression) {
      //need to strip generic stuff
      final typeName = node.constructorName.type2.name.name;
      final constructor = node.constructorName.name?.name;
      final constructorName =
          constructor == null ? typeName : '$typeName.$constructor';
      return _allowedConstructorInvocations.any(constructorName.endsWith);
    } else if (node is MethodInvocation) {
      final methodName = node.methodName.name;
      return (_allowedMethodInvocations.contains(methodName)) &&
          //make sure the string is a child of the argument list,
          //not the object calling the method
          stringNode.thisOrAncestorMatching(
                (ancestorNode) => ancestorNode == node.argumentList,
              ) !=
              null;
    } else if (node is MethodDeclaration) {
      final methodName = node.name.name;
      return _allowedMethodBodies.contains(methodName);
    } else if (node is FunctionDeclaration) {
      final functionName = node.name.name;
      return _allowedMethodBodies.contains(functionName);
    } else if (node is ClassDeclaration) {
      final className = node.name.name;
      return _allowedClasses.contains(className);
    }
    return false;
  }

  bool _containsAlphabeticChars(String stringValue) {
    var str = stringValue;
    _allowedStrings
        .forEach((allowedString) => str = str.replaceAll(allowedString, ''));
    return str.contains(alphabeticalRegex);
  }
}
