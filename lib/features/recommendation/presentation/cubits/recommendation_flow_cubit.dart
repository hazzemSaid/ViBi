import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vibi/features/recommendation/data/models/tmdb_media.dart';
import 'package:vibi/features/recommendation/data/repositories/recommendation_repository.dart';
import 'package:vibi/features/recommendation/presentation/cubits/recommendation_flow_state.dart';

class RecommendationFlowCubit extends Cubit<RecommendationFlowState> {
  RecommendationFlowCubit(this._repository)
    : super(const RecommendationFlowState());

  final RecommendationRepository _repository;
  Timer? _debounce;

  void initialize({required bool isAnonymous}) {
    emit(state.copyWith(isAnonymous: isAnonymous));
  }

  void setAnonymous(bool value) {
    emit(state.copyWith(isAnonymous: value));
  }

  void setSelectedMedia(TmdbMedia media) {
    emit(
      state.copyWith(selectedMedia: media, clearError: true, isSuccess: false),
    );
  }

  void onQueryChanged(String value) {
    final query = value.trim();
    emit(state.copyWith(query: value, clearError: true, isSuccess: false));

    _debounce?.cancel();

    if (query.isEmpty) {
      emit(
        state.copyWith(
          results: const <TmdbMedia>[],
          isSearching: false,
          clearError: true,
        ),
      );
      return;
    }

    _debounce = Timer(const Duration(milliseconds: 400), () {
      search(query);
    });
  }

  Future<void> search(String query) async {
    emit(state.copyWith(isSearching: true, clearError: true, isSuccess: false));

    try {
      final results = await _repository.search(query);
      if (results.isLeft()) {
        emit(
          state.copyWith(
            results: const <TmdbMedia>[],
            isSearching: false,
            errorMessage:
                'Could not load recommendations. Check your connection and TMDB key.',
          ),
        );
        return;
      }
      emit(
        state.copyWith(
          results: results.getOrElse(() => const []),
          isSearching: false,
          clearError: true,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          results: const <TmdbMedia>[],
          isSearching: false,
          errorMessage:
              'Could not load recommendations. Check your connection and TMDB key.',
        ),
      );
    }
  }

  Future<void> sendRecommendation({required String recipientId}) async {
    if (state.selectedMedia == null || state.isSending) return;

    emit(state.copyWith(isSending: true, clearError: true, isSuccess: false));

    try {
      await _repository.send(
        recipientId: recipientId,
        media: state.selectedMedia!,
        isAnonymous: state.isAnonymous,
      );

      emit(state.copyWith(isSending: false, isSuccess: true, clearError: true));
    } catch (_) {
      emit(
        state.copyWith(
          isSending: false,
          errorMessage: 'Failed to send recommendation. Please try again.',
          isSuccess: false,
        ),
      );
    }
  }

  void clearSuccessFlag() {
    if (!state.isSuccess) return;
    emit(state.copyWith(isSuccess: false));
  }

  @override
  Future<void> close() {
    _debounce?.cancel();
    return super.close();
  }
}
