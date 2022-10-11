import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer_plugin/protocol/protocol_common.dart';

import '../../options/options.dart';
import '../../rule/rule.dart';
import 'no_material_cupertino_imports_visitor.dart';

class NoMaterialCupertinoImportsRule extends Rule {
  @override
  String get id => 'no_material_cupertino_imports';

  @override
  String get message => "Don't use material or cupertino libraries.";

  @override
  String? get correction => "Import 'package:flutter/widgets.dart' instead.";

  @override
  AnalysisErrorSeverity get severity => AnalysisErrorSeverity.ERROR;

  @override
  SimpleRuleVisitor getVisitor(
    ResolvedUnitResult result,
    RuleConfig config,
  ) =>
      NoMaterialCupertinoImportsVisitor(
        rule: this,
        result: result,
        config: config,
      );
}
