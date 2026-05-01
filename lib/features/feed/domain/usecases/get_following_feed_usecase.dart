import 'package:dartz/dartz.dart';
import 'package:vibi/features/feed/domain/entities/feed_item.dart';
import 'package:vibi/features/feed/domain/repositories/feed_repository.dart';

class GetFollowingFeedUseCase {
  final FeedRepository _repository;

  const GetFollowingFeedUseCase(this._repository);

  Future<Either<String, List<FeedItem>>> call(
    String userId, {
    required int limit,
    required int offset,
  }) {
    return _repository.getFollowingFeed(userId, limit: limit, offset: offset);
  }
}
