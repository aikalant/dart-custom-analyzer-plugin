import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer_plugin/protocol/protocol_common.dart';
import 'package:analyzer_plugin/protocol/protocol_generated.dart';

import '../rule_base.dart';
import '../utils.dart';
import '../visitor_mixin.dart';

part 'visitor.dart';

class NoMaterialCupertinoImportRule extends Rule {
  @override
  String get id => 'no_material_cupertino_import';

  @override
  String get message => 'Do not use material or cupertino libraries.';

  @override
  String? get correction =>
      'Use "package:flutter_widgets/flutter_widgets.dart" instead.';

  @override
  AnalysisErrorSeverity get severity => AnalysisErrorSeverity.ERROR;

  @override
  VisitorMixin getVisitor(ResolvedUnitResult result) => _Visitor(this, result);
}
