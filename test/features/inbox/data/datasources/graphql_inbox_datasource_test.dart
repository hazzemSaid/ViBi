import 'package:flutter_test/flutter_test.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vibi/features/inbox/data/datasources/graphql_inbox_datasource.dart';

class _MockGraphQLClient extends Mock implements GraphQLClient {}

class _FakeQueryOptions extends Fake implements QueryOptions<Object?> {}

void main() {
  setUpAll(() {
    registerFallbackValue(_FakeQueryOptions());
  });

  group('GraphQLInboxDataSource', () {
    test('getPendingQuestions uses archived statuses when requested', () async {
      final client = _MockGraphQLClient();
      final dataSource = GraphQLInboxDataSource(graphQLClient: client);

      when(() => client.query(any())).thenAnswer(
        (_) async => _queryResult(data: _questionsPayload),
      );

      final result = await dataSource.getPendingQuestions(
        'recipient-1',
        status: 'archived',
        limit: 12,
        offset: 4,
      );

      expect(result.isRight(), isTrue);
      final captured =
          verify(() => client.query(captureAny())).captured.single as QueryOptions;
      expect(captured.variables['currentUserId'], 'recipient-1');
      expect(captured.variables['limit'], 12);
      expect(captured.variables['offset'], 4);
      expect(captured.variables['statuses'], ['archive', 'archived']);
    });

    test('getPendingQuestions maps unanswered status to pending', () async {
      final client = _MockGraphQLClient();
      final dataSource = GraphQLInboxDataSource(graphQLClient: client);

      when(() => client.query(any())).thenAnswer(
        (_) async => _queryResult(data: _questionsPayload),
      );

      final result = await dataSource.getPendingQuestions(
        'recipient-1',
        status: 'unanswered',
      );

      expect(result.isRight(), isTrue);
      final captured =
          verify(() => client.query(captureAny())).captured.single as QueryOptions;
      expect(captured.variables['statuses'], ['pending']);
    });

    test('getPendingQuestions maps valid edges and skips malformed ones', () async {
      final client = _MockGraphQLClient();
      final dataSource = GraphQLInboxDataSource(graphQLClient: client);

      when(() => client.query(any())).thenAnswer(
        (_) async => _queryResult(data: _questionsPayloadWithMalformedEdge),
      );

      final result = await dataSource.getPendingQuestions('recipient-1');

      expect(result.isRight(), isTrue);
      final questions = result.getOrElse(() => []);
      expect(questions, hasLength(1));
      expect(questions.first.id, 'question-1');
      expect(questions.first.questionText, 'Question text');
      expect(questions.first.senderUsername, 'alice');
      expect(questions.first.senderAvatarUrl, 'https://cdn.test/alice.png');
    });
  });
}

QueryResult<Object?> _queryResult({
  Map<String, dynamic>? data,
  OperationException? exception,
}) {
  final options =
      QueryOptions<Object?>(document: gql('query Test { __typename }'));
  return QueryResult<Object?>(
    options: options,
    source: QueryResultSource.network,
    data: data,
    exception: exception,
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
