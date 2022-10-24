import 'package:yaml/yaml.dart';

extension YamlListToDartList on YamlList {
  /// Convert the yaml list to a Dart [List].
  List<Object> toDartList() =>
      List.unmodifiable(nodes.map<Object>((obj) => obj.toDartObject()));
}

extension YamlMapToDartMap on YamlMap {
  /// Convert the yaml map to a Dart [Map].
  Map<String, Object> toDartMap() => Map.unmodifiable(
        Map<String, Object>.fromEntries(
          nodes.keys
              .whereType<YamlScalar>()
              .where(
                (key) => key.value is String && nodes[key]?.value != null,
              )
              .map(
                (key) => MapEntry<String, Object>(
                  key.value as String,
                  nodes[key]?.toDartObject() ?? Object(),
                ),
              ),
        ),
      );
}

extension YamlNodeToDartObject on YamlNode {
  /// Convert the yaml node to a Dart [Object].
  Object toDartObject() {
    var object = Object();

    if (this is YamlMap) {
      object = (this as YamlMap).toDartMap();
    } else if (this is YamlList) {
      object = (this as YamlList).toDartList();
    } else if (this is YamlScalar) {
      object = (this as YamlScalar).toDartObject();
    }

    return object;
  }
}

extension YamlScalarToDartObject on YamlScalar {
  /// Convert the yaml scalar to a Dart [Object].
  Object toDartObject() => value as Object;
}
