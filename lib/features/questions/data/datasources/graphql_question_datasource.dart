import 'package:supabase_flutter/supabase_flutter.dart';

class GraphQLQuestionDataSource {
  final SupabaseClient _client;

  GraphQLQuestionDataSource({SupabaseClient? client})
    : _client = client ?? Supabase.instance.client;

  Future<void> sendQuestion({
    required String recipientId,
    required String questionText,
    required bool isAnonymous,
    String? senderId,
  }) async {
    try {
      await _client.from('questions').insert({
        'recipient_id': recipientId,
        'sender_id': isAnonymous ? null : senderId,
        'question_text': questionText,
        'is_anonymous': isAnonymous,
        'status': 'pending',
      });

      // Update question count for recipient
      await _updateQuestionCount(recipientId);
    } catch (e) {
      print('Send question error: $e');
      rethrow;
    }
  }

  Future<void> _updateQuestionCount(String userId) async {
    // The profiles table no longer stores denormalized question counters.
    // Counts are derived from relations in GraphQL queries.
    final _ = userId;
  }
}
