import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer_plugin/protocol/protocol_generated.dart';

import '../../options/options.dart';
import '../rule_base.dart';
import '../utils.dart';
import '../visitor_mixin.dart';

class Visitor extends RecursiveAstVisitor<void> with VisitorMixin {
  Visitor(
    this.rule,
    this.result,
    RuleConfig options,
  ) {
    _parseConfig(options);
  }

  @override
  final Rule rule;
  @override
  final ResolvedUnitResult result;
  late final String? url;
  late final Set<String>? _allowedConstructorInvocations;
  late final Set<String>? _allowedMethodInvocations;
  late final Set<String>? _allowedClasses;
  late final Set<String>? _allowedMethodBodies;
  late final Set<String>? _allowedStrings;

  void _parseConfig(RuleConfig config) {
    url = config.url;
    final allowedConstructorsList =
        config.options['allowed_constructor_invocations'];
    _allowedConstructorInvocations = allowedConstructorsList is List<Object>
        ? allowedConstructorsList.whereType<String>().toSet()
        : null;

    final allowedFunctionsList = config.options['allowed_method_invocations'];
    _allowedMethodInvocations = allowedFunctionsList is List<Object>
        ? allowedFunctionsList.whereType<String>().toSet()
        : null;

    final allowedClassesList = config.options['allowed_classes'];
    _allowedClasses = allowedClassesList is List<Object>
        ? allowedClassesList.whereType<String>().toSet()
        : null;

    final allowedMethodBodiesList = config.options['allowed_method_bodies'];
    _allowedMethodBodies = allowedMethodBodiesList is List<Object>
        ? allowedMethodBodiesList.whereType<String>().toSet()
        : null;

    final allowedStringsList = config.options['allowed_strings'];
    _allowedStrings = allowedStringsList is List<Object>
        ? allowedStringsList.whereType<String>().toSet()
        : null;
  }

  @override
  void visitStringInterpolation(StringInterpolation node) {
    super.visitStringInterpolation(node);
    _check(node);
  }

  @override
  void visitSimpleStringLiteral(SimpleStringLiteral node) {
    super.visitSimpleStringLiteral(node);
    _check(node);
  }

  void _check(AstNode node) {
    if (node.thisOrAncestorMatching(_isAllowedAncestor) == null &&
        _containsAlphabeticChars(
          node.toString(),
          stripInterpolation: node is StringInterpolation,
        )) {
      errors.add(
        AnalysisErrorFixes(
          generateError(
            rule: rule,
            result: result,
            node: node,
            hasFix: false,
            url: url,
          ),
          //fixes: [],
        ),
      );
    }
  }

  bool _isAllowedAncestor(AstNode node) {
    // cant use switch(node.runtimeType) because node is actually
    // "xxxImpl" types, which are internal to the analyzer package
    // so we have to use this if/else statement
    if (node is Directive ||
        node is AssertStatement ||
        node is ThrowExpression) {
      return true;
    } else if (node is InstanceCreationExpression) {
      //need to strip generic stuff
      final typeName = node.constructorName.type2.name.name;
      final constructor = node.constructorName.name?.name;
      final constructorName =
          constructor == null ? typeName : '$typeName.$constructor';
      return _allowedConstructorInvocations?.any(constructorName.endsWith) ??
          false;
    } else if (node is MethodInvocation) {
      final functionName = node.methodName.name;
      return _allowedMethodInvocations?.any(functionName.equals) ?? false;
    } else if (node is MethodDeclaration) {
      final methodName = node.name.name;
      return _allowedMethodBodies?.any(methodName.equals) ?? false;
    } else if (node is FunctionDeclaration) {
      final functionName = node.name.name;
      return _allowedMethodBodies?.any(functionName.equals) ?? false;
    } else if (node is ClassDeclaration) {
      final className = node.name.name;
      return _allowedClasses?.any(className.equals) ?? false;
    }
    return false;
  }

  static final _interpolationRegex = RegExp(r'(\$\S+)|(\$\{.+?\})');
  static final _alphabeticalRegex = RegExp(r'\p{L}+', unicode: true);

  bool _containsAlphabeticChars(
    String s, {
    bool stripInterpolation = false,
  }) {
    var str = stripInterpolation ? s.replaceAll(_interpolationRegex, '') : s;
    _allowedStrings
        ?.forEach((allowedString) => str = str.replaceAll(allowedString, ''));
    return str.contains(_alphabeticalRegex);
  }
}

extension _StringExt on String {
  bool equals(String other) => this == other;
}
