import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer_plugin/protocol/protocol_generated.dart';

import 'rule_base.dart';

mixin VisitorMixin on AstVisitor<void> {
  Rule get rule;
  ResolvedUnitResult get result;

  final errors = <AnalysisErrorFixes>[];
}
