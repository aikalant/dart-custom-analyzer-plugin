import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer_plugin/protocol/protocol_generated.dart';

import 'rules/rule_list.dart';
import 'suppression.dart';

Iterable<AnalysisErrorFixes> analyzeResult(
  ResolvedUnitResult result,
  Set<String> enabledRules,
) {
  final ignores = Suppression(result.content, result.lineInfo);
  return rules
      .where(
        (rule) =>
            enabledRules.contains(rule.id) && !ignores.isSuppressed(rule.id),
      )
      .expand(
        (rule) => rule.check(result).where(
              (errorFix) => !ignores.isSuppressedAt(
                rule.id,
                errorFix.error.location.startLine,
              ),
            ),
      );
}
