import 'package:dartz/dartz.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:vibi/core/errors/errors_handel.dart';
import 'package:vibi/core/graphql/graphql_config.dart';
import 'package:vibi/features/inbox/data/models/inbox_question_model.dart';

class GraphQLInboxDataSource {
  final GraphQLClient _graphQLClient;

  GraphQLInboxDataSource({GraphQLClient? graphQLClient})
    : _graphQLClient = graphQLClient ?? GraphQLConfig.client;

  // ── Queries ────────────────────────────────────────────────────────────────

  static const _pendingQuestionsQuery = r'''
    query GetPendingQuestions($currentUserId: UUID!, $limit: Int!, $offset: Int!, $statuses: [String!]!) {
      questionsCollection(
        filter: {
          recipient_id: { eq: $currentUserId }
          status: { in: $statuses }
        }
        orderBy: [{ created_at: DescNullsLast }]
        first: $limit
        offset: $offset
      ) {
        edges {
          node {
            id
            recipient_id
            sender_id
            question_text
            is_anonymous
            status
            created_at
            profiles {
              username
              avatar_urls
            }
          }
        }
      }
    }
  ''';

  static const _handleQuestionActionMutation = r'''
    mutation HandleQuestionAction(
      $questionId: UUID!
      $userId: UUID!
      $action: String!
      $answerText: String
    ) {
      handle_question_action(
        p_question_id: $questionId
        p_user_id: $userId
        p_action: $action
        p_answer_text: $answerText
      )
    }
  ''';

  // ── Public Methods ─────────────────────────────────────────────────────────

  Future<Either<String, List<InboxQuestionModel>>> getPendingQuestions(
    String currentUserId, {
    int limit = 20,
    int offset = 0,
    String status = 'pending',
  }) async {
    try {
      final statuses = const <String>['pending', 'archive', 'archived'];

      final result = await _graphQLClient.query(
        QueryOptions(
          document: gql(_pendingQuestionsQuery),
          variables: {
            'currentUserId': currentUserId,
            'limit': limit,
            'offset': offset,
            'statuses': statuses,
          },
          fetchPolicy: FetchPolicy.networkOnly,
        ),
      );

      if (result.hasException) {
        return left(SupabaseErrorHandler.getErrorMessage(result.exception));
      }

      final edges =
          result.data?['questionsCollection']?['edges'] as List<dynamic>? ??
          const <dynamic>[];

      final questions = <InboxQuestionModel>[];
      for (final edge in edges) {
        try {
          final node =
              (edge as Map<String, dynamic>)['node'] as Map<String, dynamic>;
          final rawProfile = node['profiles'];

          Map<String, dynamic>? senderProfile;
          if (rawProfile is Map<String, dynamic>) {
            senderProfile = rawProfile;
          } else if (rawProfile is List &&
              rawProfile.isNotEmpty &&
              rawProfile.first is Map) {
            senderProfile = Map<String, dynamic>.from(rawProfile.first as Map);
          }

          questions.add(
            InboxQuestionModel.fromMap({
              'id': node['id'],
              'recipient_id': node['recipient_id'],
              'sender_id': node['sender_id'],
              'question_text': node['question_text'],
              'is_anonymous': node['is_anonymous'],
              'status': node['status'],
              'created_at': node['created_at'],
              'sender': senderProfile,
            }),
          );
        } catch (e) {
          print('WARN: Skipping malformed inbox edge: $e');
        }
      }

      return right(questions);
    } catch (e) {
      return left('Failed to fetch pending questions: $e');
    }
  }

  Future<Either<String, Unit>> answerQuestion({
    required String questionId,
    required String answerText,
    required String userId,
  }) async {
    try {
      print('DEBUG: Starting answerQuestion via RPC: $questionId');

      final result = await _graphQLClient.mutate(
        MutationOptions(
          document: gql(_handleQuestionActionMutation),
          variables: {
            'questionId': questionId,
            'userId': userId,
            'action': 'answer',
            'answerText': answerText,
          },
        ),
      );

      if (result.hasException) {
        print('DEBUG: RPC Answer failed: ${result.exception}');
        return left(SupabaseErrorHandler.getErrorMessage(result.exception));
      }

      print('DEBUG: answerQuestion completed successfully via RPC');
      return right(unit);
    } catch (e) {
      print('DEBUG: Exception in answerQuestion RPC: $e');
      return left('Failed to answer question: $e');
    }
  }

  Future<Either<String, Unit>> deleteQuestion(String questionId) async {
    try {
      print('DEBUG: Starting deleteQuestion via RPC: $questionId');

      final user = Supabase.instance.client.auth.currentUser;
      final userId = user?.id ?? '';

      final result = await _graphQLClient.mutate(
        MutationOptions(
          document: gql(_handleQuestionActionMutation),
          variables: {
            'questionId': questionId,
            'userId': userId,
            'action': 'delete',
            'answerText': null,
          },
        ),
      );

      if (result.hasException) {
        print('DEBUG: RPC Delete failed: ${result.exception}');
        return left(SupabaseErrorHandler.getErrorMessage(result.exception));
      }

      return right(unit);
    } catch (e) {
      print('DEBUG: Exception in deleteQuestion RPC: $e');
      return left('Failed to delete question: $e');
    }
  }

  Future<Either<String, Unit>> archiveQuestion({
    required String questionId,
  }) async {
    try {
      print('DEBUG: Starting archiveQuestion via RPC: $questionId');

      final user = Supabase.instance.client.auth.currentUser;
      final userId = user?.id ?? '';

      final result = await _graphQLClient.mutate(
        MutationOptions(
          document: gql(_handleQuestionActionMutation),
          variables: {
            'questionId': questionId,
            'userId': userId,
            'action': 'archive',
          },
        ),
      );

      if (result.hasException) {
        print('DEBUG: RPC Archive failed: ${result.exception}');
        return left(SupabaseErrorHandler.getErrorMessage(result.exception));
      }

      return right(unit);
    } catch (e) {
      print('DEBUG: Exception in archiveQuestion RPC: $e');
      return left('Failed to archive question: $e');
    }
  }
}
