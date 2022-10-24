import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer_plugin/protocol/protocol_common.dart';
import 'package:analyzer_plugin/protocol/protocol_generated.dart';
import 'package:meta/meta.dart';

import '../options/options.dart';
import 'rule_visitor.dart';

export 'rule_visitor.dart';
export 'utils.dart';

abstract class Rule {
  String get id;

  String get message;

  String? get correction => null;

  AnalysisErrorSeverity get severity => AnalysisErrorSeverity.WARNING;

  @nonVirtual
  AnalysisErrorType get type => AnalysisErrorType.LINT;

  RuleVisitor getVisitor(
    ResolvedUnitResult result,
    RuleConfig config,
  );

  @nonVirtual
  Iterable<AnalysisErrorFixes> check(
    ResolvedUnitResult result,
    RuleConfig options,
  ) {
    final visitor = getVisitor(result, options);
    result.unit.visitChildren(visitor);
    return visitor.errors;
  }
}
