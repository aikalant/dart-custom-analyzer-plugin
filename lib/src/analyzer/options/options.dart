// ignore_for_file: implementation_imports
import 'package:analyzer/src/analysis_options/analysis_options_provider.dart';
import 'package:analyzer/src/dart/analysis/driver.dart';
import 'yaml_utils.dart';

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
