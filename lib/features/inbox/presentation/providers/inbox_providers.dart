import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:vibi/core/state/view_state.dart';
import 'package:vibi/features/inbox/data/datasources/graphql_inbox_datasource.dart';
import 'package:vibi/features/inbox/data/repositories/inbox_repository_impl.dart';
import 'package:vibi/features/inbox/domain/entities/inbox_question.dart';
import 'package:vibi/features/inbox/domain/repositories/inbox_repository.dart';

InboxRepository buildInboxRepository(GraphQLInboxDataSource dataSource) {
  final currentUserId = Supabase.instance.client.auth.currentUser?.id ?? '';
  return InboxRepositoryImpl(dataSource, currentUserId);
}

// Real-time provider for pending questions using Supabase channels
// Automatically updates when:
// - New questions are inserted with status='pending' and recipient_id matches current user
// - Questions are updated (e.g., status changes from 'pending' to 'answered')
// - Questions are deleted
// The channel subscription is scoped to current user and auto-disposes when provider is no longer used
class PendingQuestionsCubit extends Cubit<ViewState<List<InboxQuestion>>> {
  PendingQuestionsCubit(this._dataSource)
    : super(const ViewState(status: ViewStatus.loading)) {
    _setupRealtimeSubscription();
    _loadInitialData();
  }

  final GraphQLInboxDataSource _dataSource;

  RealtimeChannel? _channel;

  Future<void> _loadInitialData() async {
    try {
      final repository = buildInboxRepository(_dataSource);
      final questions = await repository.getPendingQuestions();
      emit(ViewState(status: ViewStatus.success, data: questions));
    } catch (e) {
      emit(ViewState(status: ViewStatus.failure, errorMessage: '$e'));
    }
  }

  void _setupRealtimeSubscription() {
    final currentUserId = Supabase.instance.client.auth.currentUser?.id;
    if (currentUserId == null) return;

    final supabase = Supabase.instance.client;

    // Subscribe to changes in questions table for current user
    _channel = supabase
        .channel('inbox_questions_$currentUserId')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'questions',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'recipient_id',
            value: currentUserId,
          ),
          callback: (payload) {
            print('Real-time event received: ${payload.eventType}');
            _handleRealtimeEvent(payload);
          },
        )
        .subscribe();
  }

  Future<void> _handleRealtimeEvent(PostgresChangePayload payload) async {
    final newRecord = payload.newRecord;
    final oldRecord = payload.oldRecord;

    switch (payload.eventType) {
      case PostgresChangeEvent.insert:
        // Only add if status is pending
        if (newRecord['status'] == 'pending') {
          await _refreshQuestions();
        }
        break;

      case PostgresChangeEvent.update:
        // Refresh if status changed or if it's a pending question
        if (newRecord['status'] != 'pending' ||
            oldRecord['status'] != newRecord['status']) {
          await _refreshQuestions();
        }
        break;

      case PostgresChangeEvent.delete:
        // Remove deleted question
        await _refreshQuestions();
        break;

      default:
        break;
    }
  }

  Future<void> _refreshQuestions() async {
    try {
      final repository = buildInboxRepository(_dataSource);
      final questions = await repository.getPendingQuestions();
      emit(ViewState(status: ViewStatus.success, data: questions));
    } catch (e) {
      emit(ViewState(status: ViewStatus.failure, errorMessage: '$e'));
    }
  }

  // Manual refresh method
  Future<void> refresh() async {
    emit(const ViewState(status: ViewStatus.loading));
    await _refreshQuestions();
  }

  @override
  Future<void> close() async {
    await _channel?.unsubscribe();
    return super.close();
  }
}

class AnswerQuestionCubit extends Cubit<ViewState<void>> {
  AnswerQuestionCubit(this._dataSource) : super(const ViewState());

  final GraphQLInboxDataSource _dataSource;

  Future<void> answerQuestion({
    required String questionId,
    required String answerText,
  }) async {
    emit(const ViewState(status: ViewStatus.loading));
    try {
      final repository = buildInboxRepository(_dataSource);
      await repository.answerQuestion(
        questionId: questionId,
        answerText: answerText,
      );
      emit(const ViewState(status: ViewStatus.success));
    } catch (e) {
      emit(ViewState(status: ViewStatus.failure, errorMessage: '$e'));
    }
  }
}

class DeleteQuestionCubit extends Cubit<ViewState<void>> {
  DeleteQuestionCubit(this._dataSource) : super(const ViewState());

  final GraphQLInboxDataSource _dataSource;

  Future<void> deleteQuestion(String questionId) async {
    emit(const ViewState(status: ViewStatus.loading));
    try {
      final repository = buildInboxRepository(_dataSource);
      await repository.deleteQuestion(questionId);
      emit(const ViewState(status: ViewStatus.success));
    } catch (e) {
      emit(ViewState(status: ViewStatus.failure, errorMessage: '$e'));
    }
  }
}
