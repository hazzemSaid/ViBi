import 'package:dartz/dartz.dart';
import 'package:ferry/ferry.dart' as ferry;
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:vibi/core/errors/errors_handel.dart';
import 'package:vibi/core/graphql/graphql_config.dart';
import 'package:vibi/features/inbox/data/models/inbox_question_model.dart';

class GraphQLInboxDataSource {
  final ferry.Client _ferryClient;

  GraphQLInboxDataSource({ferry.Client? ferryClient})
    : _ferryClient = ferryClient ?? GraphQLConfig.ferryClient;

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

  Future<ferry.OperationResponse<Map<String, dynamic>, Map<String, dynamic>>>
  _runNetworkFirstQuery({
    required String operationName,
    required String document,
    required Map<String, dynamic> variables,
  }) {
    return GraphQLConfig.ferryQuery(
      operationName,
      document: document,
      variables: variables,
      clientOverride: _ferryClient,
    );
  }

  Future<ferry.OperationResponse<Map<String, dynamic>, Map<String, dynamic>>>
  _runMutation({
    required String operationName,
    required String document,
    required Map<String, dynamic> variables,
  }) {
    return GraphQLConfig.ferryMutate(
      operationName,
      document: document,
      variables: variables,
      clientOverride: _ferryClient,
    );
  }

  // ── Public Methods ─────────────────────────────────────────────────────────

  Future<Either<String, List<InboxQuestionModel>>> getPendingQuestions(
    String currentUserId, {
    int limit = 20,
    int offset = 0,
    String status = 'pending',
  }) async {
    try {
      final normalizedStatus = status.trim().toLowerCase();
      final statuses = switch (normalizedStatus) {
        'archived' || 'archive' => const <String>['archive', 'archived'],
        '' || 'unanswered' => const <String>['pending'],
        _ => <String>[normalizedStatus],
      };

      final result = await _runNetworkFirstQuery(
        operationName: 'GetPendingQuestions',
        document: _pendingQuestionsQuery,
        variables: {
          'currentUserId': currentUserId,
          'limit': limit,
          'offset': offset,
          'statuses': statuses,
        },
      );

      if (result.hasErrors) {
        return left(SupabaseErrorHandler.getErrorMessage(result));
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
          if (kDebugMode) {
            debugPrint('WARN: Skipping malformed inbox edge: $e');
          }
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
      if (kDebugMode) {
        debugPrint('DEBUG: Starting answerQuestion via RPC: $questionId');
      }

      final result = await _runMutation(
        operationName: 'HandleQuestionAction',
        document: _handleQuestionActionMutation,
        variables: {
          'questionId': questionId,
          'userId': userId,
          'action': 'answer',
          'answerText': answerText,
        },
      );

      if (result.hasErrors) {
        if (kDebugMode) {
          debugPrint('DEBUG: RPC Answer failed: ${result.graphqlErrors}');
          debugPrint('DEBUG: RPC Answer link error: ${result.linkException}');
        }
        return left(SupabaseErrorHandler.getErrorMessage(result));
      }

      if (kDebugMode) {
        debugPrint('DEBUG: answerQuestion completed successfully via RPC');
      }
      return right(unit);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('DEBUG: Exception in answerQuestion RPC: $e');
      }
      return left('Failed to answer question: $e');
    }
  }

  Future<Either<String, Unit>> deleteQuestion(String questionId) async {
    try {
      if (kDebugMode) {
        debugPrint('DEBUG: Starting deleteQuestion via RPC: $questionId');
      }

      final user = Supabase.instance.client.auth.currentUser;
      final userId = user?.id ?? '';

      final result = await _runMutation(
        operationName: 'HandleQuestionAction',
        document: _handleQuestionActionMutation,
        variables: {
          'questionId': questionId,
          'userId': userId,
          'action': 'delete',
          'answerText': null,
        },
      );

      if (result.hasErrors) {
        if (kDebugMode) {
          debugPrint('DEBUG: RPC Delete failed: ${result.graphqlErrors}');
          debugPrint('DEBUG: RPC Delete link error: ${result.linkException}');
        }
        return left(SupabaseErrorHandler.getErrorMessage(result));
      }

      return right(unit);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('DEBUG: Exception in deleteQuestion RPC: $e');
      }
      return left('Failed to delete question: $e');
    }
  }

  Future<Either<String, Unit>> archiveQuestion({
    required String questionId,
  }) async {
    try {
      if (kDebugMode) {
        debugPrint('DEBUG: Starting archiveQuestion via RPC: $questionId');
      }

      final user = Supabase.instance.client.auth.currentUser;
      final userId = user?.id ?? '';

      final result = await _runMutation(
        operationName: 'HandleQuestionAction',
        document: _handleQuestionActionMutation,
        variables: {
          'questionId': questionId,
          'userId': userId,
          'action': 'archive',
        },
      );

      if (result.hasErrors) {
        if (kDebugMode) {
          debugPrint('DEBUG: RPC Archive failed: ${result.graphqlErrors}');
          debugPrint('DEBUG: RPC Archive link error: ${result.linkException}');
        }
        return left(SupabaseErrorHandler.getErrorMessage(result));
      }

      return right(unit);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('DEBUG: Exception in archiveQuestion RPC: $e');
      }
      return left('Failed to archive question: $e');
    }
  }

  Future<Either<String, Unit>> unarchiveQuestion({
    required String questionId,
  }) async {
    try {
      if (kDebugMode) {
        debugPrint('DEBUG: Starting unarchiveQuestion via RPC: $questionId');
      }

      final user = Supabase.instance.client.auth.currentUser;
      final userId = user?.id ?? '';

      final result = await _runMutation(
        operationName: 'HandleQuestionAction',
        document: _handleQuestionActionMutation,
        variables: {
          'questionId': questionId,
          'userId': userId,
          'action': 'unarchive',
        },
      );

      if (result.hasErrors) {
        if (kDebugMode) {
          debugPrint('DEBUG: RPC Unarchive failed: ${result.graphqlErrors}');
          debugPrint(
            'DEBUG: RPC Unarchive link error: ${result.linkException}',
          );
        }
        return left(SupabaseErrorHandler.getErrorMessage(result));
      }

      return right(unit);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('DEBUG: Exception in unarchiveQuestion RPC: $e');
      }
      return left('Failed to unarchive question: $e');
    }
  }
}
