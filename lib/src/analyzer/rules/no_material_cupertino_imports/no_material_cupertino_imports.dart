import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer_plugin/protocol/protocol_common.dart';

import '../../options/options.dart';
import '../rule_base.dart';
import '../visitor_mixin.dart';
import '_visitor.dart';

class NoMaterialCupertinoImportsRule extends Rule {
  @override
  String get id => 'no_material_cupertino_imports';

  @override
  String get message => 'Do not use material or cupertino libraries.';

  @override
  String? get correction => "Instead, use 'package:flutter/widgets.dart'";

  @override
  AnalysisErrorSeverity get severity => AnalysisErrorSeverity.ERROR;

  @override
  VisitorMixin getVisitor(
    ResolvedUnitResult result,
    RuleConfig options,
  ) =>
      Visitor(this, result, options);
}
