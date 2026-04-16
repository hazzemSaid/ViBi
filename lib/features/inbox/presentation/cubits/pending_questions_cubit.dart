import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:vibi/features/inbox/domain/usecases/get_pending_questions_usecase.dart';
import 'package:vibi/features/inbox/presentation/state/pending_questions_state.dart';

class PendingQuestionsCubit extends Cubit<PendingQuestionsState> {
  PendingQuestionsCubit(this._getPendingQuestionsUseCase)
    : super(const PendingQuestionsInitial()) {
    _setupRealtimeSubscription();
    loadInitialQuestions();
  }

  final GetPendingQuestionsUseCase _getPendingQuestionsUseCase;
  final int _limit = 20;
  int _offset = 0;
  bool _hasMore = true;
  bool _isLoadingMore = false;
  String _currentStatus = 'unanswered';

  RealtimeChannel? _channel;

  String get currentStatus => _currentStatus;

  Future<void> loadUnansweredQuestions() async {
    _currentStatus = 'unanswered';
    await loadInitialQuestions();
  }

  Future<void> loadPendingQuestions() async {
    _currentStatus = 'pending';
    await loadInitialQuestions();
  }

  Future<void> loadArchivedQuestions() async {
    _currentStatus = 'archive';
    await loadInitialQuestions();
  }

  Future<void> setQuestionStatus(String status) async {
    if (_currentStatus == status) return;
    _currentStatus = status;
    await loadInitialQuestions();
  }

  Future<void> loadInitialQuestions() async {
    _offset = 0;
    _hasMore = true;
    _isLoadingMore = false;
    if (isClosed) return;
    emit(const PendingQuestionsLoading());

    final result = await _getPendingQuestionsUseCase(
      limit: _limit,
      offset: _offset,
      status: _currentStatus,
    );

    result.fold(
      (error) {
        if (!isClosed) {
          emit(PendingQuestionsError(error));
        }
      },
      (questions) {
        _hasMore = questions.length == _limit;
        if (!isClosed) {
          emit(
            PendingQuestionsSuccess(questions: questions, hasMore: _hasMore),
          );
        }
      },
    );
  }

  Future<void> loadMoreQuestions() async {
    final currentState = state;
    if (currentState is! PendingQuestionsSuccess) return;
    if (_isLoadingMore || !_hasMore) return;

    _isLoadingMore = true;
    if (!isClosed) {
      emit(currentState.copyWith(isLoadingMore: true));
    }

    final previousOffset = _offset;
    _offset += _limit;

    final result = await _getPendingQuestionsUseCase(
      limit: _limit,
      offset: _offset,
      status: _currentStatus,
    );

    result.fold(
      (error) {
        _offset = previousOffset;
        if (!isClosed && state is PendingQuestionsSuccess) {
          final latestState = state as PendingQuestionsSuccess;
          emit(latestState.copyWith(isLoadingMore: false));
        }
      },
      (newQuestions) {
        if (newQuestions.length < _limit) {
          _hasMore = false;
        }

        if (!isClosed && state is PendingQuestionsSuccess) {
          final latestState = state as PendingQuestionsSuccess;
          emit(
            PendingQuestionsSuccess(
              questions: [...latestState.questions, ...newQuestions],
              hasMore: _hasMore,
              isLoadingMore: false,
            ),
          );
        }
      },
    );

    _isLoadingMore = false;
  }

  void _setupRealtimeSubscription() {
    final currentUserId = Supabase.instance.client.auth.currentUser?.id;
    if (currentUserId == null) return;

    final supabase = Supabase.instance.client;

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
        if (_matchesCurrentStatus(newRecord['status']?.toString())) {
          await loadInitialQuestions();
        }
        break;

      case PostgresChangeEvent.update:
        final questionId = (newRecord['id'] ?? oldRecord['id'])?.toString();
        if (questionId == null) return;

        final newStatus = newRecord['status']?.toString();
        final oldStatus = oldRecord['status']?.toString();

        final wasInCurrentStatus = _matchesCurrentStatus(oldStatus);
        final isInCurrentStatus = _matchesCurrentStatus(newStatus);

        if (wasInCurrentStatus && !isInCurrentStatus) {
          _removeQuestionById(questionId);
          return;
        }

        if (wasInCurrentStatus && isInCurrentStatus) {
          if (oldStatus != newStatus) {
            await loadInitialQuestions();
          }
          return;
        }

        if (!wasInCurrentStatus && isInCurrentStatus) {
          await loadInitialQuestions();
        }
        break;

      case PostgresChangeEvent.delete:
        final questionId = oldRecord['id']?.toString();
        if (questionId != null) {
          _removeQuestionById(questionId);
        }
        break;

      default:
        break;
    }
  }

  bool _matchesCurrentStatus(String? status) {
    if (status == null) return false;
    final normalized = status.trim().toLowerCase();
    if (_currentStatus == 'unanswered') {
      return normalized != 'answered' && normalized != 'deleted';
    }
    if (_currentStatus == 'archive') {
      return normalized == 'archive' || normalized == 'archived';
    }
    return normalized == _currentStatus;
  }

  void _removeQuestionById(String questionId) {
    final currentState = state;
    if (currentState is! PendingQuestionsSuccess) return;

    final updatedQuestions = currentState.questions
        .where((question) => question.id != questionId)
        .toList();

    if (isClosed) return;
    emit(
      currentState.copyWith(questions: updatedQuestions, isLoadingMore: false),
    );
  }

  Future<void> refresh() async {
    await loadInitialQuestions();
  }

  @override
  Future<void> close() async {
    await _channel?.unsubscribe();
    return super.close();
  }
}
