import 'dart:async';
import 'dart:io';

import 'package:ferry/ferry.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseErrorHandler {
  /// Returns a user-friendly error message based on the error type and content.
  static String getErrorMessage(dynamic error) {
    if (error is AuthException) {
      return _handleAuthError(error);
    } else if (error is OperationResponse) {
      return _handleFerryError(error);
    } else if (error is PostgrestException) {
      return _handlePostgrestError(error);
    } else if (error is SocketException) {
      return 'No internet connection. Please check your network and try again.';
    } else if (error is TimeoutException) {
      return 'The request timed out. Please check your connection or try again later.';
    } else if (error is Exception) {
      final msg = error.toString().toLowerCase();
      if (msg.contains('socketexception')) {
        return 'Connection error. Please check your internet.';
      }
      return 'An unexpected error occurred: ${error.toString().split(':').last.trim()}';
    } else if (error is String) {
      return error;
    } else {
      return 'Something went wrong. Please try again.';
    }
  }

  /// Logs the error to console and provides a hook for future integration 
  /// with services like Sentry or Firebase Crashlytics.
  static void logError(dynamic error, [StackTrace? stackTrace]) {
    debugPrint('--- [APP ERROR LOG] ---');
    debugPrint('Timestamp: ${DateTime.now()}');
    debugPrint('Error: $error');
    if (stackTrace != null) {
      debugPrint('StackTrace: $stackTrace');
    }
    debugPrint('-----------------------');
  }

  /// Shows a styled SnackBar with the error message.
  static void showErrorSnackBar(BuildContext context, dynamic error) {
    final message = getErrorMessage(error);
    logError(error);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Theme.of(context).colorScheme.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  /// Shows an Error Dialog for more critical or disruptive errors.
  static Future<void> showErrorDialog(BuildContext context, {
    required dynamic error,
    String? title,
    VoidCallback? onRetry,
  }) {
    final message = getErrorMessage(error);
    logError(error);

    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title ?? 'Something Went Wrong'),
        content: Text(message),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
          if (onRetry != null)
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                onRetry();
              },
              child: const Text('Try Again'),
            ),
        ],
      ),
    );
  }

  static String _handleAuthError(AuthException error) {
    final msg = error.message.toLowerCase();
    if (msg.contains('invalid login credentials')) {
      return 'The email or password you entered is incorrect.';
    } else if (msg.contains('email not confirmed')) {
      return 'Please verify your email address to log in.';
    } else if (msg.contains('user already registered')) {
      return 'This email is already registered. Try logging in instead.';
    } else if (msg.contains('weak password')) {
      return 'Your password is too weak. Please use at least 6 characters.';
    } else if (msg.contains('token expired')) {
      return 'Your session has expired. Please sign in again.';
    } else if (msg.contains('network') || msg.contains('connection')) {
      return 'Unable to connect during authentication. Please check your internet.';
    }
    return error.message;
  }

  static String _handlePostgrestError(PostgrestException error) {
    switch (error.code) {
      case '23505':
        return 'This entry already exists in our records.';
      case '23503':
        return 'This operation failed because a related record was not found.';
      case '42P01':
        return 'A server-side technical error occurred. Our team has been notified.';
      case '42501':
        return 'You do not have permission to perform this action.';
      case 'P0001': // Custom database exception
        return error.message;
      default:
        // Strip technical codes for non-developer eyes unless debugging
        return 'Database error: ${error.message}';
    }
  }

  static String _handleFerryError(OperationResponse<dynamic, dynamic> response) {
    if (response.graphqlErrors != null && response.graphqlErrors!.isNotEmpty) {
      final message = response.graphqlErrors!.first.message;
      // Handle common custom GraphQL error messages or return as is
      return message;
    }

    final linkException = response.linkException;
    if (linkException != null) {
      final msg = linkException.toString().toLowerCase();
      if (msg.contains('socketexception') || msg.contains('failed host lookup')) {
        return 'Failed to reach the server. Please check your connection.';
      } else if (msg.contains('timeout')) {
        return 'The connection timed out. Please try again.';
      }
      return 'A network error occurred while reaching our services.';
    }

    return 'The request could not be completed. Please try again later.';
  }
}
