import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vibi/core/services/push_notification_service.dart';
import 'package:vibi/features/auth/domain/entities/app_user.dart';
import 'package:vibi/features/auth/domain/repositories/auth_repository.dart';
import 'package:vibi/features/auth/presentation/cubit/auth_action_cubit.dart';

class _FakeAuthRepository implements AuthRepository {
  bool signInCalled = false;
  bool signUpCalled = false;
  bool signOutCalled = false;
  bool signInWithGoogleCalled = false;
  bool sendVerificationCalled = false;
  bool reloadUserCalled = false;
  bool throwOnSignIn = false;
  String? lastUsedEmail;

  @override
  Stream<AppUser?> get authStateChanges => Stream.value(null);

  @override
  Future<Either<String, AppUser>> signInWithEmailPassword(
    String email,
    String password,
  ) async {
    signInCalled = true;
    lastUsedEmail = email;
    if (throwOnSignIn) {
      return Left('sign in failed');
    }
    return Right(AppUser(id: 'mock-id-123', email: email));
  }

  @override
  Future<Either<String, AppUser>> signUpWithEmailPassword(
    String email,
    String password, {
    Map<String, dynamic>? data,
  }) async {
    signUpCalled = true;
    lastUsedEmail = email;
    return Right(AppUser(id: 'mock-id-123', email: email));
  }

  @override
  Future<Either<String, AppUser>> signInWithGoogle() async {
    signInWithGoogleCalled = true;
    return Right(AppUser(id: 'mock-google-id', email: 'google@test.com'));
  }

  @override
  Future<Either<String, void>> signOut() async {
    signOutCalled = true;
    return Right(null);
  }

  @override
  Future<Either<String, void>> sendEmailVerification() async {
    sendVerificationCalled = true;
    return Right(null);
  }

  @override
  Future<Either<String, void>> reloadUser() async {
    reloadUserCalled = true;
    return Right(null);
  }
}

class _MockPushNotificationService extends Mock
    implements PushNotificationService {}

void main() {
  late _FakeAuthRepository fakeRepository;
  late _MockPushNotificationService mockNotificationService;
  late AuthActionCubit controller;

  setUp(() {
    fakeRepository = _FakeAuthRepository();
    mockNotificationService = _MockPushNotificationService();
    when(
      () => mockNotificationService.updateUserId(any()),
    ).thenAnswer((_) async {});
    when(
      () => mockNotificationService.clearUserId(any()),
    ).thenAnswer((_) async {});
    controller = AuthActionCubit(fakeRepository, mockNotificationService);
  });

  tearDown(() async {
    await controller.close();
  });

  group('AuthActionCubit', () {
    test('initial state is initial', () {
      expect(controller.state, isA<AuthActionInitial>());
    });

    test('signInWithEmail emits success and calls repository', () async {
      await controller.signInWithEmail('test@example.com', 'password123');
      await Future<void>.delayed(Duration.zero);

      expect(controller.state, isA<AuthActionSuccess>());
      expect(fakeRepository.signInCalled, isTrue);
      expect(fakeRepository.lastUsedEmail, 'test@example.com');
    });

    test('signInWithEmail emits failure when repository throws', () async {
      fakeRepository.throwOnSignIn = true;

      await controller.signInWithEmail('test@example.com', 'password123');
      await Future<void>.delayed(Duration.zero);

      expect(controller.state, isA<AuthActionFailure>());
      final failure = controller.state as AuthActionFailure;
      expect(failure.message, contains('sign in failed'));
    });

    test('signUpWithEmail calls repository correctly', () async {
      await controller.signUpWithEmail('new@example.com', 'password123');
      await Future<void>.delayed(Duration.zero);

      expect(controller.state, isA<AuthActionSuccess>());
      expect(fakeRepository.signUpCalled, isTrue);
      expect(fakeRepository.lastUsedEmail, 'new@example.com');
    });

    test('signInWithGoogle calls repository correctly', () async {
      await controller.signInWithGoogle();
      await Future<void>.delayed(Duration.zero);

      expect(controller.state, isA<AuthActionSuccess>());
      expect(fakeRepository.signInWithGoogleCalled, isTrue);
    });

    test('signOut calls repository correctly', () async {
      await controller.signOut();
      await Future<void>.delayed(Duration.zero);

      expect(controller.state, isA<AuthActionSuccess>());
      expect(fakeRepository.signOutCalled, isTrue);
    });

    test('sendEmailVerification calls repository correctly', () async {
      await controller.sendEmailVerification();
      await Future<void>.delayed(Duration.zero);

      expect(controller.state, isA<AuthActionSuccess>());
      expect(fakeRepository.sendVerificationCalled, isTrue);
    });

    test('reloadUser calls repository correctly', () async {
      await controller.reloadUser();
      await Future<void>.delayed(Duration.zero);

      expect(controller.state, isA<AuthActionSuccess>());
      expect(fakeRepository.reloadUserCalled, isTrue);
    });
  });
}
