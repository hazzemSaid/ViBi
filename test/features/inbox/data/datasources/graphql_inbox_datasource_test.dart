import 'package:flutter_test/flutter_test.dart';
import 'package:ferry/ferry.dart' as ferry;
import 'package:mocktail/mocktail.dart';
import 'package:vibi/features/inbox/data/datasources/graphql_inbox_datasource.dart';

class _MockFerryClient extends Mock implements ferry.Client {}

class _FakeOperationRequest extends Fake
    implements
        ferry.OperationRequest<Map<String, dynamic>, Map<String, dynamic>> {}

void main() {
  setUpAll(() {
    registerFallbackValue(_FakeOperationRequest());
  });

  group('GraphQLInboxDataSource', () {
    test('getPendingQuestions uses archived statuses when requested', () async {
      final client = _MockFerryClient();
      final dataSource = GraphQLInboxDataSource(ferryClient: client);

      when(
        () => client.request<Map<String, dynamic>, Map<String, dynamic>>(any()),
      ).thenAnswer(
        (_) => Stream.value(_operationResponse(data: _questionsPayload)),
      );

      final result = await dataSource.getPendingQuestions(
        'recipient-1',
        status: 'archived',
        limit: 12,
        offset: 4,
      );

      expect(result.isRight(), isTrue);
      final captured =
          verify(
                () =>
                    client.request<Map<String, dynamic>, Map<String, dynamic>>(
                      captureAny(),
                    ),
              ).captured.single
              as ferry.JsonOperationRequest;
      expect(captured.vars['currentUserId'], 'recipient-1');
      expect(captured.vars['limit'], 12);
      expect(captured.vars['offset'], 4);
      expect(captured.vars['statuses'], ['archive', 'archived']);
    });

    test('getPendingQuestions maps unanswered status to pending', () async {
      final client = _MockFerryClient();
      final dataSource = GraphQLInboxDataSource(ferryClient: client);

      when(
        () => client.request<Map<String, dynamic>, Map<String, dynamic>>(any()),
      ).thenAnswer(
        (_) => Stream.value(_operationResponse(data: _questionsPayload)),
      );

      final result = await dataSource.getPendingQuestions(
        'recipient-1',
        status: 'unanswered',
      );

      expect(result.isRight(), isTrue);
      final captured =
          verify(
                () =>
                    client.request<Map<String, dynamic>, Map<String, dynamic>>(
                      captureAny(),
                    ),
              ).captured.single
              as ferry.JsonOperationRequest;
      expect(captured.vars['statuses'], ['pending']);
    });

    test(
      'getPendingQuestions maps valid edges and skips malformed ones',
      () async {
        final client = _MockFerryClient();
        final dataSource = GraphQLInboxDataSource(ferryClient: client);

        when(
          () =>
              client.request<Map<String, dynamic>, Map<String, dynamic>>(any()),
        ).thenAnswer(
          (_) => Stream.value(
            _operationResponse(data: _questionsPayloadWithMalformedEdge),
          ),
        );

        final result = await dataSource.getPendingQuestions('recipient-1');

        expect(result.isRight(), isTrue);
        final questions = result.getOrElse(() => []);
        expect(questions, hasLength(1));
        expect(questions.first.id, 'question-1');
        expect(questions.first.questionText, 'Question text');
        expect(questions.first.senderUsername, 'alice');
        expect(questions.first.senderAvatarUrl, 'https://cdn.test/alice.png');
      },
    );
  });
}

ferry.OperationResponse<Map<String, dynamic>, Map<String, dynamic>>
_operationResponse({Map<String, dynamic>? data}) {
  return ferry.OperationResponse<Map<String, dynamic>, Map<String, dynamic>>(
    operationRequest: _FakeOperationRequest(),
    dataSource: ferry.DataSource.Link,
    data: data,
  );
}

const _questionsPayload = {
  'questionsCollection': {
    'edges': [
      {
        'node': {
          'id': 'question-1',
          'recipient_id': 'recipient-1',
          'sender_id': 'sender-1',
          'question_text': 'Question text',
          'is_anonymous': false,
          'status': 'pending',
          'created_at': '2026-01-01T00:00:00.000Z',
          'profiles': {
            'username': 'alice',
            'avatar_urls': ['https://cdn.test/alice.png'],
          },
        },
      },
    ],
  },
};

const _questionsPayloadWithMalformedEdge = {
  'questionsCollection': {
    'edges': [
      {'node': null},
      {
        'node': {
          'id': 'question-1',
          'recipient_id': 'recipient-1',
          'sender_id': 'sender-1',
          'question_text': 'Question text',
          'is_anonymous': false,
          'status': 'pending',
          'created_at': '2026-01-01T00:00:00.000Z',
          'profiles': {
            'username': 'alice',
            'avatar_urls': ['https://cdn.test/alice.png'],
          },
        },
      },
    ],
  },
};
