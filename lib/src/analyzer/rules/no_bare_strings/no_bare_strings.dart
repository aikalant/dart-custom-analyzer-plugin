import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer_plugin/protocol/protocol_common.dart';

import '../../options/options.dart';
import '../rule_base.dart';
import '../visitor_mixin.dart';
import '_visitor.dart';

class NoBareStrings extends Rule {
  @override
  String get id => 'no_bare_strings';

  @override
  String get message => 'Avoid string literals.';

  @override
  String? get correction => 'Use internationalization: "S.of(context).XXX"';

  @override
  AnalysisErrorSeverity get severity => AnalysisErrorSeverity.WARNING;

  @override
  VisitorMixin getVisitor(
    ResolvedUnitResult result,
    RuleConfig options,
  ) =>
      Visitor(this, result, options);
}
