// import 'package:flutter_test/flutter_test.dart';
// import 'package:ferry/ferry.dart' as ferry;
// import 'package:gql/language.dart' show gql;
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
//       final client = _MockFerryClient();
//       final dataSource = GraphQLInboxDataSource(
//         graphQLClient: client,
//         mediaRecommendationsLoader: (_) async => _mediaById,
//       );

//       when(() => client.request(any())).thenAnswer((invocation) =>
//           Stream.value(_response(data: _questionsPayload)));

//       final result = await dataSource.getPendingQuestions(
//         'recipient-1',
//         status: 'archived',
//         limit: 12,
//         offset: 4,
//       );

//       expect(result.isRight(), isTrue);
//       final captured = verify(() => client.request(captureAny())).captured
//           .whereType<ferry.OperationRequest<Map<String, dynamic>, Map<String, dynamic>>();
//       final request = captured.single;
//       expect(request.vars['currentUserId'], 'recipient-1');
//       expect(request.vars['limit'], 12);
//       expect(request.vars['offset'], 4);
//       expect(request.vars['statuses'], ['archive', 'archived']);
//     });

//     test('getPendingQuestions maps unanswered status to pending', () async {
//       final client = _MockFerryClient();
//       final dataSource = GraphQLInboxDataSource(
//         graphQLClient: client,
//         mediaRecommendationsLoader: (_) async => _mediaById,
//       );

//       when(() => client.request(any())).thenAnswer((invocation) =>
//           Stream.value(_response(data: _questionsPayload)));

//       final result = await dataSource.getPendingQuestions(
//         'recipient-1',
//         status: 'unanswered',
//       );

//       expect(result.isRight(), isTrue);
//       final captured = verify(() => client.request(captureAny())).captured
//           .whereType<ferry.OperationRequest<Map<String, dynamic>, Map<String, dynamic>>();
//       final request = captured.single;
//       expect(request.vars['statuses'], ['pending']);
//     });

//     test(
//       'getPendingQuestions maps valid edges and skips malformed ones',
//       () async {
//         final client = _MockFerryClient();
//         final dataSource = GraphQLInboxDataSource(
//           graphQLClient: client,
//           mediaRecommendationsLoader: (_) async => _mediaById,
//         );

//         when(() => client.request(any())).thenAnswer((invocation) =>
//             Stream.value(_response(data: _questionsPayloadWithMalformedEdge)));

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

// ferry.OperationResponse<Map<String, dynamic>, dynamic> _response({
//   Map<String, dynamic>? data,
// }) {
//   final request = ferry.JsonOperationRequest<Map<String, dynamic>, dynamic>(
//     operation: Operation(
//       document: gql('query Test { __typename }'),
//     ),
//     vars: const <String, dynamic>{},
//   );
//   return ferry.OperationResponse<Map<String, dynamic>, dynamic>(
//     operationRequest: request,
//     data: data,
//     dataSource: ferry.DataSource.network,
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
