import 'package:dartz/dartz.dart';
import 'package:ferry/ferry.dart' as ferry;
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:vibi/core/errors/errors_handel.dart';
import 'package:vibi/core/graphql/graphql_config.dart';
import 'package:vibi/core/graphql/queries/inbox_queries.dart';
import 'package:vibi/features/inbox/data/datasources/inbox_datasource.dart';
import 'package:vibi/features/inbox/data/models/inbox_question_model.dart';

/**
 * Data source for fetching inbox questions via GraphQL.
 */
class GraphQLInboxDataSource implements InboxDataSource {
  final ferry.Client _ferryClient;
  final Future<Map<int, Map<String, dynamic>>> Function(Set<int> ids)
      _mediaRecommendationsLoader;

  /**
   * Initializes the [GraphQLInboxDataSource] with an optional GraphQL client
   * and an optional media recommendations loader.
   */
  GraphQLInboxDataSource({
    ferry.Client? graphQLClient,
    Future<Map<int, Map<String, dynamic>>> Function(Set<int> ids)?
        mediaRecommendationsLoader,
  })  : _ferryClient = graphQLClient ?? GraphQLConfig.ferryClient,
        _mediaRecommendationsLoader =
            mediaRecommendationsLoader ?? _defaultLoadMediaRecommendationsById;

  // ── Logging ──────────────────────────────────────────────────────────────

  /**
   * Internal logging helper that only prints in debug mode.
   */
  static void _log(String message) {
    if (kDebugMode) debugPrint(message);
  }

  // ── GraphQL Helpers ──────────────────────────────────────────────────────

  /**
   * Runs a GraphQL query with a 'network-only' fetch policy.
   */
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

  // ── Questions Query ──────────────────────────────────────────────────────

  /**
   * Fetches a list of questions for a specific user from the GraphQL API.
   *
   * [currentUserId] is the ID of the user whose questions are being fetched.
   * [limit] is the maximum number of questions to retrieve.
   * [offset] is used for pagination to skip a certain number of results.
   * [status] filters the questions based on their current state (e.g., 'pending').
   *
   * Returns:
   * - [Right] containing a [List] of [InboxQuestionModel] on success.
   * - [Left] containing an error [String] if the network request or parsing fails.
   */
  @override
  Future<Either<String, List<InboxQuestionModel>>> getPendingQuestions(
    String currentUserId, {
    int limit = 20,
    int offset = 0,
    String status = 'pending',
  }) async {
    try {
      final statuses = _resolveStatuses(status);

      final result = await _runNetworkFirstQuery(
        operationName: InboxQueries.getPendingQuestionsOpName,
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

      final mediaById =
          await _mediaRecommendationsLoader(_extractMediaIds(edges));

      return right(_parseQuestionEdges(edges, mediaById));
    } catch (e) {
      return left('Failed to fetch pending questions: $e');
    }
  }

  /**
   * Resolves the question status string into a list of specific status values.
   * When 'all' is specified, returns all possible statuses to fetch everything.
   */
  List<String> _resolveStatuses(String status) {
    final normalized = status.trim().toLowerCase();
    return switch (normalized) {
      'archived' || 'archive' => const ['archive', 'archived'],
      '' || 'unanswered' => const ['pending'],
      'all' => const ['pending', 'answered', 'deleted', 'archive', 'archived'],
      _ => [normalized],
    };
  }

  /**
   * Parses raw GraphQL edges into a list of [InboxQuestionModel].
   */
  List<InboxQuestionModel> _parseQuestionEdges(
    List<dynamic> edges,
    Map<int, Map<String, dynamic>> mediaById,
  ) {
    final questions = <InboxQuestionModel>[];

    for (final edge in edges) {
      try {
        final node =
            (edge as Map<String, dynamic>)['node'] as Map<String, dynamic>;
        questions.add(_buildQuestionModel(node, mediaById));
      } catch (e) {
        _log('WARN: Skipping malformed inbox edge: $e');
      }
    }

    return questions;
  }

  /**
   * Builds an [InboxQuestionModel] from a raw JSON node.
   */
  InboxQuestionModel _buildQuestionModel(
    Map<String, dynamic> node,
    Map<int, Map<String, dynamic>> mediaById,
  ) {
    return InboxQuestionModel.fromMap({
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
      'sender': _parseSenderProfile(node['profiles']),
    });
  }

  /**
   * Extracts the sender profile from a raw profiles object (handles Map or List).
   */
  static Map<String, dynamic>? _parseSenderProfile(dynamic rawProfile) {
    if (rawProfile is Map<String, dynamic>) return rawProfile;
    if (rawProfile is List &&
        rawProfile.isNotEmpty &&
        rawProfile.first is Map) {
      return Map<String, dynamic>.from(rawProfile.first as Map);
    }
    return null;
  }

  // ── Media Recommendations ────────────────────────────────────────────────

  /**
   * Extracts media recommendation IDs from a list of question edges.
   */
  Set<int> _extractMediaIds(List<dynamic> questionEdges) {
    final ids = <int>{};

    for (final edge in questionEdges) {
      if (edge is! Map<String, dynamic>) continue;
      final node = edge['node'];
      if (node is! Map<String, dynamic>) continue;

      final type =
          (node['question_type'] as String? ?? '').trim().toLowerCase();
      if (type != 'recommendation') continue;

      final id = _asInt(node['media_rec_id']);
      if (id != null) ids.add(id);
    }

    return ids;
  }

  /**
   * Default loader for fetching media recommendations by ID from Supabase.
   */
  static Future<Map<int, Map<String, dynamic>>>
      _defaultLoadMediaRecommendationsById(Set<int> ids) async {
    if (ids.isEmpty) return const {};

    try {
      final rows = await Supabase.instance.client
          .from('media_recommendations')
          .select('*')
          .inFilter('id', ids.toList(growable: false));

      return {
        for (final row in rows.cast<Map<String, dynamic>>())
          if (_asInt(_normalizeMediaRow(row)['id']) case final id?)
            id: _normalizeMediaRow(row),
      };
    } catch (e) {
      _log('WARN: Failed to load media recommendations from Supabase: $e');
      return const {};
    }
  }

  // ── Normalization Utilities ──────────────────────────────────────────────

  /**
   * Safely converts a dynamic value to an integer.
   */
  static int? _asInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  /**
   * Normalizes raw media recommendation data for consistency.
   */
  static Map<String, dynamic> _normalizeMediaRow(Map<String, dynamic> row) {
    final map = Map<String, dynamic>.from(row);

    final posterPath = _firstNonEmpty([
      map['poster_path'],
      map['posterPath'],
      map['poster_url'],
      map['posterUrl'],
      map['image_url'],
      map['imageUrl'],
    ]);

    if (posterPath != null) {
      map['poster_path'] = _normalizePosterPath(posterPath);
    }

    map['tmdb_id'] = _asInt(map['tmdb_id'] ?? map['tmdbId']) ?? 0;
    map['media_type'] =
        _firstNonEmpty([map['media_type'], map['mediaType']])?.toLowerCase() ??
            '';
    map['title'] = _firstNonEmpty([map['title'], map['name']]) ?? '';

    return map;
  }

  /**
   * Returns the first non-empty string from a list of potential values.
   */
  static String? _firstNonEmpty(List<dynamic> values) {
    for (final value in values) {
      final text = value?.toString().trim() ?? '';
      if (text.isNotEmpty) return text;
    }
    return null;
  }

  /**
   * Normalizes a poster path to ensure it's a relative path starting with '/'.
   */
  static String _normalizePosterPath(String raw) {
    final value = raw.trim();
    if (value.isEmpty) return value;

    if (!value.startsWith('http://') && !value.startsWith('https://')) {
      return value.startsWith('/') ? value : '/$value';
    }

    final markerIndex = value.indexOf('/t/p/');
    if (markerIndex != -1) {
      final lastSlash = value.lastIndexOf('/');
      if (lastSlash != -1 && lastSlash + 1 < value.length) {
        return '/${value.substring(lastSlash + 1)}';
      }
    }

    return value;
  }
}

