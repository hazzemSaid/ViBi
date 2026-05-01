import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vibi/features/search/domain/entities/content_search_result.dart';
import 'package:vibi/features/search/domain/entities/user_search_result.dart';
import 'package:vibi/features/search/domain/repositories/search_repository.dart';
import 'package:vibi/features/search/presentation/providers/search_providers.dart';
import 'package:vibi/features/search/presentation/providers/search_state.dart';

class _FakeSearchRepository implements SearchRepository {
  bool searchUsersCalled = false;
  bool searchContentCalled = false;
  String? lastUserQuery;
  String? lastContentQuery;
  bool shouldFail = false;
  String errorMessage = 'search failed';
  List<UserSearchResult> usersToReturn = [];
  List<ContentSearchResult> contentToReturn = [];

  @override
  Future<Either<String, List<UserSearchResult>>> searchUsers(String query) async {
    searchUsersCalled = true;
    lastUserQuery = query;
    if (shouldFail) {
      return Left(errorMessage);
    }
    return Right(usersToReturn);
  }

  @override
  Future<Either<String, List<ContentSearchResult>>> searchContent(String query) async {
    searchContentCalled = true;
    lastContentQuery = query;
    if (shouldFail) {
      return Left(errorMessage);
    }
    return Right(contentToReturn);
  }
}

void main() {
  group('UserSearchCubit', () {
    test('initial state is initial', () {
      final repository = _FakeSearchRepository();
      final cubit = UserSearchCubit(repository);

      expect(cubit.state, isA<UserSearchInitial>());

      cubit.close();
    });

    test('search emits loaded with results on success', () async {
      final repository = _FakeSearchRepository()
        ..usersToReturn = [
          UserSearchResult(
            id: 'user-1',
            username: 'alice',
            followersCount: 10,
            answersCount: 5,
            isPrivate: false,
          ),
        ];
      final cubit = UserSearchCubit(repository);

      await cubit.search('alice');

      expect(cubit.state, isA<UserSearchLoaded>());
      final loaded = cubit.state as UserSearchLoaded;
      expect(loaded.results, hasLength(1));
      expect(loaded.results.first.username, 'alice');
      expect(repository.searchUsersCalled, isTrue);
      expect(repository.lastUserQuery, 'alice');

      cubit.close();
    });

    test('search emits failure on error', () async {
      final repository = _FakeSearchRepository()..shouldFail = true;
      final cubit = UserSearchCubit(repository);

      await cubit.search('query');

      expect(cubit.state, isA<UserSearchFailure>());
      final failure = cubit.state as UserSearchFailure;
      expect(failure.message, contains('search failed'));

      cubit.close();
    });

    test('search with empty query emits loaded with empty list', () async {
      final repository = _FakeSearchRepository();
      final cubit = UserSearchCubit(repository);

      await cubit.search('');

      expect(cubit.state, isA<UserSearchLoaded>());
      final loaded = cubit.state as UserSearchLoaded;
      expect(loaded.results, isEmpty);
      expect(repository.searchUsersCalled, isFalse);

      cubit.close();
    });
  });

  group('ContentSearchCubit', () {
    test('initial state is initial', () {
      final repository = _FakeSearchRepository();
      final cubit = ContentSearchCubit(repository);

      expect(cubit.state, isA<ContentSearchInitial>());

      cubit.close();
    });

    test('search emits loaded with results on success', () async {
      final repository = _FakeSearchRepository()
        ..contentToReturn = [
          ContentSearchResult(
            id: 'content-1',
            userId: 'user-1',
            questionText: 'Question?',
            answerText: 'Answer',
            likesCount: 5,
            createdAt: DateTime.now(),
            isAnonymous: false,
          ),
        ];
      final cubit = ContentSearchCubit(repository);

      await cubit.search('test');

      expect(cubit.state, isA<ContentSearchLoaded>());
      final loaded = cubit.state as ContentSearchLoaded;
      expect(loaded.results, hasLength(1));
      expect(loaded.results.first.questionText, 'Question?');
      expect(repository.searchContentCalled, isTrue);
      expect(repository.lastContentQuery, 'test');

      cubit.close();
    });

    test('search emits failure on error', () async {
      final repository = _FakeSearchRepository()..shouldFail = true;
      final cubit = ContentSearchCubit(repository);

      await cubit.search('query');

      expect(cubit.state, isA<ContentSearchFailure>());
      final failure = cubit.state as ContentSearchFailure;
      expect(failure.message, contains('search failed'));

      cubit.close();
    });

    test('search with empty query emits loaded with empty list', () async {
      final repository = _FakeSearchRepository();
      final cubit = ContentSearchCubit(repository);

      await cubit.search('  ');

      expect(cubit.state, isA<ContentSearchLoaded>());
      final loaded = cubit.state as ContentSearchLoaded;
      expect(loaded.results, isEmpty);
      expect(repository.searchContentCalled, isFalse);

      cubit.close();
    });
  });
}
