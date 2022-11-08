import 'package:analyzer/dart/analysis/analysis_context.dart';
import 'package:analyzer/dart/analysis/context_root.dart';
import 'package:analyzer/file_system/file_system.dart';
import 'package:analyzer/src/analysis_options/analysis_options_provider.dart';
import 'package:analyzer/src/dart/analysis/driver.dart';
import 'package:dart_custom_analyzer_plugin/src/analyzer/options/options.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';
import 'package:yaml/yaml.dart';

class MockAnalysisDriver extends Mock implements AnalysisDriver {}

class MockFolder extends Mock implements Folder {}

class MockAnalysisContext extends Mock implements AnalysisContext {}

class MockFile extends Mock implements File {}

class MockContextRoot extends Mock implements ContextRoot {}

class MockAnalysisOptionsProvider extends Mock
    implements AnalysisOptionsProvider {}

void main() {
  group('getOptionsFromDriver', () {
    test('returns empty map when optionsFile is null', () {
      final context = MockAnalysisContext();
      final contextRoot = MockContextRoot();
      final optionsProvider = MockAnalysisOptionsProvider();
      final root = MockFolder();
      when(() => context.contextRoot).thenReturn(contextRoot);
      when(() => contextRoot.optionsFile).thenReturn(null);
      expect(
        getOptionsFromDriver(
          context: context,
          optionsProvider: optionsProvider,
          root: root,
        ),
        isEmpty,
      );
    });

    test('returns empty map when optionsFile does not exist', () {
      final context = MockAnalysisContext();
      final contextRoot = MockContextRoot();
      final optionsProvider = MockAnalysisOptionsProvider();
      final root = MockFolder();
      final optionsFile = MockFile();
      when(() => context.contextRoot).thenReturn(contextRoot);
      when(() => contextRoot.optionsFile).thenReturn(null);
      when(() => optionsFile.exists).thenReturn(false);
      expect(
        getOptionsFromDriver(
          context: context,
          optionsProvider: optionsProvider,
          root: root,
        ),
        isEmpty,
      );
    });

    test('returns correct options map', () {
      const documentationUrl = 'https://example.com';
      final context = MockAnalysisContext();
      final contextRoot = MockContextRoot();
      final optionsProvider = MockAnalysisOptionsProvider();
      final root = MockFolder();
      final optionsFile = MockFile();
      when(() => root.path).thenReturn('/');
      when(() => context.contextRoot).thenReturn(contextRoot);
      when(() => contextRoot.optionsFile).thenReturn(optionsFile);
      when(() => optionsFile.exists).thenReturn(true);
      when(() => optionsProvider.getOptionsFromFile(optionsFile)).thenReturn(
        YamlMap.wrap(<dynamic, dynamic>{
          'custom_linter': <dynamic, dynamic>{
            'documentationUrl': documentationUrl,
            'rules': <dynamic>[
              'rule1',
              <dynamic, dynamic>{
                'rule2': <dynamic, dynamic>{
                  'enabled': true,
                },
              },
              <dynamic, dynamic>{
                'rule3': <dynamic, dynamic>{
                  'documentationUrl': documentationUrl,
                  'enabled': false,
                  'exclude': <dynamic>['/**/*.dart'],
                },
              },
            ],
          },
        }),
      );

      final options = getOptionsFromDriver(
        context: context,
        optionsProvider: optionsProvider,
        ruleWhiteList: ['rule1'],
        ruleBlackList: [],
        root: root,
      );

      expect(
        options,
        isA<Map<String, RuleConfig>>(),
      );

      expect(
        options['rule1'],
        isA<RuleConfig>().having((c) => c.enabled, 'enabled', true),
      );

      expect(options.containsKey('rule2'), isFalse);
    });
  });
}
