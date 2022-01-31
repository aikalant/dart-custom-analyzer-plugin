# Dart Custom Analyzer Plugin
A simple rules analysis logic library for a dart analyzer plugin to remotely reference.
Heavily inspired by (and often borrowed from) dart code metrics https://github.com/dart-code-checker/dart-code-metrics.

## Usage (plugin or library)

Whether this repo is used as a plugin or a library, files that it analyzes must be `.dart` files within a dart package containing an `analysis_options.yaml` file.

Include the following entry in the `analysis_options.yaml` file(s) with your specified set of rules. 
Rules may be simple strings, or maps with rule options.

###### target packages' `analysis_options.yaml`
```
custom_linter:
  rules:
    - <rule id>
    - <rule id>:
        enabled: false
        exclude:
         - /test/**
         - /lib/generated**
        <rule specific option>: <val>
    - <rule id>
    - ...
```

Each rule may have its own options, but all rules may include the following optional keys:
- `enabled` - controls whether the rule is run or not.
- `exclude` - list if file paths to exclude from analysis.
   - ex: `/test/**`

### Library

Simply call the analyze function. Returned will be a list of [AnalyzerErrorFixes](https://pub.dev/documentation/analysis_server_lib/latest/analysis_server_lib/AnalysisErrorFixes-class.html) identical to those provided to the analyzer server when used as a plugin.

```
import 'package:dart_custom_analyzer_plugin/analyzer.dart';

void main(List<String> arguments) async {
  final errors = await analyze(<List of directory and/or file paths>);
  return;
}
```

### VS Code Plugin

Create a dart analyzer `plugin loader` package, and a `plugin` package. The `plugin` package itself will be subpackage of the loader package located in `/tools/analyzer_plugin/`
Note: match the exact names of the directories and plugin.dart file.

###### The `plugin loader` package's directory structure:
```
<Plugin Loader Package Directory>
    tools/
        analyzer_plugin/
            bin/
                plugin.dart
            pubspec.yaml
    pubspec.yaml
```
Reference this project in the `plugin` subpackage's `pubspec.yaml`
Note: the dependency path must either be remote or an absolute (not relative) path.

###### `/tools/analyzer_plugin/pubspec.yaml`
```
...
dependencies:
  dart_custom_analyzer_plugin:
    git: https://github.com/aikalant/dart-custom-analyzer-plugin
    #path: <Absolute path to cloned directory>
```

Inside of `plugin.dart`, call the start function.

###### `/tools/analyzer_plugin/bin/plugin.dart`
```
import 'dart:isolate';

import 'package:dart_custom_analyzer_plugin/analyzer_plugin.dart';

void main(List<String> args, SendPort sendPort) {
  start(args, sendPort);
}
```

Ensure that the plugin loader is a dev dependency for any of the target packages it will be analyzing
###### Target packages' `/pubspec.yaml`
```
dev_dependencies:
  <Plugin Loader package name (parent package, not subpackage)>:
    path: <path>
```

Finally, add the plugin loader to the analysis_options.yaml of the target packages

###### Target packages' `/analysis_options.yaml`
```
analyzer:
  plugins:
    - <Plugin Loader package name (parent package, not subpackage)>
```

Don't forget to restart the analyzer server (ctrl + shift + p)

If you have trouble, try clearing the analysis server plugin cache and then restarting the server:
- `~/.dartServer/.plugin_manager/` for linux/mac
- `%LOCALAPPDATA%/.dartServer/.plugin_manager/` for windows

## Sources
https://github.com/dart-code-checker/dart-code-metrics