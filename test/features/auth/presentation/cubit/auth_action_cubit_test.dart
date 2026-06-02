import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vibi/core/services/push_notification_service.dart';
import 'package:vibi/features/auth/domain/entities/app_user.dart';
import 'package:vibi/features/auth/domain/repositories/auth_repository.dart';
import 'package:vibi/features/auth/presentation/cubit/auth_action_cubit.dart';

class _MockAuthRepository extends Mock implements AuthRepository {
  @override
  final Stream<AppUser?> authStateChanges;

  _MockAuthRepository()
    : authStateChanges = Stream.value(
        AppUser(id: 'user-1', email: 'test@test.com'),
      );
}

class _MockPushNotificationService extends Mock
    implements PushNotificationService {}

void main() {
  late _MockAuthRepository mockRepository;
  late _MockPushNotificationService mockNotificationService;
  late AuthActionCubit cubit;

  setUp(() {
    mockRepository = _MockAuthRepository();
    mockNotificationService = _MockPushNotificationService();

    when(() => mockNotificationService.updateUserId(any()))
        .thenAnswer((_) async {});
    when(() => mockNotificationService.clearUserId(any()))
        .thenAnswer((_) async {});

    cubit = AuthActionCubit(mockRepository, mockNotificationService);
  });

  tearDown(() async {
    await cubit.close();
  });

  group('AuthActionCubit', () {
    test('initial state is AuthActionInitial', () {
      expect(cubit.state, const AuthActionInitial());
    });

    test('signInWithEmail emits success and calls repository', () async {
      when(() => mockRepository.signInWithEmailPassword(
            any(),
            any(),
          )).thenAnswer(
        (_) async => Right(
          AppUser(id: 'uid-1', email: 'test@example.com'),
        ),
      );

      await cubit.signInWithEmail('test@example.com', 'password123');
      await Future<void>.delayed(Duration.zero);

      expect(cubit.state, isA<AuthActionSuccess>());
    });

    test('signInWithEmail emits failure when repository returns error',
        () async {
      when(() => mockRepository.signInWithEmailPassword(
            any(),
            any(),
          )).thenAnswer((_) async => Left('Invalid credentials'));

      await cubit.signInWithEmail('test@example.com', 'wrong');
      await Future<void>.delayed(Duration.zero);

      expect(cubit.state, isA<AuthActionFailure>());
      final failure = cubit.state as AuthActionFailure;
      expect(failure.message, contains('Invalid'));
    });

    test('signUpWithEmail calls repository correctly', () async {
      when(() => mockRepository.signUpWithEmailPassword(
            any(),
            any(),
            data: any(named: 'data'),
          )).thenAnswer(
        (_) async => Right(
          AppUser(id: 'uid-2', email: 'new@example.com'),
        ),
      );

      await cubit.signUpWithEmail('new@example.com', 'password123');
      await Future<void>.delayed(Duration.zero);

      expect(cubit.state, isA<AuthActionSuccess>());
    });

    test('signUpWithEmail emits failure on repository error', () async {
      when(() => mockRepository.signUpWithEmailPassword(
            any(),
            any(),
            data: any(named: 'data'),
          )).thenAnswer((_) async => Left('Email already registered'));

      await cubit.signUpWithEmail('existing@example.com', 'password123');
      await Future<void>.delayed(Duration.zero);

      expect(cubit.state, isA<AuthActionFailure>());
    });

    test('signInWithGoogle calls repository correctly', () async {
      when(() => mockRepository.signInWithGoogle()).thenAnswer(
        (_) async => Right(
          AppUser(id: 'google-1', email: 'google@test.com'),
        ),
      );

      await cubit.signInWithGoogle();
      await Future<void>.delayed(Duration.zero);

      expect(cubit.state, isA<AuthActionSuccess>());
    });

    test('signInWithGoogle emits failure on repository error', () async {
      when(() => mockRepository.signInWithGoogle())
          .thenAnswer((_) async => Left('Google sign-in failed'));

      await cubit.signInWithGoogle();
      await Future<void>.delayed(Duration.zero);

      expect(cubit.state, isA<AuthActionFailure>());
    });

    test('signOut calls repository correctly', () async {
      when(() => mockRepository.signOut())
          .thenAnswer((_) async => const Right(null));

      await cubit.signOut();
      await Future<void>.delayed(Duration.zero);

      expect(cubit.state, isA<AuthActionSuccess>());
    });

    test('signOut emits failure on repository error', () async {
      when(() => mockRepository.signOut())
          .thenAnswer((_) async => Left('Sign out failed'));

      await cubit.signOut();
      await Future<void>.delayed(Duration.zero);

      expect(cubit.state, isA<AuthActionFailure>());
    });

    test('sendEmailVerification calls repository correctly', () async {
      when(() => mockRepository.sendEmailVerification())
          .thenAnswer((_) async => const Right(null));

      await cubit.sendEmailVerification();
      await Future<void>.delayed(Duration.zero);

      expect(cubit.state, isA<AuthActionSuccess>());
    });

    test('reloadUser calls repository correctly', () async {
      when(() => mockRepository.reloadUser())
          .thenAnswer((_) async => const Right(null));

      await cubit.reloadUser();
      await Future<void>.delayed(Duration.zero);

      expect(cubit.state, isA<AuthActionSuccess>());
    });

    test('verifyOtp calls repository correctly', () async {
      when(
        () => mockRepository.verifyOtp(any(), any(), AuthOtpType.signup),
      ).thenAnswer((_) async => const Right(null));

      await cubit.verifyOtp('test@test.com', '12345678', AuthOtpType.signup);
      await Future<void>.delayed(Duration.zero);

      expect(cubit.state, isA<AuthActionSuccess>());
    });

    test('verifyOtp emits failure on repository error', () async {
      when(
        () => mockRepository.verifyOtp(any(), any(), AuthOtpType.signup),
      ).thenAnswer((_) async => Left('Invalid OTP'));

      await cubit.verifyOtp('test@test.com', '00000000', AuthOtpType.signup);
      await Future<void>.delayed(Duration.zero);

      expect(cubit.state, isA<AuthActionFailure>());
    });
  });
}
