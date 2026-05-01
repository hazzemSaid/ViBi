import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vibi/features/feed/domain/entities/feed_item.dart';
import 'package:vibi/features/feed/domain/usecases/get_global_feed_usecase.dart';
import 'package:vibi/features/feed/presentation/cubit/feed_cubit.dart';
import 'package:vibi/features/feed/presentation/cubit/feed_state.dart';

class _FakeGetGlobalFeedUseCase implements GetGlobalFeedUseCase {
  bool callCalled = false;
  int? lastLimit;
  int? lastOffset;
  bool shouldFail = false;
  List<FeedItem> itemsToReturn = [];
  String errorMessage = 'feed failed';

  @override
  Future<Either<String, List<FeedItem>>> call({
    int limit = 20,
    int offset = 0,
  }) async {
    callCalled = true;
    lastLimit = limit;
    lastOffset = offset;
    if (shouldFail) {
      return Left(errorMessage);
    }
    return Right(itemsToReturn);
  }
}

FeedItem _makeFeedItem({required String id}) {
  return FeedItem(
    id: id,
    userId: 'user-1',
    username: 'user',
    answerAuthorUsername: 'user',
    questionText: 'Question?',
    answerText: 'Answer',
    likesCount: 0,
    commentsCount: 0,
    sharesCount: 0,
    createdAt: DateTime.now(),
    isAnonymous: false,
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('GlobalFeedCubit', () {
    test('initial state is loading', () {
      final useCase = _FakeGetGlobalFeedUseCase();
      final cubit = GlobalFeedCubit(useCase);

      expect(cubit.state, isA<FeedLoading>());

      cubit.close();
    });

    test('emits loaded state with items on success', () async {
      final useCase = _FakeGetGlobalFeedUseCase()
        ..itemsToReturn = [
          _makeFeedItem(id: 'item-1'),
          _makeFeedItem(id: 'item-2'),
        ];
      final cubit = GlobalFeedCubit(useCase);
      await Future<void>.delayed(Duration.zero);

      expect(cubit.state, isA<FeedLoaded>());
      final loaded = cubit.state as FeedLoaded;
      expect(loaded.items, hasLength(2));
      expect(loaded.hasMore, isFalse);

      cubit.close();
    });

    test('emits failure state on error', () async {
      final useCase = _FakeGetGlobalFeedUseCase()..shouldFail = true;
      final cubit = GlobalFeedCubit(useCase);
      await Future<void>.delayed(Duration.zero);

      expect(cubit.state, isA<FeedFailure>());
      final failure = cubit.state as FeedFailure;
      expect(failure.message, 'feed failed');

      cubit.close();
    });

    test('refresh resets pagination and fetches again', () async {
      final useCase = _FakeGetGlobalFeedUseCase()
        ..itemsToReturn = [_makeFeedItem(id: 'item-1')];
      final cubit = GlobalFeedCubit(useCase);
      await Future<void>.delayed(Duration.zero);

      expect(useCase.callCalled, isTrue);
      expect(useCase.lastOffset, 0);

      useCase.callCalled = false;
      await cubit.refresh();
      await Future<void>.delayed(Duration.zero);

      expect(useCase.callCalled, isTrue);
      expect(useCase.lastOffset, 0);

      cubit.close();
    });

    test('patchAnswerCounts updates item counts locally', () async {
      final useCase = _FakeGetGlobalFeedUseCase()
        ..itemsToReturn = [
          _makeFeedItem(id: 'item-1'),
          _makeFeedItem(id: 'item-2'),
        ];
      final cubit = GlobalFeedCubit(useCase);
      await Future<void>.delayed(Duration.zero);

      cubit.patchAnswerCounts(
        answerId: 'item-1',
        reactionsCount: 10,
        commentsCount: 5,
      );

      expect(cubit.state, isA<FeedLoaded>());
      final loaded = cubit.state as FeedLoaded;
      final updatedItem = loaded.items.firstWhere((i) => i.id == 'item-1');
      expect(updatedItem.likesCount, 10);
      expect(updatedItem.commentsCount, 5);

      cubit.close();
    });

    test('getItemById returns correct item', () async {
      final useCase = _FakeGetGlobalFeedUseCase()
        ..itemsToReturn = [
          _makeFeedItem(id: 'item-1'),
          _makeFeedItem(id: 'item-2'),
        ];
      final cubit = GlobalFeedCubit(useCase);
      await Future<void>.delayed(Duration.zero);

      final item = cubit.getItemById('item-2');
      expect(item, isNotNull);
      expect(item?.id, 'item-2');

      cubit.close();
    });

    test('getItemById returns null for non-existent item', () async {
      final useCase = _FakeGetGlobalFeedUseCase()
        ..itemsToReturn = [_makeFeedItem(id: 'item-1')];
      final cubit = GlobalFeedCubit(useCase);
      await Future<void>.delayed(Duration.zero);

      final item = cubit.getItemById('non-existent');
      expect(item, isNull);

      cubit.close();
    });
  });
}
