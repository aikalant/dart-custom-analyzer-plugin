import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer_plugin/protocol/protocol_generated.dart';

import '../options/options.dart';
import 'rule.dart';

/// {@template rule_visitor}
/// Base class for a rule visitor. Extend one of the subclasses when
/// implementing a rule visitor.
/// {@endtemplate}
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

mixin RuleVisitorImplementation implements RuleVisitor {
  @override
  final errors = <AnalysisErrorFixes>[];

  @override
  String get fileUrl => Uri.file(result.path).toFilePath();

  @override
  String? get documentationUrl => config.documentationUrl;
}

/// {@template simple_rule_visitor}
/// A rule visitor that inherits [SimpleAstVisitor]. Note: this does not
/// recursively visit child nodes. Use this when you need to override all
/// nodes that will be visited, or only care about top level nodes (like
/// import statements).
/// {@endtemplate}
class SimpleRuleVisitor extends SimpleAstVisitor<void>
    with RuleVisitorImplementation {
  /// {@macro simple_rule_visitor}
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
}

/// {@template recursive_rule_visitor}
/// Rule visitor that recursively visits all children. Use this when you need
/// to visit the entire AST or a nested subtree.
/// {@endtemplate}
class RecursiveRuleVisitor extends RecursiveAstVisitor<void>
    with RuleVisitorImplementation {
  /// {@macro recursive_rule_visitor}
  RecursiveRuleVisitor({
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
}
