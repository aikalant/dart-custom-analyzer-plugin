import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer_plugin/protocol/protocol_generated.dart';

import '../../rule/rule_visitor.dart';
import '../../rule/utils.dart';
import 'use_alternative_class.dart';

class UseAlternativeClassVisitor extends RecursiveRuleVisitor {
  UseAlternativeClassVisitor({
    required super.rule,
    required super.result,
    required super.config,
  }) {
    _alternatives = {};
    final alternatives = config.options[alternativeKey];

    if (alternatives is Map<String, Object?>) {
      for (final alternative in alternatives.entries) {
        final replacement = alternative.value;
        if (replacement is String) {
          _alternatives[alternative.key] = replacement;
        }
      }
    }
  }

  static const alternativeKey = 'alternatives';

  late final Map<String, String> _alternatives;

  @override
  void visitConstructorName(ConstructorName node) {
    final constructorName = node.name;
    late final String className;

    if (constructorName == null) {
      className = node.toString();
    } else {
      final name = node.toString();
      className = name.substring(0, name.length - (constructorName.length + 1));
    }

    for (final entry in _alternatives.entries) {
      if (className == entry.key) {
        errors.add(
          AnalysisErrorFixes(
            generateError(
              rule: UseAlternativeClassRule(
                targetClass: entry.key,
                alternativeClass: entry.value,
              ),
              result: result,
              node: node,
              hasFix: false,
              documentationUrl: documentationUrl,
            ),
          ),
        );
      }
    }
  }
}
