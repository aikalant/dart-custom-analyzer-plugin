part of 'no_material_cupertino_import.dart';

class _Visitor extends RecursiveAstVisitor<void> with VisitorMixin {
  _Visitor(this.rule, this.result);

  @override
  final Rule rule;
  @override
  final ResolvedUnitResult result;

  @override
  void visitImportDirective(ImportDirective node) {
    super.visitImportDirective(node);
    if (node.toString().contains('flutter/material.dart') ||
        node.toString().contains('flutter/cupertino.dart')) {
      errors.add(
        AnalysisErrorFixes(
          generateError(
            rule: rule,
            result: result,
            node: node,
            hasFix: false,
          ),
          //fixes: [],
        ),
      );
    }
  }
}
