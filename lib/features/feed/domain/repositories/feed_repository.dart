import 'package:dartz/dartz.dart';
import 'package:vibi/features/feed/domain/entities/feed_item.dart';

abstract class FeedRepository {
  Future<Either<String, List<FeedItem>>> getGlobalFeed({
    int limit = 20,
    int offset = 0,
  });
  Future<Either<String, List<FeedItem>>> getFollowingFeed(
    String userId, {
    int limit = 20,
    int offset = 0,
  });
}
