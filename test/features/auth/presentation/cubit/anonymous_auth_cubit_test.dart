import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vibi/features/auth/domain/entities/app_user.dart';
import 'package:vibi/features/auth/domain/repositories/auth_repository.dart';
import 'package:vibi/features/auth/presentation/cubit/anonymous_auth_cubit.dart';

class _MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late _MockAuthRepository mockRepository;
  late AnonymousAuthCubit cubit;

  setUp(() {
    mockRepository = _MockAuthRepository();
    cubit = AnonymousAuthCubit(mockRepository);
  });

  tearDown(() async {
    await cubit.close();
  });

  group('AnonymousAuthCubit', () {
    test('initial state is AuthActionInitial', () {
      expect(cubit.state, const AuthActionInitial());
    });

    test('signInAnonymously emits success on success', () async {
      when(() => mockRepository.signInAnonymously()).thenAnswer(
        (_) async => Right(
          AppUser(id: 'anon-1', email: '', isAnonymous: true),
        ),
      );

      await cubit.signInAnonymously();
      await Future<void>.delayed(Duration.zero);

      expect(cubit.state, isA<AuthActionSuccess>());
    });

    test('signInAnonymously emits failure on error', () async {
      when(() => mockRepository.signInAnonymously())
          .thenAnswer((_) async => Left('Anonymous sign-in failed'));

      await cubit.signInAnonymously();
      await Future<void>.delayed(Duration.zero);

      expect(cubit.state, isA<AuthActionFailure>());
    });
  });
}
