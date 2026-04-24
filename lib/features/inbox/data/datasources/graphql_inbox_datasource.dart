import 'package:dartz/dartz.dart';
import 'package:ferry/ferry.dart' as ferry;
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:vibi/core/errors/errors_handel.dart';
import 'package:vibi/core/graphql/graphql_config.dart';
import 'package:vibi/core/graphql/mutations/inbox_mutations.dart';
import 'package:vibi/core/graphql/queries/inbox_queries.dart';
import 'package:vibi/features/inbox/data/models/inbox_question_model.dart';

class GraphQLInboxDataSource {
  final ferry.Client _ferryClient;
  final Future<Map<int, Map<String, dynamic>>> Function(Set<int> ids)
  _mediaRecommendationsLoader;

  GraphQLInboxDataSource({
    ferry.Client? graphQLClient,
    Future<Map<int, Map<String, dynamic>>> Function(Set<int> ids)?
    mediaRecommendationsLoader,
  }) : _ferryClient = graphQLClient ?? GraphQLConfig.ferryClient,
       _mediaRecommendationsLoader =
           mediaRecommendationsLoader ?? _defaultLoadMediaRecommendationsById;

  // ── Queries ────────────────────────────────────────────────────────────────



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
        document: InboxQueries.getPendingQuestions,
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

      final mediaIds = _extractRecommendationMediaIds(edges);
      final mediaById = await _mediaRecommendationsLoader(mediaIds);

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
              'question_type': node['question_type'],
              'media_rec_id': node['media_rec_id'],
              'media_recommendations': mediaById[_asInt(node['media_rec_id'])],
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

  Set<int> _extractRecommendationMediaIds(List<dynamic> questionEdges) {
    final ids = <int>{};

    for (final edge in questionEdges) {
      if (edge is! Map<String, dynamic>) continue;
      final node = edge['node'];
      if (node is! Map<String, dynamic>) continue;

      final questionType = (node['question_type'] as String? ?? '')
          .trim()
          .toLowerCase();
      if (questionType != 'recommendation') continue;

      final mediaRecId = _asInt(node['media_rec_id']);
      if (mediaRecId != null) {
        ids.add(mediaRecId);
      }
    }

    return ids;
  }

  static Future<Map<int, Map<String, dynamic>>>
  _defaultLoadMediaRecommendationsById(Set<int> ids) async {
    if (ids.isEmpty) return const {};

    try {
      final rows = await Supabase.instance.client
          .from('media_recommendations')
          .select('*')
          .inFilter('id', ids.toList(growable: false));

      final mediaById = <int, Map<String, dynamic>>{};
      for (final row in rows.cast<Map<String, dynamic>>()) {
        final map = _normalizeMediaRecommendationRow(row);
        final id = _asIntStatic(map['id']);
        if (id != null) {
          mediaById[id] = map;
        }
      }

      return mediaById;
    } catch (e) {
      if (kDebugMode) {
        debugPrint(
          'WARN: Failed to load media recommendations from Supabase: $e',
        );
      }
      return const {};
    }
  }

  int? _asInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  static int? _asIntStatic(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  static Map<String, dynamic> _normalizeMediaRecommendationRow(
    Map<String, dynamic> row,
  ) {
    final map = Map<String, dynamic>.from(row);

    final posterPath = _firstNonEmptyString([
      map['poster_path'],
      map['posterPath'],
      map['poster_url'],
      map['posterUrl'],
      map['image_url'],
      map['imageUrl'],
    ]);

    if (posterPath != null) {
      map['poster_path'] = _normalizePosterPathValue(posterPath);
    }

    map['tmdb_id'] = _asIntStatic(map['tmdb_id'] ?? map['tmdbId']) ?? 0;
    map['media_type'] =
        _firstNonEmptyString([
          map['media_type'],
          map['mediaType'],
        ])?.toLowerCase() ??
        '';
    map['title'] = _firstNonEmptyString([map['title'], map['name']]) ?? '';

    return map;
  }

  static String? _firstNonEmptyString(List<dynamic> values) {
    for (final value in values) {
      final text = value?.toString().trim() ?? '';
      if (text.isNotEmpty) return text;
    }
    return null;
  }

  static String _normalizePosterPathValue(String raw) {
    final value = raw.trim();
    if (value.isEmpty) return value;

    if (!value.startsWith('http://') && !value.startsWith('https://')) {
      return value.startsWith('/') ? value : '/$value';
    }

    final marker = '/t/p/';
    final markerIndex = value.indexOf(marker);
    if (markerIndex != -1) {
      final lastSlash = value.lastIndexOf('/');
      if (lastSlash != -1 && lastSlash + 1 < value.length) {
        return '/${value.substring(lastSlash + 1)}';
      }
    }

    return value;
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
        document: InboxMutations.handleQuestionAction,
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
        document: InboxMutations.handleQuestionAction,
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
        document: InboxMutations.handleQuestionAction,
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
        document: InboxMutations.handleQuestionAction,
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
