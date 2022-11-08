import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer_plugin/protocol/protocol_common.dart';
import 'package:analyzer_plugin/protocol/protocol_generated.dart';

import '../../rule/rule_visitor.dart';
import '../../rule/utils.dart';

class NoMaterialCupertinoImportsVisitor extends SimpleRuleVisitor {
  NoMaterialCupertinoImportsVisitor({
    required super.rule,
    required super.result,
    required super.config,
  });

  static const String material = 'package:flutter/material.dart';
  static const String cupertino = 'package:flutter/cupertino.dart';
  static const String widgets = 'package:flutter/widgets.dart';

  @override
  void visitImportDirective(ImportDirective node) {
    final literal = node.uri;
    final uri = literal.toSource();
    final importsMaterial = uri.contains(material);
    final importsCupertino = uri.contains(cupertino);
    var fix = uri.replaceAll(material, widgets);
    fix = fix.replaceAll(cupertino, widgets);

    if (importsMaterial || importsCupertino) {
      errors.add(
        AnalysisErrorFixes(
          generateError(
            rule: rule,
            result: result,
            node: literal,
            hasFix: true,
            documentationUrl: documentationUrl,
          ),
          fixes: [
            PrioritizedSourceChange(
              0,
              SourceChange(
                'Replace with "$widgets" instead',
                edits: [
                  SourceFileEdit(
                    fileUrl,
                    // timestamp
                    0,
                    edits: [
                      SourceEdit(
                        literal.offset,
                        literal.length,
                        fix,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }
  }
}
