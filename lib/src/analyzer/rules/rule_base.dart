import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer_plugin/protocol/protocol_common.dart';
import 'package:analyzer_plugin/protocol/protocol_generated.dart';
import 'package:meta/meta.dart';

import 'visitor_mixin.dart';

abstract class Rule {
  String get id;

  String get message;

  String? get correction => null;

  AnalysisErrorSeverity get severity => AnalysisErrorSeverity.WARNING;

  @nonVirtual
  AnalysisErrorType get type => AnalysisErrorType.LINT;

  VisitorMixin getVisitor(ResolvedUnitResult result);

  Iterable<AnalysisErrorFixes> check(ResolvedUnitResult result) {
    final visitor = getVisitor(result);
    result.unit.visitChildren(visitor);
    return visitor.errors;
  }
}
