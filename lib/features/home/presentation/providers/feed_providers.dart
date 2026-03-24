import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:vibi/core/di/service_locator.dart';
import 'package:vibi/core/state/view_state.dart';
import 'package:vibi/features/home/domain/entities/feed_item.dart';
import 'package:vibi/features/home/domain/repositories/feed_repository.dart';

class GlobalFeedCubit extends Cubit<ViewState<List<FeedItem>>> {
  GlobalFeedCubit(this._repository) : super(const ViewState(status: ViewStatus.loading)) {
    _fetchInitial();
  }

  final FeedRepository _repository;
  int _offset = 0;
  final int _limit = 20;
  bool _hasMore = true;
  bool _isLoadingMore = false;

  Future<void> refresh() async {
    _offset = 0;
    _hasMore = true;
    _isLoadingMore = false;
    emit(const ViewState(status: ViewStatus.loading));
    await _fetchInitial();
  }

  bool get hasMore => _hasMore;

  Future<void> _fetchInitial() async {
    try {
      final newItems = await _repository.getGlobalFeed(limit: _limit, offset: 0);
      _hasMore = newItems.length == _limit;
      emit(ViewState(status: ViewStatus.success, data: newItems));
    } catch (e) {
      emit(ViewState(status: ViewStatus.failure, errorMessage: '$e'));
    }
  }

  Future<void> fetchMore() async {
    if (_isLoadingMore || !_hasMore) return;
    
    _isLoadingMore = true;
    _offset += _limit;
    
    try {
      final newItems = await _repository.getGlobalFeed(limit: _limit, offset: _offset);
      if (newItems.length < _limit) {
        _hasMore = false;
      }
      final currentItems = state.data ?? [];
      emit(ViewState(status: ViewStatus.success, data: [...currentItems, ...newItems]));
    } catch (e) {
      _offset -= _limit;
    } finally {
      _isLoadingMore = false;
    }
  }
}

class FollowingFeedCubit extends Cubit<ViewState<List<FeedItem>>> {
  FollowingFeedCubit(this._repository) : super(const ViewState(status: ViewStatus.loading)) {
    _fetchInitial();
  }

  final FeedRepository _repository;
  int _offset = 0;
  final int _limit = 20;
  bool _hasMore = true;
  bool _isLoadingMore = false;
  
  Future<void> refresh() async {
    _offset = 0;
    _hasMore = true;
    _isLoadingMore = false;
    emit(const ViewState(status: ViewStatus.loading));
    await _fetchInitial();
  }

  bool get hasMore => _hasMore;

  Future<void> _fetchInitial() async {
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) {
        emit(const ViewState(status: ViewStatus.success, data: []));
        return;
      }
      final newItems = await _repository.getFollowingFeed(userId, limit: _limit, offset: 0);
      _hasMore = newItems.length == _limit;
      emit(ViewState(status: ViewStatus.success, data: newItems));
    } catch (e) {
      emit(ViewState(status: ViewStatus.failure, errorMessage: '$e'));
    }
  }

  Future<void> fetchMore() async {
    if (_isLoadingMore || !_hasMore) return;
    
    _isLoadingMore = true;
    _offset += _limit;
    
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) return;
      
      final newItems = await _repository.getFollowingFeed(userId, limit: _limit, offset: _offset);
      if (newItems.length < _limit) {
        _hasMore = false;
      }
      final currentItems = state.data ?? [];
      emit(ViewState(status: ViewStatus.success, data: [...currentItems, ...newItems]));
    } catch (e) {
      _offset -= _limit;
    } finally {
      _isLoadingMore = false;
    }
  }
}

FeedRepository get feedRepository => getIt<FeedRepository>();
