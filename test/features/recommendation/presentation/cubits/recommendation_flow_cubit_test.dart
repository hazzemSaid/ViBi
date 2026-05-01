import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vibi/features/recommendation/data/models/tmdb_media.dart';
import 'package:vibi/features/recommendation/data/repositories/recommendation_repository.dart';
import 'package:vibi/features/recommendation/presentation/cubits/recommendation_flow_cubit.dart';
import 'package:vibi/features/recommendation/presentation/cubits/recommendation_flow_state.dart';

class _FakeRecommendationRepository implements RecommendationRepository {
  bool searchCalled = false;
  bool sendCalled = false;
  String? lastQuery;
  String? lastRecipientId;
  TmdbMedia? lastMedia;
  bool? lastIsAnonymous;
  bool searchShouldFail = false;
  bool sendShouldFail = false;
  List<TmdbMedia> searchResults = [];

  @override
  Future<Either<Exception, List<TmdbMedia>>> search(String query) async {
    searchCalled = true;
    lastQuery = query;
    if (searchShouldFail) {
      return Left(Exception('search failed'));
    }
    return Right(searchResults);
  }

  @override
  Future<void> send({
    required String recipientId,
    required TmdbMedia media,
    required bool isAnonymous,
  }) async {
    sendCalled = true;
    lastRecipientId = recipientId;
    lastMedia = media;
    lastIsAnonymous = isAnonymous;
    if (sendShouldFail) {
      throw Exception('send failed');
    }
  }
}

TmdbMedia _makeTmdbMedia({int tmdbId = 1, String title = 'Movie'}) {
  return TmdbMedia(
    tmdbId: tmdbId,
    mediaType: 'movie',
    title: title,
    posterPath: '/poster.jpg',
    overview: 'Overview',
    releaseDate: '2024-01-01',
    voteAverage: 7.0,
  );
}

void main() {
  group('RecommendationFlowCubit', () {
    test('initial state has default values', () {
      final repository = _FakeRecommendationRepository();
      final cubit = RecommendationFlowCubit(repository);

      expect(cubit.state.query, '');
      expect(cubit.state.results, isEmpty);
      expect(cubit.state.selectedMedia, isNull);
      expect(cubit.state.isAnonymous, isFalse);
      expect(cubit.state.isSearching, isFalse);
      expect(cubit.state.isSending, isFalse);
      expect(cubit.state.isSuccess, isFalse);
      expect(cubit.state.errorMessage, isNull);

      cubit.close();
    });

    test('initialize sets isAnonymous', () {
      final repository = _FakeRecommendationRepository();
      final cubit = RecommendationFlowCubit(repository);

      cubit.initialize(isAnonymous: true);

      expect(cubit.state.isAnonymous, isTrue);

      cubit.close();
    });

    test('setAnonymous updates isAnonymous', () {
      final repository = _FakeRecommendationRepository();
      final cubit = RecommendationFlowCubit(repository);

      cubit.setAnonymous(true);
      expect(cubit.state.isAnonymous, isTrue);

      cubit.setAnonymous(false);
      expect(cubit.state.isAnonymous, isFalse);

      cubit.close();
    });

    test('setSelectedMedia updates selectedMedia and clears error', () {
      final repository = _FakeRecommendationRepository();
      final cubit = RecommendationFlowCubit(repository);

      final media = _makeTmdbMedia(title: 'Test Movie');
      cubit.setSelectedMedia(media);

      expect(cubit.state.selectedMedia, isNotNull);
      expect(cubit.state.selectedMedia?.title, 'Test Movie');
      expect(cubit.state.errorMessage, isNull);
      expect(cubit.state.isSuccess, isFalse);

      cubit.close();
    });

    test('onQueryChanged with empty query clears results', () {
      final repository = _FakeRecommendationRepository();
      final cubit = RecommendationFlowCubit(repository);

      cubit.onQueryChanged('');

      expect(cubit.state.query, '');
      expect(cubit.state.results, isEmpty);
      expect(cubit.state.isSearching, isFalse);

      cubit.close();
    });

    test('search emits results on success', () async {
      final repository = _FakeRecommendationRepository()
        ..searchResults = [_makeTmdbMedia(title: 'Movie 1')];
      final cubit = RecommendationFlowCubit(repository);

      await cubit.search('test');

      expect(cubit.state.results, hasLength(1));
      expect(cubit.state.results.first.title, 'Movie 1');
      expect(cubit.state.isSearching, isFalse);
      expect(repository.searchCalled, isTrue);

      cubit.close();
    });

    test('search emits error message on failure', () async {
      final repository = _FakeRecommendationRepository()
        ..searchShouldFail = true;
      final cubit = RecommendationFlowCubit(repository);

      await cubit.search('test');

      expect(cubit.state.errorMessage, isNotNull);
      expect(cubit.state.isSearching, isFalse);
      expect(cubit.state.results, isEmpty);

      cubit.close();
    });

    test('sendRecommendation emits success when repository succeeds', () async {
      final repository = _FakeRecommendationRepository();
      final cubit = RecommendationFlowCubit(repository);

      cubit.setSelectedMedia(_makeTmdbMedia());

      await cubit.sendRecommendation(recipientId: 'user-1');

      expect(cubit.state.isSuccess, isTrue);
      expect(cubit.state.isSending, isFalse);
      expect(repository.sendCalled, isTrue);
      expect(repository.lastRecipientId, 'user-1');
      expect(repository.lastIsAnonymous, isFalse);

      cubit.close();
    });

    test('sendRecommendation emits error on failure', () async {
      final repository = _FakeRecommendationRepository()
        ..sendShouldFail = true;
      final cubit = RecommendationFlowCubit(repository);

      cubit.setSelectedMedia(_makeTmdbMedia());

      await cubit.sendRecommendation(recipientId: 'user-1');

      expect(cubit.state.errorMessage, isNotNull);
      expect(cubit.state.isSending, isFalse);
      expect(cubit.state.isSuccess, isFalse);

      cubit.close();
    });

    test('sendRecommendation does nothing when no media selected', () async {
      final repository = _FakeRecommendationRepository();
      final cubit = RecommendationFlowCubit(repository);

      await cubit.sendRecommendation(recipientId: 'user-1');

      expect(repository.sendCalled, isFalse);
      expect(cubit.state.isSending, isFalse);

      cubit.close();
    });

    test('clearSuccessFlag resets success flag', () {
      final repository = _FakeRecommendationRepository();
      final cubit = RecommendationFlowCubit(repository);

      cubit.setSelectedMedia(_makeTmdbMedia());

      cubit.clearSuccessFlag();
      expect(cubit.state.isSuccess, isFalse);

      cubit.close();
    });
  });
}
