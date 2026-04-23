// import 'package:flutter_test/flutter_test.dart';
// import 'package:ferry/ferry.dart' as ferry;
// import 'package:mocktail/mocktail.dart';
// import 'package:vibi/features/inbox/data/datasources/graphql_inbox_datasource.dart';

// class _MockFerryClient extends Mock implements ferry.Client {}

// class _FakeOperationRequest extends Fake
//     implements
//         ferry.OperationRequest<Map<String, dynamic>, Map<String, dynamic>> {}

// void main() {
//   setUpAll(() {
//     registerFallbackValue(_FakeOperationRequest());
//   });

//   group('GraphQLInboxDataSource', () {
//     test('getPendingQuestions uses archived statuses when requested', () async {
//       final client = _MockGraphQLClient();
//       final dataSource = GraphQLInboxDataSource(
//         graphQLClient: client,
//         mediaRecommendationsLoader: (_) async => _mediaById,
//       );

//       when(
//         () => client.query(any()),
//       ).thenAnswer((_) async => _queryResult(data: _questionsPayload));

//       final result = await dataSource.getPendingQuestions(
//         'recipient-1',
//         status: 'archived',
//         limit: 12,
//         offset: 4,
//       );

//       expect(result.isRight(), isTrue);
//       final captured = verify(
//         () => client.query(captureAny()),
//       ).captured.cast<QueryOptions>();
//       final questionQuery = captured.single;
//       expect(questionQuery.variables['currentUserId'], 'recipient-1');
//       expect(questionQuery.variables['limit'], 12);
//       expect(questionQuery.variables['offset'], 4);
//       expect(questionQuery.variables['statuses'], ['archive', 'archived']);
//     });

//     test('getPendingQuestions maps unanswered status to pending', () async {
//       final client = _MockGraphQLClient();
//       final dataSource = GraphQLInboxDataSource(
//         graphQLClient: client,
//         mediaRecommendationsLoader: (_) async => _mediaById,
//       );

//       when(
//         () => client.query(any()),
//       ).thenAnswer((_) async => _queryResult(data: _questionsPayload));

//       final result = await dataSource.getPendingQuestions(
//         'recipient-1',
//         status: 'unanswered',
//       );

//       expect(result.isRight(), isTrue);
//       final captured = verify(
//         () => client.query(captureAny()),
//       ).captured.cast<QueryOptions>();
//       final questionQuery = captured.single;
//       expect(questionQuery.variables['statuses'], ['pending']);
//     });

//     test(
//       'getPendingQuestions maps valid edges and skips malformed ones',
//       () async {
//         final client = _MockGraphQLClient();
//         final dataSource = GraphQLInboxDataSource(
//           graphQLClient: client,
//           mediaRecommendationsLoader: (_) async => _mediaById,
//         );

//         when(() => client.query(any())).thenAnswer(
//           (_) async => _queryResult(data: _questionsPayloadWithMalformedEdge),
//         );

//         final result = await dataSource.getPendingQuestions('recipient-1');

//         expect(result.isRight(), isTrue);
//         final questions = result.getOrElse(() => []);
//         expect(questions, hasLength(1));
//         expect(questions.first.id, 'question-1');
//         expect(questions.first.questionText, 'Question text');
//         expect(questions.first.senderUsername, 'alice');
//         expect(questions.first.senderAvatarUrl, 'https://cdn.test/alice.png');
//         expect(questions.first.questionType, 'recommendation');
//         expect(questions.first.mediaRecId, 71);
//         expect(questions.first.mediaRec?.tmdbId, 603);
//         expect(questions.first.mediaRec?.mediaType, 'movie');
//         expect(questions.first.mediaRec?.title, 'The Matrix');
//       },
//     );
//   });
// }

// QueryResult<Object?> _queryResult({
//   Map<String, dynamic>? data,
//   OperationException? exception,
// }) {
//   final options = QueryOptions<Object?>(
//     document: gql('query Test { __typename }'),
//   );
//   return QueryResult<Object?>(
//     options: options,
//     source: QueryResultSource.network,
//     data: data,
//   );
// }

// const _questionsPayload = {
//   'questionsCollection': {
//     'edges': [
//       {
//         'node': {
//           'id': 'question-1',
//           'recipient_id': 'recipient-1',
//           'sender_id': 'sender-1',
//           'question_text': 'Question text',
//           'question_type': 'recommendation',
//           'media_rec_id': 71,
//           'is_anonymous': false,
//           'status': 'pending',
//           'created_at': '2026-01-01T00:00:00.000Z',
//           'profiles': {
//             'username': 'alice',
//             'avatar_urls': ['https://cdn.test/alice.png'],
//           },
//         },
//       },
//     ],
//   },
// };

// const _questionsPayloadWithMalformedEdge = {
//   'questionsCollection': {
//     'edges': [
//       {'node': null},
//       {
//         'node': {
//           'id': 'question-1',
//           'recipient_id': 'recipient-1',
//           'sender_id': 'sender-1',
//           'question_text': 'Question text',
//           'question_type': 'recommendation',
//           'media_rec_id': 71,
//           'is_anonymous': false,
//           'status': 'pending',
//           'created_at': '2026-01-01T00:00:00.000Z',
//           'profiles': {
//             'username': 'alice',
//             'avatar_urls': ['https://cdn.test/alice.png'],
//           },
//         },
//       },
//     ],
//   },
// };

// const _mediaById = {
//   71: {
//     'id': 71,
//     'tmdb_id': 603,
//     'media_type': 'movie',
//     'title': 'The Matrix',
//     'poster_path': '/f89U3ADr1oiB1s9GkdPOEpXUk5H.jpg',
//     'overview': 'A computer hacker learns about the true nature of reality.',
//     'release_date': '1999-03-30',
//     'vote_average': 8.2,
//   },
// };
