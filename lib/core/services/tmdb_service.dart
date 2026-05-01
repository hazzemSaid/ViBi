import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
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
      _apiKey = dotenv.env['TMDB_API_KEY']!;

  Future<Either<Exception, List<TmdbMedia>>> search(String query) async {
    try {
      if (_apiKey.isEmpty) {
        return left(Exception('TMDB_API_KEY is missing.'));
      }

      final normalizedQuery = query.trim();
      if (normalizedQuery.isEmpty) return right(const []);

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

      final data = response.data;
      if (data is! Map<String, dynamic>) return right(const []);

      final results =
          (data['results'] as List<dynamic>? ?? const <dynamic>[])
              .whereType<Map<String, dynamic>>()
              .map(TmdbMedia.fromJson)
              .where(
                (item) =>
                    (item.mediaType == 'movie' || item.mediaType == 'tv') &&
                    item.title.trim().isNotEmpty,
              )
              .toList(growable: false);

      return right(results);
    } on DioException catch (e) {
      return left(Exception('TMDB Network Error: ${e.message}'));
    } catch (e) {
      return left(Exception('TMDB Search Error: $e'));
    }
  }
}
