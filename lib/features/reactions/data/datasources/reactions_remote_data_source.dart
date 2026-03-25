import 'package:supabase_flutter/supabase_flutter.dart';

class ReactionsRemoteDataSource {
  ReactionsRemoteDataSource({SupabaseClient? client})
    : _db = client ?? Supabase.instance.client;

  final SupabaseClient _db;

  Future<Map<String, int>> getReactionCounts(String answerId) async {
    final rows = await _db
        .from('reactions')
        .select('reaction')
        .eq('answer_id', answerId);

    final counts = <String, int>{'love': 0, 'sad': 0, 'haha': 0};
    for (final row in rows) {
      final key = row['reaction'] as String?;
      if (key == null) continue;
      counts[key] = (counts[key] ?? 0) + 1;
    }

    return counts;
  }

  Future<String?> getMyReaction({
    required String answerId,
    required String userId,
  }) async {
    final row = await _db
        .from('reactions')
        .select('reaction')
        .eq('answer_id', answerId)
        .eq('user_id', userId)
        .maybeSingle();

    return row?['reaction'] as String?;
  }

  Future<void> toggleReaction({
    required String answerId,
    required String userId,
    required String reaction,
  }) async {
    final existing = await getMyReaction(answerId: answerId, userId: userId);

    if (existing != null && existing == reaction) {
      await _db
          .from('reactions')
          .delete()
          .eq('answer_id', answerId)
          .eq('user_id', userId);
      return;
    }

    if (existing != null) {
      await _db
          .from('reactions')
          .delete()
          .eq('answer_id', answerId)
          .eq('user_id', userId);
    }

    await _db.from('reactions').insert({
      'answer_id': answerId,
      'user_id': userId,
      'reaction': reaction,
    });
  }

  Future<List<Map<String, dynamic>>> getComments(String answerId) async {
    final commentRows = await _db
        .from('comments')
        .select('id, answer_id, user_id, body, created_at')
        .eq('answer_id', answerId)
        .order('created_at', ascending: true);

    final userIds = commentRows
        .map((row) => row['user_id'] as String?)
        .whereType<String>()
        .toSet()
        .toList(growable: false);

    final profilesById = <String, Map<String, dynamic>>{};
    if (userIds.isNotEmpty) {
      final inFilter = '(${userIds.map((id) => '"$id"').join(',')})';
      final profileRows = await _db
          .from('profiles')
          .select('id, username, avatar_url')
          .filter('id', 'in', inFilter);

      for (final profile in profileRows) {
        final id = profile['id'] as String?;
        if (id == null) continue;
        profilesById[id] = profile;
      }
    }

    return commentRows
        .map((row) {
          final userId = row['user_id'] as String?;
          final profile = userId != null ? profilesById[userId] : null;

          return <String, dynamic>{
            ...row,
            'profiles': profile ?? <String, dynamic>{},
          };
        })
        .toList(growable: false);
  }

  Future<void> addComment({
    required String answerId,
    required String userId,
    required String body,
  }) async {
    await _db.from('comments').insert({
      'answer_id': answerId,
      'user_id': userId,
      'body': body,
    });
  }

  Future<int> getCommentsCount(String answerId) async {
    final rows = await _db
        .from('comments')
        .select('id')
        .eq('answer_id', answerId);

    return rows.length;
  }
}
