import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// GraphQL client configuration for Supabase
/// This eliminates N+1 query problems by fetching nested data in a single request
class GraphQLConfig {
  static GraphQLClient? _client;

  /// Get the configured GraphQL client instance
  static GraphQLClient get client {
    if (_client == null) {
      throw Exception(
        'GraphQL client not initialized. Call GraphQLConfig.initialize() first.',
      );
    }
    return _client!;
  }

  /// Initialize the GraphQL client with Supabase configuration
  static void initialize() {
    final graphqlUrl = dotenv.env['SUPABASE_GRAPHQL_URL'];
    if (graphqlUrl == null || graphqlUrl.isEmpty) {
      throw Exception('SUPABASE_GRAPHQL_URL not found in .env file');
    }

    // Create auth link that adds bearer token to every request
    final authLink = AuthLink(
      getToken: () async {
        final session = Supabase.instance.client.auth.currentSession;
        if (session?.accessToken != null) {
          return 'Bearer ${session!.accessToken}';
        }
        return null;
      },
    );

    // Create HTTP link to Supabase GraphQL endpoint
    final httpLink = HttpLink(
      graphqlUrl,
      defaultHeaders: {
        'apikey': dotenv.env['SUPABASE_ANON_KEY'] ?? '',
        'Content-Type': 'application/json',
      },
    );

    // Combine auth and HTTP links
    final link = authLink.concat(httpLink);

    // Create the GraphQL client
    _client = GraphQLClient(
      link: link,
      cache: GraphQLCache(store: InMemoryStore()),
      defaultPolicies: DefaultPolicies(
        query: Policies(
          fetch: FetchPolicy.networkOnly, // Always fetch fresh data
        ),
        mutate: Policies(fetch: FetchPolicy.networkOnly),
      ),
    );
  }

  /// Create a new query request
  static QueryOptions queryOptions({
    required String document,
    Map<String, dynamic>? variables,
    FetchPolicy? fetchPolicy,
  }) {
    return QueryOptions(
      document: gql(document),
      variables: variables ?? {},
      fetchPolicy: fetchPolicy ?? FetchPolicy.networkOnly,
    );
  }

  /// Create a new mutation request
  static MutationOptions mutationOptions({
    required String document,
    Map<String, dynamic>? variables,
  }) {
    return MutationOptions(document: gql(document), variables: variables ?? {});
  }

  /// Execute a query and return the result
  static Future<QueryResult> query(
    String document, {
    Map<String, dynamic>? variables,
  }) async {
    final result = await client.query(
      queryOptions(document: document, variables: variables),
    );
    return result;
  }

  /// Execute a mutation and return the result
  static Future<QueryResult> mutate(
    String document, {
    Map<String, dynamic>? variables,
  }) async {
    final result = await client.mutate(
      mutationOptions(document: document, variables: variables),
    );
    return result;
  }

  /// Dispose the client
  static void dispose() {
    _client = null;
  }
}
