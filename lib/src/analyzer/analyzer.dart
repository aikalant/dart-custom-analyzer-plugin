import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer_plugin/protocol/protocol_generated.dart';

import 'options/options.dart';
import 'rules/rules.dart';
import 'suppression.dart';

Iterable<AnalysisErrorFixes> analyzeResult(
  ResolvedUnitResult result,
  Map<String, RuleConfig> configs,
) {
  final ignores = Suppression(result.content, result.lineInfo);
  return rules
      .where(
        (rule) =>
            (configs[rule.id]?.enabled ?? false) &&
            !configs[rule.id]!
                .excludedGlobs
                .any((excludeGlob) => excludeGlob.matches(result.path)) &&
            !ignores.isSuppressed(rule.id),
      )
      .expand(
        (rule) => rule.check(result, configs[rule.id]!).where(
              (errorFix) => !ignores.isSuppressedAt(
                rule.id,
                errorFix.error.location.startLine,
              ),
            ),
      );
}
