import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vibi/features/auth/domain/entities/app_user.dart';
import 'package:vibi/features/auth/domain/repositories/auth_repository.dart';
import 'package:vibi/features/auth/presentation/cubit/anonymous_auth_cubit.dart';

class _FakeAuthRepository implements AuthRepository {
  bool signInAnonymouslyCalled = false;
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
  Future<Either<String, AppUser>> signInAnonymously() async {
    signInAnonymouslyCalled = true;
    if (shouldFail) {
      return Left(errorMessage);
    }
    return Right(AppUser(id: 'mock-anon-id', email: '', isAnonymous: true));
  }

  @override
  Future<Either<String, void>> signOut() async => const Right(null);

  @override
  Future<Either<String, void>> sendEmailVerification() async =>
      const Right(null);

  @override
  Future<Either<String, void>> reloadUser() async => const Right(null);

  @override
  Future<Either<String, void>> resetPasswordForEmail(String email) async =>
      const Right(null);

  @override
  Future<Either<String, void>> updatePassword(String newPassword) async =>
      const Right(null);
}

void main() {
  late _FakeAuthRepository fakeRepository;
  late AnonymousAuthCubit controller;

  setUp(() {
    fakeRepository = _FakeAuthRepository();
    controller = AnonymousAuthCubit(fakeRepository);
  });

  tearDown(() async {
    await controller.close();
  });

  group('AnonymousAuthCubit', () {
    test('initial state is initial', () {
      expect(controller.state, isA<AuthActionInitial>());
    });

    test('signInAnonymously emits success and calls repository', () async {
      await controller.signInAnonymously();
      await Future<void>.delayed(Duration.zero);

      expect(controller.state, isA<AuthActionSuccess>());
      expect(fakeRepository.signInAnonymouslyCalled, isTrue);
    });

    test('signInAnonymously emits failure when repository fails', () async {
      fakeRepository.shouldFail = true;
      fakeRepository.errorMessage = 'Anonymous sign in failed';

      await controller.signInAnonymously();
      await Future<void>.delayed(Duration.zero);

      expect(controller.state, isA<AuthActionFailure>());
      final failure = controller.state as AuthActionFailure;
      expect(failure.message, contains('Anonymous sign in failed'));
    });
  });
}
