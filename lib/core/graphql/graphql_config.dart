import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:ferry/ferry.dart' as ferry;
import 'package:ferry_hive_store/ferry_hive_store.dart';
import 'package:gql/language.dart';
import 'package:gql_exec/gql_exec.dart';
import 'package:gql_http_link/gql_http_link.dart' as gql_http;
import 'package:hive/hive.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// GraphQL client configuration for Supabase
/// This eliminates N+1 query problems by fetching nested data in a single request
class GraphQLConfig {
  static const String cacheBoxName = 'ferry_graphql_cache';

  static ferry.Client? _ferryClient;

  /// Get the configured Ferry client instance.
  static ferry.Client get ferryClient {
    if (_ferryClient == null) {
      throw Exception(
        'Ferry client not initialized. Call GraphQLConfig.initialize() first.',
      );
    }
    return _ferryClient!;
  }

  /// Initialize the GraphQL client with Supabase configuration
  static Future<void> initialize() async {
    final graphqlUrl = dotenv.env['SUPABASE_GRAPHQL_URL'];
    if (graphqlUrl == null || graphqlUrl.isEmpty) {
      throw Exception('SUPABASE_GRAPHQL_URL not found in .env file');
    }

    final defaultHeaders = {
      'apikey': dotenv.env['SUPABASE_ANON_KEY'] ?? '',
      'Content-Type': 'application/json',
    };

    final ferryAuthLink = ferry.Link.function((request, [forward]) async* {
      if (forward == null) {
        return;
      }

      final token = await _getBearerToken();
      final requestWithHeaders = request
          .updateContextEntry<gql_http.HttpLinkHeaders>((existing) {
            final existingHeaders =
                existing?.headers ?? const <String, String>{};
            return gql_http.HttpLinkHeaders(
              headers: {
                ...existingHeaders,
                ...defaultHeaders,
                ...(token == null
                    ? const <String, String>{}
                    : <String, String>{'Authorization': token}),
              },
            );
          });

      yield* forward(requestWithHeaders);
    });

    final ferryHttpLink = gql_http.HttpLink(graphqlUrl);
    final ferryLink = ferry.Link.from([ferryAuthLink, ferryHttpLink]);

    final cacheBox = await _openCacheBox();
    final cache = ferry.Cache(store: HiveStore(cacheBox));

    _ferryClient = ferry.Client(
      link: ferryLink,
      cache: cache,
      defaultFetchPolicies: const {
        ferry.OperationType.query: ferry.FetchPolicy.NetworkOnly,
        ferry.OperationType.mutation: ferry.FetchPolicy.NetworkOnly,
      },
    );
  }

  static Future<String?> _getBearerToken() async {
    var session = Supabase.instance.client.auth.currentSession;
    if (session != null && session.isExpired) {
      try {
        final refreshed = await Supabase.instance.client.auth.refreshSession();
        session = refreshed.session;
      } catch (_) {
        // Ignore refresh failures and let the backend reject stale tokens.
      }
    }

    if (session?.accessToken != null) {
      return 'Bearer ${session!.accessToken}';
    }
    return null;
  }

  static Future<Box<dynamic>> _openCacheBox() async {
    if (Hive.isBoxOpen(cacheBoxName)) {
      return Hive.box<dynamic>(cacheBoxName);
    }
    return Hive.openBox<dynamic>(cacheBoxName);
  }

  static Future<
    ferry.OperationResponse<Map<String, dynamic>, Map<String, dynamic>>
  >
  ferryQuery(
    String operationName, {
    required String document,
    Map<String, dynamic>? variables,
    ferry.FetchPolicy fetchPolicy = ferry.FetchPolicy.NetworkOnly,
    ferry.Client? clientOverride,
  }) async {
    final activeClient = clientOverride ?? ferryClient;
    final request = ferry.JsonOperationRequest(
      operation: Operation(
        document: parseString(document),
        operationName: operationName,
      ),
      vars: variables ?? const <String, dynamic>{},
      fetchPolicy: fetchPolicy,
    );

    final networkResponse = await activeClient
        .request<Map<String, dynamic>, Map<String, dynamic>>(request)
        .first;

    // Network-first behavior: fallback to cache if transport failed.
    if (networkResponse.linkException != null && networkResponse.data == null) {
      final cacheFallbackRequest = ferry.JsonOperationRequest(
        operation: Operation(
          document: parseString(document),
          operationName: operationName,
        ),
        vars: variables ?? const <String, dynamic>{},
        fetchPolicy: ferry.FetchPolicy.CacheFirst,
      );

      final cacheResponse = await activeClient
          .request<Map<String, dynamic>, Map<String, dynamic>>(
            cacheFallbackRequest,
          )
          .first;

      if (cacheResponse.data != null) {
        return cacheResponse;
      }
    }

    return networkResponse;
  }

  static Future<
    ferry.OperationResponse<Map<String, dynamic>, Map<String, dynamic>>
  >
  ferryMutate(
    String operationName, {
    required String document,
    Map<String, dynamic>? variables,
    ferry.FetchPolicy fetchPolicy = ferry.FetchPolicy.NetworkOnly,
    ferry.Client? clientOverride,
  }) async {
    final activeClient = clientOverride ?? ferryClient;
    final request = ferry.JsonOperationRequest(
      operation: Operation(
        document: parseString(document),
        operationName: operationName,
      ),
      vars: variables ?? const <String, dynamic>{},
      fetchPolicy: fetchPolicy,
    );

    return activeClient
        .request<Map<String, dynamic>, Map<String, dynamic>>(request)
        .first;
  }

  /// Dispose the client
  static void dispose() {
    _ferryClient = null;
  }
}
