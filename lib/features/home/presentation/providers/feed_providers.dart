import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:vibi/features/home/domain/entities/feed_item.dart';
import 'package:vibi/features/home/domain/usecases/get_following_feed_usecase.dart';
import 'package:vibi/features/home/domain/usecases/get_global_feed_usecase.dart';
import 'package:vibi/features/home/presentation/providers/feed_state.dart';

class GlobalFeedCubit extends Cubit<FeedState> {
  GlobalFeedCubit(this._getGlobalFeedUseCase) : super(const FeedLoading()) {
    _fetchInitial();
  }

  final GetGlobalFeedUseCase _getGlobalFeedUseCase;
  int _offset = 0;
  final int _limit = 20;
  bool _hasMore = true;
  bool _isLoadingMore = false;
  final Map<String, int> _itemIndexById = <String, int>{};

  Future<void> refresh() async {
    _offset = 0;
    _hasMore = true;
    _isLoadingMore = false;
    if (isClosed) return;
    emit(const FeedLoading());
    await _fetchInitial();
  }

  bool get hasMore => _hasMore;

  FeedItem? getItemById(String id) {
    final currentState = state;
    if (currentState is! FeedLoaded) return null;

    final index = _itemIndexById[id];
    if (index == null || index < 0 || index >= currentState.items.length) {
      return null;
    }
    return currentState.items[index];
  }

  void _cacheItems(List<FeedItem> items) {
    _itemIndexById.clear();
    for (var i = 0; i < items.length; i++) {
      _itemIndexById[items[i].id] = i;
    }
  }

  void _emitLoaded(List<FeedItem> items) {
    if (isClosed) return;
    _cacheItems(items);
    emit(FeedLoaded(items, hasMore: _hasMore));
  }

  Future<void> _fetchInitial() async {
    try {
      final newItems = await _getGlobalFeedUseCase(limit: _limit, offset: 0);
      _hasMore = newItems.length == _limit;
      _emitLoaded(newItems);
    } catch (e) {
      if (!isClosed) {
        emit(FeedFailure('$e'));
      }
    }
  }

  Future<void> fetchMore() async {
    if (_isLoadingMore || !_hasMore) return;

    _isLoadingMore = true;
    _offset += _limit;

    try {
      final newItems = await _getGlobalFeedUseCase(
        limit: _limit,
        offset: _offset,
      );
      if (newItems.length < _limit) {
        _hasMore = false;
      }
      final currentState = state;
      final currentItems = currentState is FeedLoaded
          ? currentState.items
          : <FeedItem>[];
      _emitLoaded([...currentItems, ...newItems]);
    } catch (e) {
      _offset -= _limit;
    } finally {
      _isLoadingMore = false;
    }
  }

  void patchAnswerCounts({
    required String answerId,
    int? reactionsCount,
    int? commentsCount,
  }) {
    if (isClosed) return;
    final currentState = state;
    if (currentState is! FeedLoaded) return;

    final currentItems = currentState.items;
    if (currentItems.isEmpty) return;

    final index = currentItems.indexWhere((item) => item.id == answerId);
    if (index < 0) return;

    final currentItem = currentItems[index];
    final nextLikesCount = reactionsCount ?? currentItem.likesCount;
    final nextCommentsCount = commentsCount ?? currentItem.commentsCount;

    if (nextLikesCount == currentItem.likesCount &&
        nextCommentsCount == currentItem.commentsCount) {
      return;
    }

    final updatedItems = List<FeedItem>.of(currentItems, growable: false);
    updatedItems[index] = currentItem.copyWith(
      likesCount: nextLikesCount,
      commentsCount: nextCommentsCount,
    );

    _emitLoaded(updatedItems);
  }
}

class FollowingFeedCubit extends Cubit<FeedState> {
  FollowingFeedCubit(this._getFollowingFeedUseCase)
    : super(const FeedLoading()) {
    _fetchInitial();
  }

  final GetFollowingFeedUseCase _getFollowingFeedUseCase;
  int _offset = 0;
  final int _limit = 20;
  bool _hasMore = true;
  bool _isLoadingMore = false;

  Future<void> refresh() async {
    _offset = 0;
    _hasMore = true;
    _isLoadingMore = false;
    if (isClosed) return;
    emit(const FeedLoading());
    await _fetchInitial();
  }

  bool get hasMore => _hasMore;

  Future<void> _fetchInitial() async {
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) {
        if (!isClosed) emit(const FeedLoaded([], hasMore: false));
        return;
      }
      final newItems = await _getFollowingFeedUseCase(
        userId,
        limit: _limit,
        offset: 0,
      );
      _hasMore = newItems.length == _limit;
      if (!isClosed) {
        emit(FeedLoaded(newItems, hasMore: _hasMore));
      }
    } catch (e) {
      if (!isClosed) {
        emit(FeedFailure('$e'));
      }
    }
  }

  Future<void> fetchMore() async {
    if (_isLoadingMore || !_hasMore) return;

    _isLoadingMore = true;
    _offset += _limit;

    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) return;

      final newItems = await _getFollowingFeedUseCase(
        userId,
        limit: _limit,
        offset: _offset,
      );
      if (newItems.length < _limit) {
        _hasMore = false;
      }
      final currentState = state;
      final currentItems = currentState is FeedLoaded
          ? currentState.items
          : <FeedItem>[];
      if (!isClosed) {
        emit(FeedLoaded([...currentItems, ...newItems], hasMore: _hasMore));
      }
    } catch (e) {
      _offset -= _limit;
    } finally {
      _isLoadingMore = false;
    }
  }

  void patchAnswerCounts({
    required String answerId,
    int? reactionsCount,
    int? commentsCount,
  }) {
    if (isClosed) return;
    final currentState = state;
    if (currentState is! FeedLoaded) return;

    final currentItems = currentState.items;
    if (currentItems.isEmpty) return;

    final index = currentItems.indexWhere((item) => item.id == answerId);
    if (index < 0) return;

    final currentItem = currentItems[index];
    final nextLikesCount = reactionsCount ?? currentItem.likesCount;
    final nextCommentsCount = commentsCount ?? currentItem.commentsCount;

    if (nextLikesCount == currentItem.likesCount &&
        nextCommentsCount == currentItem.commentsCount) {
      return;
    }

    final updatedItems = List<FeedItem>.of(currentItems, growable: false);
    updatedItems[index] = currentItem.copyWith(
      likesCount: nextLikesCount,
      commentsCount: nextCommentsCount,
    );

    emit(FeedLoaded(updatedItems, hasMore: _hasMore));
  }
}
