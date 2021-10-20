import 'dart:io';
import 'dart:isolate';

import 'package:analyzer/dart/analysis/analysis_context.dart';
// ignore: implementation_imports
import 'package:analyzer/src/analysis_options/analysis_options_provider.dart';
// ignore: implementation_imports
import 'package:analyzer/src/dart/analysis/driver.dart';
// ignore: implementation_imports
import 'package:path/path.dart' as p;
import 'package:yaml/yaml.dart';

import 'map_utils.dart';
import 'yaml_utils.dart';

/// Perfer this one since it handles all the recursive include stuff
Set<String> getRulesFromDriver(AnalysisDriver driver) {
  final optionsFile = driver.analysisContext?.contextRoot.optionsFile;
  if (optionsFile != null && optionsFile.exists) {
    final optionsMap = yamlMapToDartMap(
      AnalysisOptionsProvider(driver.sourceFactory)
          .getOptionsFromFile(optionsFile),
    );
    return _parseOptions(optionsMap);
  }
  return {};
}

/// We have to manually parse the options file ourselves
Future<Set<String>> getRulesFromContext(AnalysisContext context) async {
  final optionsFile = context.contextRoot.optionsFile;
  if (optionsFile != null && optionsFile.exists) {
    return _parseOptions(
      await _loadConfigFromYamlFile(
        File.fromUri(optionsFile.toUri()), //Wrong "File"
      ),
    );
  }
  return {};
}

Set<String> _parseOptions(Map<String, Object> optionsMap) {
  final enabledRules = <String>{};
  final rootNode = optionsMap['custom_linter'];
  if (rootNode != null && rootNode is List<Object>) {
    for (final ruleNode in rootNode) {
      if (ruleNode is String) {
        enabledRules.add(ruleNode);
      } else if (ruleNode is Map<String, Object> && ruleNode.length == 1) {
        final entry = ruleNode.entries.first;
        final ruleID = entry.key;
        final ruleOptions = entry.value;
        if (ruleOptions is Map<String, Object>) {
          final enabled = ruleOptions['enabled'] ?? true;
          if (enabled == true) {
            enabledRules.add(ruleID);
          } else {
            enabledRules.remove(ruleID);
          }
        }
      }
    }
  }
  return enabledRules;
}

Future<Map<String, Object>> _loadConfigFromYamlFile(File optionsFile) async {
  try {
    final node = optionsFile.existsSync()
        ? loadYamlNode(optionsFile.readAsStringSync())
        : YamlMap();

    var optionsNode =
        node is YamlMap ? yamlMapToDartMap(node) : <String, Object>{};

    final includeNode = optionsNode['include'];
    if (includeNode is String) {
      final resolvedUri = includeNode.startsWith('package:')
          ? await Isolate.resolvePackageUri(Uri.parse(includeNode))
          : Uri.file(p.absolute(p.dirname(optionsFile.path), includeNode));
      if (resolvedUri != null) {
        final resolvedYamlMap =
            await _loadConfigFromYamlFile(File.fromUri(resolvedUri));
        optionsNode =
            mergeMaps(defaults: resolvedYamlMap, overrides: optionsNode);
      }
    }

    return optionsNode;
  } on YamlException catch (e) {
    throw FormatException(e.message, e.span);
  }
}
