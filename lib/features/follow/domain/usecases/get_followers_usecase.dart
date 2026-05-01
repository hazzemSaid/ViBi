import 'package:dartz/dartz.dart';
import 'package:vibi/features/follow/domain/entities/follower_user.dart';
import 'package:vibi/features/follow/domain/repositories/follow_repository.dart';

class GetFollowersUseCase {
  final FollowRepository followRepository;

  GetFollowersUseCase(this.followRepository);

  Future<Either<String, List<FollowerUser>>> call(String userId) async {
    return followRepository.getFollowers(userId);
  }
}
