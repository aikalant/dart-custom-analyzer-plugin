import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/dart/ast/syntactic_entity.dart';
import 'package:analyzer_plugin/protocol/protocol_common.dart';

import 'rule_base.dart';

AnalysisError generateError({
  required Rule rule,
  required ResolvedUnitResult result,
  required SyntacticEntity node,
  required bool hasFix,
}) =>
    AnalysisError(
      rule.severity,
      rule.type,
      _getLocation(result, node),
      rule.message,
      rule.id,
      correction: rule.correction,
      //url: 'www.google.com',
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
