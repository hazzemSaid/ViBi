import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vibi/features/profile/domain/entities/user_profile.dart';
import 'package:vibi/features/profile/domain/usecases/fetch_user_profile_usecase.dart';
import 'package:vibi/features/profile/domain/usecases/update_user_profile_usecase.dart';
import 'package:vibi/features/profile/domain/usecases/upload_profile_image_usecase.dart';
import 'package:vibi/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:vibi/features/profile/presentation/cubit/profile_state.dart';

class _FakeFetchUserProfileUseCase implements FetchUserProfileUseCase {
  bool callCalled = false;
  String? lastUid;
  bool shouldFail = false;
  String errorMessage = 'fetch failed';
  UserProfile? profileToReturn;

  @override
  Future<Either<String, UserProfile>> call(String uid) async {
    callCalled = true;
    lastUid = uid;
    if (shouldFail) {
      return Left(errorMessage);
    }
    return Right(
      profileToReturn ??
          UserProfile(
            uid: uid,
            name: 'Test User',
            username: 'testuser',
            followers_count: 0,
            following_count: 0,
            answers_count: 0,
          ),
    );
  }
}

class _FakeUpdateUserProfileUseCase implements UpdateUserProfileUseCase {
  bool callCalled = false;
  UserProfile? lastProfile;
  bool shouldFail = false;
  String errorMessage = 'update failed';

  @override
  Future<Either<String, void>> call(UserProfile profile) async {
    callCalled = true;
    lastProfile = profile;
    if (shouldFail) {
      return Left(errorMessage);
    }
    return Right(null);
  }
}

class _FakeUploadProfileImageUseCase implements UploadProfileImageUseCase {
  bool callCalled = false;
  String? lastUid;
  File? lastImage;
  int? lastSlot;
  bool shouldFail = false;
  String errorMessage = 'upload failed';
  String uploadedUrl = 'https://example.com/image.jpg';

  @override
  Future<Either<String, String>> call(String uid, File image, int slot) async {
    callCalled = true;
    lastUid = uid;
    lastImage = image;
    lastSlot = slot;
    if (shouldFail) {
      return Left(errorMessage);
    }
    return Right(uploadedUrl);
  }
}

void main() {
  group('ProfileCubit', () {
    test('initial state is initial', () {
      final cubit = ProfileCubit(
        _FakeFetchUserProfileUseCase(),
        _FakeUpdateUserProfileUseCase(),
        _FakeUploadProfileImageUseCase(),
      );

      expect(cubit.state, isA<ProfileInitial>());
      expect(cubit.currentProfile, isNull);

      cubit.close();
    });

    test('load emits loaded state on success', () async {
      final fetchUseCase = _FakeFetchUserProfileUseCase();
      final cubit = ProfileCubit(
        fetchUseCase,
        _FakeUpdateUserProfileUseCase(),
        _FakeUploadProfileImageUseCase(),
      );

      final result = await cubit.load('user-1');

      expect(cubit.state, isA<ProfileLoaded>());
      expect(result, isNotNull);
      expect(fetchUseCase.callCalled, isTrue);
      expect(fetchUseCase.lastUid, 'user-1');

      cubit.close();
    });

    test('load emits failure state on error', () async {
      final fetchUseCase = _FakeFetchUserProfileUseCase()..shouldFail = true;
      final cubit = ProfileCubit(
        fetchUseCase,
        _FakeUpdateUserProfileUseCase(),
        _FakeUploadProfileImageUseCase(),
      );

      final result = await cubit.load('user-1');

      expect(cubit.state, isA<ProfileFailure>());
      final failure = cubit.state as ProfileFailure;
      expect(failure.message, 'fetch failed');
      expect(result, isNull);

      cubit.close();
    });

    test('updateProfile emits loaded state on success', () async {
      final updateUseCase = _FakeUpdateUserProfileUseCase();
      final cubit = ProfileCubit(
        _FakeFetchUserProfileUseCase(),
        updateUseCase,
        _FakeUploadProfileImageUseCase(),
      );

      final profile = UserProfile(
        uid: 'user-1',
        name: 'Updated Name',
        username: 'updateduser',
        followers_count: 10,
        following_count: 5,
        answers_count: 3,
      );

      final result = await cubit.updateProfile(profile);

      expect(result, isTrue);
      expect(cubit.state, isA<ProfileLoaded>());
      expect(updateUseCase.callCalled, isTrue);
      expect(updateUseCase.lastProfile, profile);

      cubit.close();
    });

    test('updateProfile emits failure state on error', () async {
      final updateUseCase = _FakeUpdateUserProfileUseCase()..shouldFail = true;
      final cubit = ProfileCubit(
        _FakeFetchUserProfileUseCase(),
        updateUseCase,
        _FakeUploadProfileImageUseCase(),
      );

      final profile = UserProfile(
        uid: 'user-1',
        name: 'Name',
        username: 'user',
        followers_count: 0,
        following_count: 0,
        answers_count: 0,
      );

      final result = await cubit.updateProfile(profile);

      expect(result, isFalse);
      expect(cubit.state, isA<ProfileFailure>());
      final failure = cubit.state as ProfileFailure;
      expect(failure.message, 'update failed');
      expect(failure.profile, profile);

      cubit.close();
    });

    test('updateProfile emits saving state during update', () async {
      final updateUseCase = _FakeUpdateUserProfileUseCase();
      final cubit = ProfileCubit(
        _FakeFetchUserProfileUseCase(),
        updateUseCase,
        _FakeUploadProfileImageUseCase(),
      );
      final states = <ProfileState>[];
      cubit.stream.listen(states.add);

      final profile = UserProfile(
        uid: 'user-1',
        name: 'Name',
        username: 'user',
        followers_count: 0,
        following_count: 0,
        answers_count: 0,
      );

      await cubit.updateProfile(profile);
      await Future<void>.delayed(Duration.zero);

      expect(states.any((s) => s is ProfileSaving), isTrue);
      expect(states.any((s) => s is ProfileLoaded), isTrue);

      cubit.close();
    });

    test('currentProfile returns profile from loaded state', () async {
      final cubit = ProfileCubit(
        _FakeFetchUserProfileUseCase(),
        _FakeUpdateUserProfileUseCase(),
        _FakeUploadProfileImageUseCase(),
      );

      await cubit.load('user-1');

      expect(cubit.currentProfile, isNotNull);
      expect(cubit.currentProfile?.uid, 'user-1');
      expect(cubit.currentProfile?.name, 'Test User');

      cubit.close();
    });

    test('currentProfile returns null from initial state', () {
      final cubit = ProfileCubit(
        _FakeFetchUserProfileUseCase(),
        _FakeUpdateUserProfileUseCase(),
        _FakeUploadProfileImageUseCase(),
      );

      expect(cubit.currentProfile, isNull);

      cubit.close();
    });
  });
}
