// ignore_for_file: implementation_imports
import 'package:analyzer/dart/analysis/analysis_context.dart';
import 'package:analyzer/file_system/file_system.dart';
import 'package:analyzer/src/analysis_options/analysis_options_provider.dart';
import 'package:glob/glob.dart';
import 'package:path/path.dart' as p;

import 'yaml_utils.dart';

Map<String, RuleConfig> getOptionsFromDriver({
  required AnalysisContext? context,
  required AnalysisOptionsProvider optionsProvider,
  required Folder root,
  List<String>? ruleWhiteList,
  List<String>? ruleBlackList,
}) {
  final optionsFile = context?.contextRoot.optionsFile;

  if (optionsFile == null || !optionsFile.exists) {
    return {};
  }
  final optionsMap =
      optionsProvider.getOptionsFromFile(optionsFile).toDartMap();
  final options = _parseOptions(optionsMap, root)
    ..removeWhere((key, value) => !value.enabled);
  if (ruleBlackList != null) {
    options.removeWhere((key, value) => ruleBlackList.contains(key));
  }
  if (ruleWhiteList != null) {
    options.removeWhere((key, value) => !ruleWhiteList.contains(key));
  }
  return options;
}

Map<String, RuleConfig> _parseOptions(
  Map<String, Object> options,
  Folder root,
) {
  final ruleConfigs = <String, RuleConfig>{};
  final rootNode = options['custom_linter'];
  if (rootNode is Map<String, Object>) {
    final defaultUrl = rootNode['documentationUrl'] is String
        ? rootNode['documentationUrl'] as String?
        : null;
    final rulesNode = rootNode['rules'];
    if (rulesNode is List<Object>) {
      for (final ruleNode in rulesNode) {
        if (ruleNode is String) {
          ruleConfigs[ruleNode] = RuleConfig(documentationUrl: defaultUrl);
        } else if (ruleNode is Map<String, Object>) {
          final entry = ruleNode.entries.first;
          final ruleID = entry.key;
          final ruleOptions = entry.value;
          if (ruleOptions is Map<String, Object>) {
            _applyOptionsToConfig(
              ruleOptions,
              ruleConfigs.putIfAbsent(
                ruleID,
                () => RuleConfig(documentationUrl: defaultUrl),
              ),
              root,
            );
          }
        }
      }
    }
  }
  return ruleConfigs;
}

void _applyOptionsToConfig(
  Map<String, Object> options,
  RuleConfig config,
  Folder root,
) {
  final enabled = options['enabled'];
  if (enabled is bool) {
    config.enabled = enabled;
  }

  final url = options['documentationUrl'];
  if (url is String) {
    config.documentationUrl = url;
  }

  final excludedGlobs = options['exclude'];
  if (excludedGlobs is List<Object>) {
    config.excludedGlobs.addAll(
      excludedGlobs.whereType<String>().map(
            (pattern) => Glob(pattern, context: p.Context(current: root.path)),
          ),
    );
  }

  config.options.addEntries(
    options.entries
        .where((entry) => !['enabled', 'exclude'].contains(entry.key)),
  );
}

/// Configuration provided in a client project `analysis_options.yaml` under the
/// `custom_linter` key.
class RuleConfig {
  /// Creates a new rule configuration with the given properties.
  RuleConfig({this.documentationUrl});

  /// Whether or not the rules in this package are enabled.
  bool enabled = true;

  /// {@template documentation_url}
  /// Optional path to a markdown file describing the rule. The markdown file
  /// should contain a heading with the same name as the rule id.
  /// {@endtemplate}
  String? documentationUrl;

  /// Glob exclusion patterns which prevent analysis from occurring by the
  /// rules in this package.
  List<Glob> excludedGlobs = [];

  /// Individual rule options.
  Map<String, Object> options = {};
}
