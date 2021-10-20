part of 'no_material_cupertino_imports.dart';

class _Visitor extends SimpleAstVisitor<void> with VisitorMixin {
  _Visitor(this.rule, this.result);

  @override
  final Rule rule;
  @override
  final ResolvedUnitResult result;

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
          ),
          //fixes: [],
        ),
      );
    }
  }
}
