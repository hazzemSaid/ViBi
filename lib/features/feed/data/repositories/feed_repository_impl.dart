import 'package:dartz/dartz.dart';
import 'package:vibi/features/feed/domain/entities/feed_item.dart';
import 'package:vibi/features/feed/domain/repositories/feed_repository.dart';

class FeedRepositoryImpl implements FeedRepository {
  final FeedRepository _dataSource;

  FeedRepositoryImpl(this._dataSource);

  @override
  Future<Either<String, List<FeedItem>>> getGlobalFeed({
    int limit = 20,
    int offset = 0,
  }) {
    return _dataSource.getGlobalFeed(limit: limit, offset: offset);
  }

  @override
  Future<Either<String, List<FeedItem>>> getFollowingFeed(
    String userId, {
    int limit = 20,
    int offset = 0,
  }) {
    return _dataSource.getFollowingFeed(userId, limit: limit, offset: offset);
  }
}
