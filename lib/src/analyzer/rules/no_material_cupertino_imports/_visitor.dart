import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer_plugin/protocol/protocol_generated.dart';

import '../../options/options.dart';
import '../rule_base.dart';
import '../utils.dart';
import '../visitor_mixin.dart';

class Visitor extends SimpleAstVisitor<void> with VisitorMixin {
  Visitor(this.rule, this.result, RuleConfig options) {
    url = options.url;
  }

  @override
  final Rule rule;
  @override
  final ResolvedUnitResult result;
  late final String? url;

  @override
  void visitImportDirective(ImportDirective node) {
    super.visitImportDirective(node);

    final nodeStr = node.uri.toString();
    if (nodeStr.contains('flutter/material.dart') ||
        nodeStr.contains('flutter/cupertino.dart')) {
      errors.add(
        AnalysisErrorFixes(
          generateError(
            rule: rule,
            result: result,
            node: node.uri,
            hasFix: false,
            url: url,
          ),
          //fixes: [],
        ),
      );
    }
  }
}
