// lib/services/supabase_error_handler.dart
import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseErrorHandler {
  // Returns a user-readable error message
  static String getErrorMessage(dynamic error) {
    if (error is AuthException) {
      return _handleAuthError(error);
    } else if (error is OperationException) {
      return _handleGraphQLError(error);
    } else if (error is PostgrestException) {
      return _handlePostgrestError(error);
    } else if (error is Exception) {
      return 'An unexpected error occurred: ${error.toString()}';
    } else {
      return 'Something went wrong. Please try again.';
    }
  }

  // Optional: Show a SnackBar (requires BuildContext)
  static void showErrorSnackBar(BuildContext context, dynamic error) {
    final message = getErrorMessage(error);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  static String _handleAuthError(AuthException error) {
    final msg = error.message.toLowerCase();
    if (msg.contains('invalid login credentials')) {
      return 'Invalid email or password.';
    } else if (msg.contains('email not confirmed')) {
      return 'Please verify your email address.';
    } else if (msg.contains('user already registered')) {
      return 'An account with this email already exists.';
    } else if (msg.contains('weak password')) {
      return 'Password is too weak. Use at least 6 characters.';
    } else if (msg.contains('token expired')) {
      return 'Your session has expired. Please log in again.';
    }
    return 'Authentication error: ${error.message}';
  }

  static String _handlePostgrestError(PostgrestException error) {
    switch (error.code) {
      case '23505':
        return 'This record already exists.';
      case '23503':
        return 'This operation references a record that does not exist.';
      case '42P01':
        return 'A technical error occurred. Please contact support.';
      case '42501':
        return 'You do not have permission to perform this action.';
      default:
        return 'Database error: ${error.message}';
    }
  }

  static String _handleGraphQLError(OperationException error) {
    if (error.graphqlErrors.isNotEmpty) {
      final message = error.graphqlErrors.first.message;
      if (message.isNotEmpty) {
        return message;
      }
    }

    final linkMessage = error.linkException?.toString();
    if (linkMessage != null && linkMessage.isNotEmpty) {
      return 'Network error: $linkMessage';
    }

    return 'GraphQL request failed. Please try again.';
  }
}

