import 'package:dio/dio.dart';
import 'package:vibi/features/recommendation/data/models/tmdb_media.dart';

class TmdbService {
  static const _baseUrl = 'https://api.themoviedb.org/3';

  final Dio _dio;
  final String _apiKey;

  TmdbService({Dio? dio, String? apiKey})
    : _dio =
          dio ??
          Dio(
            BaseOptions(
              baseUrl: _baseUrl,
              connectTimeout: const Duration(seconds: 12),
              receiveTimeout: const Duration(seconds: 16),
            ),
          ),
      _apiKey =
          'eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiI3YmY2MmE3Yzc4YzkxNWQ4YTk3OTcxNDliZjdhMmNkZSIsIm5iZiI6MTc3NjUzMzkyMC4yMjg5OTk5LCJzdWIiOiI2OWUzYzFhMDM4NjBjMjkzODFmYjRiODEiLCJzY29wZXMiOlsiYXBpX3JlYWQiXSwidmVyc2lvbiI6MX0.5Q0NNfAonCkKyXGNP1KDEomIe3vZILoK2U82dNqn_Ns';

  Future<List<TmdbMedia>> search(String query) async {
    final normalizedQuery = query.trim();
    if (normalizedQuery.isEmpty) return const [];

    if (_apiKey.isEmpty) {
      throw Exception('TMDB_API_KEY is missing.');
    }

    final response = await _dio.get(
      '/search/multi',
      queryParameters: {
        'api_key': _apiKey,
        'query': normalizedQuery,
        'include_adult': false,
        'page': 1,
      },
      options: Options(
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
      ),
    );
    print('TMDB search response: ${response.data}');
    final data = response.data;
    if (data is! Map<String, dynamic>) return const [];

    final results = (data['results'] as List<dynamic>? ?? const <dynamic>[])
        .whereType<Map<String, dynamic>>()
        .map(TmdbMedia.fromJson)
        .where(
          (item) =>
              (item.mediaType == 'movie' || item.mediaType == 'tv') &&
              item.title.trim().isNotEmpty,
        )
        .toList(growable: false);

    return results;
  }
}
