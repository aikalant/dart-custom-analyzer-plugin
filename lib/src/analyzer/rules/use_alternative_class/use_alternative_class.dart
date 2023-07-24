import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer_plugin/protocol/protocol_common.dart';

import '../../options/options.dart';
import '../../rule/rule.dart';
import 'use_alternative_class_visitor.dart';

class UseAlternativeClassRule extends Rule {
  UseAlternativeClassRule({
    required String this.targetClass,
    required String this.alternativeClass,
  });

  UseAlternativeClassRule.empty()
      : targetClass = null,
        alternativeClass = null;

  final String? targetClass;
  final String? alternativeClass;

  @override
  String get id => 'use_alternative_class';

  @override
  String get message {
    assert(targetClass != null);
    return 'Avoid using $targetClass.';
  }

  @override
  String? get correction {
    assert(targetClass != null);
    assert(alternativeClass != null);
    return 'Use $alternativeClass instead of $targetClass.';
  }

  @override
  AnalysisErrorSeverity get severity => AnalysisErrorSeverity.WARNING;

  @override
  RuleVisitor getVisitor(
    ResolvedUnitResult result,
    RuleConfig config,
  ) =>
      UseAlternativeClassVisitor(rule: this, result: result, config: config);
}
