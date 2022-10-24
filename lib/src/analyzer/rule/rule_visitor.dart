import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer_plugin/protocol/protocol_generated.dart';

import '../options/options.dart';
import 'rule.dart';

/// Interface for a rule visitor. Use an implementation of this interface as
/// the superclass for a custom rule visitor.
abstract class RuleVisitor implements AstVisitor<dynamic> {
  /// Rule definition which provides a visitor, id, help text, etc.
  Rule get rule;

  /// Rule configuration provided in the client project's
  /// `analysis_options.yaml`.
  ///
  /// Projects which use these custom lint rules can customize the behavior of
  /// this plugin by specifying supported options in their `pubspec.yaml`.
  RuleConfig get config;

  /// The result of building a resolved AST for a single file. The errors
  /// returned include both syntactic and semantic errors.
  ResolvedUnitResult get result;

  /// Analysis errors produced by the rule visitor.
  List<AnalysisErrorFixes> get errors;

  /// Path to the file being analyzed, as determined by the resolved AST
  /// [result]. Use this as the file path for automatic fixes.
  String get fileUrl;

  /// {@macro documentation_url}
  String? get documentationUrl;
}

/// {@template rule_visitor}
/// Default rule visitor superclass that inherits [SimpleAstVisitor].
/// Most rules (if not all) will extend this class to produce analysis warnings
/// and errors.
/// {@endtemplate}
class SimpleRuleVisitor extends SimpleAstVisitor<void> implements RuleVisitor {
  /// {@macro rule_visitor}
  SimpleRuleVisitor({
    required this.rule,
    required this.result,
    required this.config,
  });

  @override
  final Rule rule;

  @override
  final RuleConfig config;

  @override
  final ResolvedUnitResult result;

  @override
  final errors = <AnalysisErrorFixes>[];

  @override
  String get fileUrl => Uri.file(result.path).toFilePath();

  @override
  String? get documentationUrl => config.documentationUrl;
}
