import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/dart/ast/syntactic_entity.dart';
import 'package:analyzer_plugin/protocol/protocol_common.dart';
import 'package:meta/meta.dart';

import 'rule.dart';

typedef ErrorGenerator = AnalysisError Function({
  required Rule rule,
  required ResolvedUnitResult result,
  required SyntacticEntity node,
  required bool hasFix,
  String? documentationUrl,
});

// Create shims which allow the generateError method to be swapped out when
// testing, as mocking all the offsets would become too difficult and fragile.
//
// Dart and Flutter themselves often use this convention when testing
// dependencies that are difficult to mock.

const ErrorGenerator defaultGenerateError = _generateErrorMethod;
ErrorGenerator _generateError = defaultGenerateError;
ErrorGenerator get generateError => _generateError;
set generateError(ErrorGenerator value) => _generateError = value;

/// Constructs and returns an [AnalysisError] for the given AST [node], resolved
/// ast [result], and [rule], while also specifying whether or not the rule
/// has an automatic fix available via [hasFix].
///
/// Note: A [documentationUrl] to a markdown file containing rule descriptions
/// (with each heading being a rule id) can be provided so that errors can link
/// to documentation for their respective rules.
AnalysisError _generateErrorMethod({
  required Rule rule,
  required ResolvedUnitResult result,
  required SyntacticEntity node,
  required bool hasFix,
  String? documentationUrl,
}) =>
    AnalysisError(
      rule.severity,
      rule.type,
      _getLocation(result, node),
      rule.message,
      rule.id,
      correction: rule.correction,
      url: createDocumentationUrl(documentationUrl, rule.id),
      hasFix: hasFix,
    );

Location _getLocation(ResolvedUnitResult result, SyntacticEntity node) {
  final start = result.lineInfo.getLocation(node.offset);
  //final end = result.lineInfo.getLocation(node.end);

  return Location(
    result.path,
    node.offset,
    node.length,
    start.lineNumber,
    start.columnNumber,
    //endLine: end.lineNumber,
    //endColumn: end.columnNumber,
  );
}

@visibleForTesting
String? createDocumentationUrl(String? documentationUrl, String ruleId) {
  return documentationUrl == null ? null : '$documentationUrl#$ruleId';
}
