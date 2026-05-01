import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:vibi/features/sendQuestion/data/datasources/question_datasource.dart';
import 'package:vibi/features/sendQuestion/data/models/send_question_dto.dart';

class GraphQLQuestionDataSource implements QuestionDataSource {
  final SupabaseClient _client;

  GraphQLQuestionDataSource({SupabaseClient? client})
    : _client = client ?? Supabase.instance.client;

  @override
  Future<Either<String, void>> sendQuestion(SendQuestionDto dto) async {
    try {
      await _client.from('questions').insert(dto.toMap());

      // Update question count for recipient
      await _updateQuestionCount(dto.recipientId);
      return right(null);
    } catch (e) {
      debugPrint('Send question error: $e');
      return left('Failed to send question: $e');
    }
  }

  Future<void> _updateQuestionCount(String userId) async {
    // The profiles table no longer stores denormalized question counters.
    // Counts are derived from relations in GraphQL queries.
    final _ = userId;
  }
}
