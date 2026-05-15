import 'package:flutter_test/flutter_test.dart';
import 'package:vibi/features/auth/presentation/helpers/auth_validators.dart';

void main() {
  group('AuthValidators', () {
    group('email', () {
      test('returns error when null', () {
        final result = AuthValidators.email(null);
        expect(result, 'Email is required');
      });

      test('returns error when empty', () {
        final result = AuthValidators.email('');
        expect(result, 'Email is required');
      });

      test('returns error when whitespace only', () {
        final result = AuthValidators.email('   ');
        expect(result, 'Email is required');
      });

      test('returns error when invalid format', () {
        expect(AuthValidators.email('notanemail'), isNotNull);
        expect(AuthValidators.email('missing@domain'), isNotNull);
        expect(AuthValidators.email('@missing.com'), isNotNull);
      });

      test('returns null when valid email', () {
        expect(AuthValidators.email('test@example.com'), isNull);
        expect(AuthValidators.email('user.name+tag@domain.co.uk'), isNull);
        expect(AuthValidators.email('  test@example.com  '), isNull);
      });
    });

    group('password', () {
      test('returns error when null', () {
        final result = AuthValidators.password(null);
        expect(result, 'Password is required');
      });

      test('returns error when empty', () {
        final result = AuthValidators.password('');
        expect(result, 'Password is required');
      });

      test('returns error when less than 6 characters', () {
        expect(AuthValidators.password('12345'), isNotNull);
        expect(AuthValidators.password('abc'), isNotNull);
      });

      test('returns null when 6 or more characters', () {
        expect(AuthValidators.password('123456'), isNull);
        expect(AuthValidators.password('password'), isNull);
        expect(AuthValidators.password('StrongPass123!'), isNull);
      });
    });

    group('confirmPassword', () {
      test('returns error when null', () {
        final result = AuthValidators.confirmPassword(null, 'password');
        expect(result, 'Please confirm your password');
      });

      test('returns error when empty', () {
        final result = AuthValidators.confirmPassword('', 'password');
        expect(result, 'Please confirm your password');
      });

      test('returns error when passwords do not match', () {
        final result = AuthValidators.confirmPassword('different', 'password');
        expect(result, 'Passwords do not match');
      });

      test('returns null when passwords match', () {
        expect(AuthValidators.confirmPassword('password', 'password'), isNull);
        expect(AuthValidators.confirmPassword('Test123!', 'Test123!'), isNull);
      });
    });

    group('name', () {
      test('returns error when null', () {
        final result = AuthValidators.name(null);
        expect(result, 'Name is required');
      });

      test('returns error when empty', () {
        final result = AuthValidators.name('');
        expect(result, 'Name is required');
      });

      test('returns error when whitespace only', () {
        final result = AuthValidators.name('   ');
        expect(result, 'Name is required');
      });

      test('returns error when less than 2 characters', () {
        expect(AuthValidators.name('A'), isNotNull);
        expect(AuthValidators.name(' A '), isNotNull);
      });

      test('returns null when 2 or more characters', () {
        expect(AuthValidators.name('Ab'), isNull);
        expect(AuthValidators.name('John Doe'), isNull);
        expect(AuthValidators.name('  John  '), isNull);
      });
    });
  });
}
