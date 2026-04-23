import 'package:equatable/equatable.dart';
import 'package:vibi/features/recommendation/data/models/tmdb_media.dart';

class RecommendationFlowState extends Equatable {
  const RecommendationFlowState({
    this.query = '',
    this.results = const <TmdbMedia>[],
    this.selectedMedia,
    this.isAnonymous = false,
    this.isSearching = false,
    this.isSending = false,
    this.errorMessage,
    this.isSuccess = false,
  });

  final String query;
  final List<TmdbMedia> results;
  final TmdbMedia? selectedMedia;
  final bool isAnonymous;
  final bool isSearching;
  final bool isSending;
  final String? errorMessage;
  final bool isSuccess;

  bool get canSend => selectedMedia != null && !isSending;

  RecommendationFlowState copyWith({
    String? query,
    List<TmdbMedia>? results,
    TmdbMedia? selectedMedia,
    bool clearSelectedMedia = false,
    bool? isAnonymous,
    bool? isSearching,
    bool? isSending,
    String? errorMessage,
    bool clearError = false,
    bool? isSuccess,
  }) {
    return RecommendationFlowState(
      query: query ?? this.query,
      results: results ?? this.results,
      selectedMedia: clearSelectedMedia
          ? null
          : (selectedMedia ?? this.selectedMedia),
      isAnonymous: isAnonymous ?? this.isAnonymous,
      isSearching: isSearching ?? this.isSearching,
      isSending: isSending ?? this.isSending,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      isSuccess: isSuccess ?? this.isSuccess,
    );
  }

  @override
  List<Object?> get props => [
    query,
    results,
    selectedMedia,
    isAnonymous,
    isSearching,
    isSending,
    errorMessage,
    isSuccess,
  ];
}
