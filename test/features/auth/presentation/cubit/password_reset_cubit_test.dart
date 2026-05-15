import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vibi/features/auth/domain/entities/app_user.dart';
import 'package:vibi/features/auth/domain/repositories/auth_repository.dart';
import 'package:vibi/features/auth/presentation/cubit/password_reset_cubit.dart';

class _FakeAuthRepository implements AuthRepository {
  bool resetPasswordCalled = false;
  bool updatePasswordCalled = false;
  String? lastEmail;
  String? lastPassword;
  bool shouldFail = false;
  String errorMessage = 'operation failed';

  @override
  Stream<AppUser?> get authStateChanges => Stream.value(null);

  @override
  Future<Either<String, AppUser>> signInWithEmailPassword(
    String email,
    String password,
  ) async =>
      Right(AppUser(id: 'mock-id', email: email));

  @override
  Future<Either<String, AppUser>> signUpWithEmailPassword(
    String email,
    String password, {
    Map<String, dynamic>? data,
  }) async =>
      Right(AppUser(id: 'mock-id', email: email));

  @override
  Future<Either<String, AppUser>> signInWithGoogle() async =>
      Right(AppUser(id: 'mock-google-id', email: 'google@test.com'));

  @override
  Future<Either<String, AppUser>> signInAnonymously() async =>
      Right(AppUser(id: 'mock-anon-id', email: '', isAnonymous: true));

  @override
  Future<Either<String, void>> signOut() async => const Right(null);

  @override
  Future<Either<String, void>> sendEmailVerification() async =>
      const Right(null);

  @override
  Future<Either<String, void>> reloadUser() async => const Right(null);

  @override
  Future<Either<String, void>> resetPasswordForEmail(String email) async {
    resetPasswordCalled = true;
    lastEmail = email;
    if (shouldFail) {
      return Left(errorMessage);
    }
    return const Right(null);
  }

  @override
  Future<Either<String, void>> updatePassword(String newPassword) async {
    updatePasswordCalled = true;
    lastPassword = newPassword;
    if (shouldFail) {
      return Left(errorMessage);
    }
    return const Right(null);
  }
}

void main() {
  late _FakeAuthRepository fakeRepository;
  late PasswordResetCubit controller;

  setUp(() {
    fakeRepository = _FakeAuthRepository();
    controller = PasswordResetCubit(fakeRepository);
  });

  tearDown(() async {
    await controller.close();
  });

  group('PasswordResetCubit', () {
    test('initial state is initial', () {
      expect(controller.state, isA<AuthActionInitial>());
    });

    group('sendResetEmail', () {
      test('emits success and calls repository', () async {
        await controller.sendResetEmail('test@example.com');
        await Future<void>.delayed(Duration.zero);

        expect(controller.state, isA<AuthActionSuccess>());
        expect(fakeRepository.resetPasswordCalled, isTrue);
        expect(fakeRepository.lastEmail, 'test@example.com');
      });

      test('emits failure when repository fails', () async {
        fakeRepository.shouldFail = true;
        fakeRepository.errorMessage = 'Reset password failed';

        await controller.sendResetEmail('test@example.com');
        await Future<void>.delayed(Duration.zero);

        expect(controller.state, isA<AuthActionFailure>());
        final failure = controller.state as AuthActionFailure;
        expect(failure.message, contains('Reset password failed'));
      });
    });

    group('updatePassword', () {
      test('emits success and calls repository', () async {
        await controller.updatePassword('NewStrongPass123!');
        await Future<void>.delayed(Duration.zero);

        expect(controller.state, isA<AuthActionSuccess>());
        expect(fakeRepository.updatePasswordCalled, isTrue);
        expect(fakeRepository.lastPassword, 'NewStrongPass123!');
      });

      test('emits failure when repository fails', () async {
        fakeRepository.shouldFail = true;
        fakeRepository.errorMessage = 'Update password failed';

        await controller.updatePassword('NewStrongPass123!');
        await Future<void>.delayed(Duration.zero);

        expect(controller.state, isA<AuthActionFailure>());
        final failure = controller.state as AuthActionFailure;
        expect(failure.message, contains('Update password failed'));
      });
    });
  });
}
