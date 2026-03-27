import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:vibi/features/inbox/data/models/inbox_question_model.dart';

class GraphQLInboxDataSource {
  final SupabaseClient _client;

  GraphQLInboxDataSource({SupabaseClient? client})
    : _client = client ?? Supabase.instance.client;

  Future<List<InboxQuestionModel>> getPendingQuestions(
    String currentUserId,
  ) async {
    try {
      // Fetch pending questions
      final response = await _client
          .from('questions')
          .select()
          .eq('recipient_id', currentUserId)
          .eq('status', 'pending')
          .order('created_at', ascending: false);

      // For non-anonymous questions, fetch sender info separately
      final questions = (response as List)
          .map((json) => InboxQuestionModel.fromMap(json))
          .toList();

      // Enrich with sender profile data for non-anonymous questions
      for (var i = 0; i < questions.length; i++) {
        if (!questions[i].isAnonymous && questions[i].senderId != null) {
          try {
            final senderProfile = await _client
                .from('profiles')
                .select('username, avatar_url')
                .eq('id', questions[i].senderId!)
                .maybeSingle();

            if (senderProfile != null) {
              // Create updated question with sender info
              questions[i] = InboxQuestionModel(
                id: questions[i].id,
                recipientId: questions[i].recipientId,
                senderId: questions[i].senderId,
                senderUsername: senderProfile['username'] as String?,
                senderAvatarUrl: senderProfile['avatar_url'] as String?,
                questionText: questions[i].questionText,
                isAnonymous: questions[i].isAnonymous,
                status: questions[i].status,
                createdAt: questions[i].createdAt,
              );
            }
          } catch (e) {
            print('Error fetching sender profile: $e');
            // Continue without sender profile
          }
        }
      }

      return questions;
    } catch (e) {
      print('Get pending questions error: $e');
      rethrow;
    }
  }

  Future<void> answerQuestion({
    required String questionId,
    required String answerText,
    required String userId,
  }) async {
    try {
      // Get the question first to get recipient_id
      final questionData = await _client
          .from('questions')
          .select('recipient_id')
          .eq('id', questionId)
          .maybeSingle();

      if (questionData == null) {
        throw Exception('Question not found');
      }

      // Insert answer
      await _client.from('answers').insert({
        'question_id': questionId,
        'user_id': userId,
        'answer_text': answerText,
      });

      // Update question status
      await _client
          .from('questions')
          .update({
            'status': 'answered',
            'answered_at': DateTime.now().toIso8601String(),
          })
          .eq('id', questionId);

      // Update answer count for user
      await _updateAnswerCount(userId);

      // Update question count for recipient (decrement pending)
      await _updateQuestionCount(questionData['recipient_id'] as String);
    } catch (e) {
      print('Answer question error: $e');
      rethrow;
    }
  }

  Future<void> deleteQuestion(String questionId) async {
    try {
      // Get the question first to get recipient_id
      final questionData = await _client
          .from('questions')
          .select('recipient_id')
          .eq('id', questionId)
          .maybeSingle();

      if (questionData == null) {
        throw Exception('Question not found');
      }

      // Update status to deleted instead of hard delete
      await _client
          .from('questions')
          .update({'status': 'deleted'})
          .eq('id', questionId);

      // Update question count for recipient
      await _updateQuestionCount(questionData['recipient_id'] as String);
    } catch (e) {
      print('Delete question error: $e');
      rethrow;
    }
  }

  Future<void> _updateAnswerCount(String userId) async {
    // The profiles table no longer stores denormalized answer counters.
    // Counts are derived from relations in GraphQL queries.
    final _ = userId;
  }

  Future<void> _updateQuestionCount(String userId) async {
    // The profiles table no longer stores denormalized question counters.
    // Counts are derived from relations in GraphQL queries.
    final _ = userId;
  }
}
