import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:vibi/core/state/view_state.dart';
import 'package:vibi/features/auth/domain/entities/app_user.dart';
import 'package:vibi/features/auth/domain/repositories/auth_repository.dart';
import 'package:vibi/features/auth/presentation/controllers/auth_controller.dart';

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
	Future<AppUser> signInWithEmailPassword(String email, String password) async {
		signInCalled = true;
		lastUsedEmail = email;
		if (throwOnSignIn) {
			throw Exception('sign in failed');
		}
		return AppUser(id: 'mock-id-123', email: email);
	}

	@override
	Future<AppUser> signUpWithEmailPassword(
		String email,
		String password, {
		Map<String, dynamic>? data,
	}) async {
		signUpCalled = true;
		lastUsedEmail = email;
		return AppUser(id: 'mock-id-123', email: email);
	}

	@override
	Future<AppUser> signInWithGoogle() async {
		signInWithGoogleCalled = true;
		return AppUser(id: 'mock-google-id', email: 'google@test.com');
	}

	@override
	Future<void> signOut() async {
		signOutCalled = true;
	}

	@override
	Future<void> sendEmailVerification() async {
		sendVerificationCalled = true;
	}

	@override
	Future<void> reloadUser() async {
		reloadUserCalled = true;
	}
}

void main() {
	late _FakeAuthRepository fakeRepository;
	late AuthController controller;

	setUp(() {
		fakeRepository = _FakeAuthRepository();
		controller = AuthController(fakeRepository);
	});

	tearDown(() async {
		await controller.close();
	});

	group('AuthController', () {
		test('initial state is initial', () {
			expect(controller.state.status, ViewStatus.initial);
		});

		test('signInWithEmail emits success and calls repository', () async {
			await controller.signInWithEmail('test@example.com', 'password123');

			expect(controller.state.status, ViewStatus.success);
			expect(fakeRepository.signInCalled, isTrue);
			expect(fakeRepository.lastUsedEmail, 'test@example.com');
		});

		test('signInWithEmail emits failure when repository throws', () async {
			fakeRepository.throwOnSignIn = true;

			await controller.signInWithEmail('test@example.com', 'password123');

			expect(controller.state.status, ViewStatus.failure);
			expect(controller.state.errorMessage, contains('sign in failed'));
		});

		test('signUpWithEmail calls repository correctly', () async {
			await controller.signUpWithEmail('new@example.com', 'password123');

			expect(controller.state.status, ViewStatus.success);
			expect(fakeRepository.signUpCalled, isTrue);
			expect(fakeRepository.lastUsedEmail, 'new@example.com');
		});

		test('signInWithGoogle calls repository correctly', () async {
			await controller.signInWithGoogle();

			expect(controller.state.status, ViewStatus.success);
			expect(fakeRepository.signInWithGoogleCalled, isTrue);
		});

		test('signOut calls repository correctly', () async {
			await controller.signOut();

			expect(controller.state.status, ViewStatus.success);
			expect(fakeRepository.signOutCalled, isTrue);
		});

		test('sendEmailVerification calls repository correctly', () async {
			await controller.sendEmailVerification();

			expect(controller.state.status, ViewStatus.success);
			expect(fakeRepository.sendVerificationCalled, isTrue);
		});

		test('reloadUser calls repository correctly', () async {
			await controller.reloadUser();

			expect(controller.state.status, ViewStatus.success);
			expect(fakeRepository.reloadUserCalled, isTrue);
		});
	});
}
