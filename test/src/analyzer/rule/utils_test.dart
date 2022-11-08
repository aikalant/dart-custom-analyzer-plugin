import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/dart/ast/syntactic_entity.dart';
import 'package:analyzer/source/line_info.dart';
import 'package:analyzer_plugin/protocol/protocol_common.dart';
import 'package:dart_custom_analyzer_plugin/src/analyzer/rule/rule.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class MockRule extends Mock implements Rule {}

class MockResult extends Mock implements ResolvedUnitResult {}

class MockNode extends Mock implements SyntacticEntity {}

class MockLineInfo extends Mock implements LineInfo {}

void main() {
  group('utils', () {
    group('generateError', () {
      test('produces analysis error', () {
        // Setup
        const severity = AnalysisErrorSeverity.INFO;
        const type = AnalysisErrorType.HINT;
        const message = 'message';
        const id = 'id';
        const correction = 'correction';

        final rule = MockRule();
        when(() => rule.severity).thenReturn(severity);
        when(() => rule.type).thenReturn(type);
        when(() => rule.message).thenReturn(message);
        when(() => rule.id).thenReturn(id);
        when(() => rule.correction).thenReturn(correction);

        const path = 'path';

        final result = MockResult();
        when(() => result.path).thenReturn(path);

        const offset = 10;
        const length = 20;
        const lineNumber = 1;
        const columnNumber = 2;

        final node = MockNode();
        when(() => node.offset).thenReturn(offset);
        when(() => node.length).thenReturn(length);

        final lineInfo = MockLineInfo();
        when(() => result.lineInfo).thenReturn(lineInfo);

        final characterLocation = CharacterLocation(lineNumber, columnNumber);
        when(() => lineInfo.getLocation(offset)).thenReturn(characterLocation);

        const documentationUrl = 'documentationUrl';
        const hasFix = true;

        // Expectation
        final error = generateError(
          rule: rule,
          result: result,
          node: node,
          hasFix: hasFix,
          documentationUrl: documentationUrl,
        );

        // Verification
        expect(error.severity, severity);
        expect(error.type, type);
        expect(error.location.file, path);
        expect(error.location.offset, offset);
        expect(error.location.length, length);
        expect(error.location.startColumn, columnNumber);
        expect(error.location.startLine, lineNumber);
        expect(error.message, message);
        expect(error.correction, correction);
        expect(error.url, 'documentationUrl#$id');
        expect(error.hasFix, hasFix);
      });
    });

    group('createDocumentationUrl', () {
      test('creates documentation url', () {
        const documentationUrl = 'documentationUrl';
        const id = 'id';
        final url = createDocumentationUrl(documentationUrl, id);
        expect(url, 'documentationUrl#$id');
      });

      test('returns null if given null', () {
        final url = createDocumentationUrl(null, 'id');
        expect(url, isNull);
      });
    });
  });
}
