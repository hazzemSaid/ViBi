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
    try {
      // Fetch current count
      final profile = await _client
          .from('profiles')
          .select('questions_count')
          .eq('id', userId)
          .maybeSingle();

      if (profile != null) {
        final currentCount = profile['questions_count'] as int? ?? 0;
        await _client
            .from('profiles')
            .update({'questions_count': currentCount + 1})
            .eq('id', userId);
      }
    } catch (e) {
      print('Update question count error: $e');
    }
  }
}
