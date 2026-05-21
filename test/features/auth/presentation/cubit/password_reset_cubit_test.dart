import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vibi/features/auth/domain/repositories/auth_repository.dart';
import 'package:vibi/features/auth/presentation/cubit/password_reset_cubit.dart';

class _MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late _MockAuthRepository mockRepository;
  late PasswordResetCubit cubit;

  setUp(() {
    mockRepository = _MockAuthRepository();
    cubit = PasswordResetCubit(mockRepository);
  });

  tearDown(() async {
    await cubit.close();
  });

  group('PasswordResetCubit', () {
    test('initial state is AuthActionInitial', () {
      expect(cubit.state, const AuthActionInitial());
    });

    test('sendResetEmail emits success on success', () async {
      when(() => mockRepository.resetPasswordForEmail(any()))
          .thenAnswer((_) async => const Right(null));

      await cubit.sendResetEmail('test@example.com');
      await Future<void>.delayed(Duration.zero);

      expect(cubit.state, isA<AuthActionSuccess>());
    });

    test('sendResetEmail emits failure on error', () async {
      when(() => mockRepository.resetPasswordForEmail(any()))
          .thenAnswer((_) async => Left('Email not found'));

      await cubit.sendResetEmail('unknown@example.com');
      await Future<void>.delayed(Duration.zero);

      expect(cubit.state, isA<AuthActionFailure>());
    });

    test('updatePassword emits success on success', () async {
      when(() => mockRepository.updatePassword(any()))
          .thenAnswer((_) async => const Right(null));

      await cubit.updatePassword('newPassword123');
      await Future<void>.delayed(Duration.zero);

      expect(cubit.state, isA<AuthActionSuccess>());
    });

    test('updatePassword emits failure on error', () async {
      when(() => mockRepository.updatePassword(any()))
          .thenAnswer((_) async => Left('Update failed'));

      await cubit.updatePassword('weak');
      await Future<void>.delayed(Duration.zero);

      expect(cubit.state, isA<AuthActionFailure>());
    });

    test('verifyResetOtp emits success on success', () async {
      when(() => mockRepository.verifyOtp(any(), any(), AuthOtpType.recovery))
          .thenAnswer((_) async => const Right(null));

      await cubit.verifyResetOtp('test@example.com', '12345678');
      await Future<void>.delayed(Duration.zero);

      expect(cubit.state, isA<AuthActionSuccess>());
    });

    test('verifyResetOtp emits failure on error', () async {
      when(() => mockRepository.verifyOtp(any(), any(), AuthOtpType.recovery))
          .thenAnswer((_) async => Left('Invalid code'));

      await cubit.verifyResetOtp('test@example.com', '00000000');
      await Future<void>.delayed(Duration.zero);

      expect(cubit.state, isA<AuthActionFailure>());
    });
  });
}
