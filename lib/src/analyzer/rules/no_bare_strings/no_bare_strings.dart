import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer_plugin/protocol/protocol_common.dart';

import '../../options/options.dart';
import '../../rule/rule.dart';
import 'no_bare_strings_visitor.dart';

class NoBareStrings extends Rule {
  @override
  String get id => 'no_bare_strings';

  @override
  String get message => 'Avoid string literals.';

  @override
  String? get correction => 'Use internationalization if possible.';

  @override
  AnalysisErrorSeverity get severity => AnalysisErrorSeverity.WARNING;

  @override
  RuleVisitor getVisitor(
    ResolvedUnitResult result,
    RuleConfig config,
  ) =>
      NoBareStringsVisitor(rule: this, result: result, config: config);
}
