import 'package:vibi/features/home/data/datasources/feed_data_source_interface.dart';
import 'package:vibi/features/home/domain/entities/feed_item.dart';
import 'package:vibi/features/home/domain/repositories/feed_repository.dart';

class FeedRepositoryImpl implements FeedRepository {
  final FeedDataSource _dataSource;

  FeedRepositoryImpl(this._dataSource);

  @override
  Future<List<FeedItem>> getGlobalFeed({int limit = 20, int offset = 0}) {
    return _dataSource.getGlobalFeed(limit: limit, offset: offset);
  }

  @override
  Future<List<FeedItem>> getFollowingFeed(
    String userId, {
    int limit = 20,
    int offset = 0,
  }) {
    return _dataSource.getFollowingFeed(userId, limit: limit, offset: offset);
  }
}
