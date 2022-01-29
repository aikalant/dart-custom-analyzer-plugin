// ignore_for_file: implementation_imports
import 'package:analyzer/file_system/file_system.dart';
import 'package:analyzer/src/analysis_options/analysis_options_provider.dart';
import 'package:analyzer/src/dart/analysis/driver.dart';
import 'package:glob/glob.dart';
import 'package:path/path.dart' as p;
import 'yaml_utils.dart';

Map<String, RuleConfig> getOptionsFromDriver(
  AnalysisDriver driver,
  Folder root, [
  List<String>? ruleWhiteList,
  List<String>? ruleBlackList,
]) {
  final optionsFile = driver.analysisContext?.contextRoot.optionsFile;
  if (optionsFile != null && optionsFile.exists) {
    final optionsMap = yamlMapToDartMap(
      AnalysisOptionsProvider(driver.sourceFactory)
          .getOptionsFromFile(optionsFile),
    );

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
  return {};
}

Map<String, RuleConfig> _parseOptions(
  Map<String, Object> options,
  Folder root,
) {
  final ruleConfigs = <String, RuleConfig>{};
  final rootNode = options['custom_linter'];
  if (rootNode is Map<String, Object>) {
    final defaultUrl =
        rootNode['url'] is String ? rootNode['url'] as String? : null;
    final rulesNode = rootNode['rules'];
    if (rulesNode is List<Object>) {
      for (final ruleNode in rulesNode) {
        if (ruleNode is String) {
          ruleConfigs[ruleNode] = RuleConfig(defaultUrl);
        } else if (ruleNode is Map<String, Object>) {
          final entry = ruleNode.entries.first;
          final ruleID = entry.key;
          final ruleOptions = entry.value;
          if (ruleOptions is Map<String, Object>) {
            _applyOptionsToConfig(
              ruleOptions,
              ruleConfigs.putIfAbsent(ruleID, () => RuleConfig(defaultUrl)),
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

  final url = options['url'];
  if (url is String) {
    config.url = url;
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

class RuleConfig {
  RuleConfig(this.url);
  bool enabled = true;
  String? url;
  List<Glob> excludedGlobs = [];
  Map<String, Object> options = {};
}
