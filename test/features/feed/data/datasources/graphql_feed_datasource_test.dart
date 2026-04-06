import 'package:flutter_test/flutter_test.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vibi/features/feed/data/datasources/graphql_feed_datasource.dart';

class _MockGraphQLClient extends Mock implements GraphQLClient {}

class _FakeQueryOptions extends Fake implements QueryOptions<Object?> {}

void main() {
  setUpAll(() {
    registerFallbackValue(_FakeQueryOptions());
  });

  group('GraphQLFeedDataSource', () {
    test('getGlobalFeed maps graph data to feed models', () async {
      final client = _MockGraphQLClient();
      final dataSource = GraphQLFeedDataSource(client: client);

      when(
        () => client.query(any()),
      ).thenAnswer((_) async => _queryResult(data: _globalFeedPayload));

      final items = await dataSource.getGlobalFeed(limit: 10, offset: 0);

      expect(items, hasLength(1));
      expect(items.first.id, 'ans-1');
      expect(items.first.answerText, 'Answer text');
      expect(items.first.userId, 'user-1');
      expect(items.first.likesCount, 2);
      expect(items.first.commentsCount, 1);
      expect(items.first.sharesCount, 0);
      expect(items.first.questionText, 'Question text');
      expect(items.first.isAnonymous, isTrue);
      expect(items.first.username, 'Anonymous User');

      final captured =
          verify(() => client.query(captureAny())).captured.single
              as QueryOptions;
      expect(captured.variables['limit'], 10);
      expect(captured.variables['offset'], 0);
      expect(captured.fetchPolicy, FetchPolicy.networkOnly);
    });

    test('getFollowingFeed throws when GraphQL returns exception', () async {
      final client = _MockGraphQLClient();
      final dataSource = GraphQLFeedDataSource(client: client);

      when(
        () => client.query(any()),
      ).thenAnswer((_) async => _queryResult(exception: OperationException()));

      expect(
        () => dataSource.getFollowingFeed('user-1'),
        throwsA(isA<Exception>()),
      );
    });

    test(
      'getUserFeed selects profile query variables when feedType is profile',
      () async {
        final client = _MockGraphQLClient();
        final dataSource = GraphQLFeedDataSource(client: client);

        when(
          () => client.query(any()),
        ).thenAnswer((_) async => _queryResult(data: _globalFeedPayload));

        await dataSource.getUserFeed('user-99', 'profile', limit: 3, offset: 2);

        final captured =
            verify(() => client.query(captureAny())).captured.single
                as QueryOptions;
        expect(captured.variables['userId'], 'user-99');
        expect(captured.variables['limit'], 3);
        expect(captured.variables['offset'], 2);
      },
    );

    test('getProfileFeed returns empty list when no edges', () async {
      final client = _MockGraphQLClient();
      final dataSource = GraphQLFeedDataSource(client: client);

      when(
        () => client.query(any()),
      ).thenAnswer((_) async =>
          _queryResult(data: {
            'answersCollection': {'edges': []},
          }));

      final result = await dataSource.getProfileFeed('user-1');
      expect(result, isEmpty);
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

const _globalFeedPayload = {
  'answersCollection': {
    'edges': [
      {
        'node': {
          'id': 'ans-1',
          'answer_text': 'Answer text',
          'likes_count': 2,
          'comments_count': 1,
          'shares_count': 0,
          'created_at': '2026-01-01T00:00:00.000Z',
          'user_id': 'user-1',
          'profiles': {
            'id': 'user-1',
            'username': 'alice',
            'avatar_urls': ['https://cdn.test/alice.png'],
          },
          'questions': {
            'question_text': 'Question text',
            'is_anonymous': true,
          },
        },
      },
    ],
  },
};
