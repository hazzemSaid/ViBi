import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:vibi/core/services/tmdb_service.dart';
import 'package:vibi/features/recommendation/data/models/tmdb_media.dart';

class RecommendationRepository {
  final SupabaseClient _supabase;
  final TmdbService _tmdb;

  RecommendationRepository({
    required SupabaseClient supabase,
    required TmdbService tmdb,
  }) : _supabase = supabase,
       _tmdb = tmdb;

  Future<Either<Exception, List<TmdbMedia>>> search(String query) =>
      _tmdb.search(query);

  Future<void> send({
    required String recipientId,
    required TmdbMedia media,
    required bool isAnonymous,
  }) async {
    final currentUserId = _supabase.auth.currentUser?.id;

    await _supabase.rpc(
      'send_recommendation',
      params: {
        'p_recipient_id': recipientId,
        'p_sender_id': isAnonymous ? null : currentUserId,
        'p_is_anonymous': isAnonymous,
        'p_tmdb_id': media.tmdbId,
        'p_media_type': media.mediaType,
        'p_title': media.title,
        'p_poster_path': media.posterPath,
        'p_overview': media.overview,
        'p_release_date': media.releaseDate,
        'p_vote_average': media.voteAverage,
      },
    );
  }
}
