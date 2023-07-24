import 'dart:collection';

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
    final allowedClasses = config.options[allowedClassesKey] as List<Object>?;

    _alternatives =
        (config.options[alternativeKey] as UnmodifiableMapView<String, Object?>?)
                ?.entries.where((e) => allowedClasses == null || !allowedClasses.contains(e.key))
                .map((e) => MapEntry(e.key, e.value! as String)).toList() ?? [];
  }

  static const alternativeKey = 'alternatives';
  static const allowedClassesKey = 'allowed_classes';


  late final List<MapEntry<String, String>> _alternatives;

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

    for (final entry in _alternatives) {
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
