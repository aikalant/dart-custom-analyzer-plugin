import 'package:dart_custom_analyzer_plugin/src/analyzer/options/yaml_utils.dart';
import 'package:test/test.dart';
import 'package:yaml/yaml.dart';

void main() {
  const key = 'key';
  const value = 10;

  group('YamlNodeToDartObject', () {
    test('converts yaml map to dart object', () {
      final node = YamlMap.wrap(<String, dynamic>{key: value});
      final object = node.toDartObject();
      expect(object, isA<Map<String, dynamic>>());
      final map = object as Map<String, dynamic>;
      expect(map[key], value);
    });

    test('converts yaml list to dart object', () {
      final node = YamlList.wrap(<dynamic>[value]);
      final object = node.toDartObject();
      expect(object, isA<List<dynamic>>());
      final list = object as List<dynamic>;
      expect(list[0], value);
    });

    test('converts yaml scalar to dart object', () {
      final node = YamlScalar.wrap(value);
      final object = node.toDartObject();
      expect(object, value);
    });
  });
}
