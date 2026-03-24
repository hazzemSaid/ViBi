// import 'dart:async';

// import 'package:flutter_test/flutter_test.dart';
// import 'package:vibi/core/di/service_locator.dart';
// import 'package:vibi/features/auth/domain/entities/app_user.dart';
// import 'package:vibi/features/auth/domain/repositories/auth_repository.dart';
// import 'package:vibi/features/auth/presentation/controllers/auth_controller.dart';

// /// A Mock wrapper around AuthRepository.
// /// This allows us to test the auth features (like AuthController) independently
// /// from Firebase or any other concrete backend we might plug in later.
// class MockAuthRepository implements AuthRepository {
//   bool signInCalled = false;
//   bool signUpCalled = false;
//   bool signOutCalled = false;
//   bool signInWithGoogleCalled = false;
//   String? lastUsedEmail;

//   @override
//   Stream<AppUser?> get authStateChanges => Stream.value(null);

//   @override
//   Future<AppUser> signInWithEmailPassword(String email, String password) async {
//     signInCalled = true;
//     lastUsedEmail = email;
//     return AppUser(id: 'mock-id-123', email: email);
//   }

//   @override
//   Future<AppUser> signUpWithEmailPassword(
//     String email,
//     String password, {
//     Map<String, dynamic>? data,
//   }) async {
//     signUpCalled = true;
//     lastUsedEmail = email;
//     return AppUser(id: 'mock-id-123', email: email);
//   }

//   @override
//   Future<AppUser> signInWithGoogle() async {
//     signInWithGoogleCalled = true;
//     return AppUser(id: 'mock-google-id', email: 'google@test.com');
//   }

//   @override
//   Future<void> signOut() async {
//     signOutCalled = true;
//   }

//   @override
//   Future<void> sendEmailVerification() async {
//     // Mock implementation for sending email
//   }

//   @override
//   Future<void> reloadUser() async {
//     // Mock implementation for reloading user
//   }
// }

// void main() {
//   late MockAuthRepository mockRepository;
//   late AuthController controller;

//   setUp(() {
//     mockRepository = MockAuthRepository();
//     if (getIt.isRegistered<AuthRepository>()) {
//       getIt.unregister<AuthRepository>();
//     }
//     getIt.registerSingleton<AuthRepository>(mockRepository);
//     controller = AuthController();
//   });

//   tearDown(() async {
//     await controller.close();
//     if (getIt.isRegistered<AuthRepository>()) {
//       getIt.unregister<AuthRepository>();
//     }
//   });

//   group('AuthController Tests', () {
//     test('initial state is not loading', () {
//       final state = controller.state;
//       expect(state.isLoading, false);
//     });

//     test(
//       'signInWithEmail updates state to loading and calls repository',
//       () async {
//         final future = controller.signInWithEmail(
//           'test@example.com',
//           'password123',
//         );

//         // Should immediately go into loading state during execution
//         expect(controller.state.isLoading, true);

//         await future;

//         // Loading is finished
//         expect(controller.state.isLoading, false);

//         // Verification that the repository was called properly
//         expect(mockRepository.signInCalled, true);
//         expect(mockRepository.lastUsedEmail, 'test@example.com');
//       },
//     );

//     test('signUpWithEmail calls repository correctly', () async {
//       await controller.signUpWithEmail('new@example.com', 'password123');

//       expect(mockRepository.signUpCalled, true);
//       expect(mockRepository.lastUsedEmail, 'new@example.com');
//     });

//     test('signInWithGoogle calls repository correctly', () async {
//       await controller.signInWithGoogle();

//       expect(mockRepository.signInWithGoogleCalled, true);
//     });

//     test('signOut calls repository correctly', () async {
//       await controller.signOut();

//       expect(mockRepository.signOutCalled, true);
//     });
//   });
// }
