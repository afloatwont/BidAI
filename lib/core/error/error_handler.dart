import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ErrorHandler {
  // Private constructor to prevent instantiation
  ErrorHandler._();

  /// Initialize error handling for the entire app
  static void initialize() {
    // Set up Flutter error handling
    FlutterError.onError = (FlutterErrorDetails details) {
      FlutterError.presentError(details);
      reportError(details.exception, details.stack);
    };

    // Handle errors that occur during async operations
    PlatformDispatcher.instance.onError = (error, stack) {
      reportError(error, stack);
      return true;
    };
  }

  /// Report error to console and optionally to Crashlytics in production
  static void reportError(dynamic error, StackTrace? stackTrace) {
    debugPrint('App Error: $error');
    if (stackTrace != null) {
      debugPrint(stackTrace.toString());
    }

    // In production, you could report to Firebase Crashlytics
    // if (!kDebugMode) {
    //   FirebaseCrashlytics.instance.recordError(error, stackTrace);
    // }
  }

  /// Convert technical error messages to user-friendly messages
  static String getReadableErrorMessage(dynamic error) {
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'user-not-found':
          return 'No account found with this email address. Please check your email or register.';
        case 'wrong-password':
          return 'Incorrect password. Please try again or reset your password.';
        case 'email-already-in-use':
          return 'An account already exists with this email address.';
        case 'weak-password':
          return 'Password is too weak. Please use a stronger password.';
        case 'invalid-email':
          return 'Invalid email format. Please enter a valid email address.';
        case 'network-request-failed':
          return 'Network connection problem. Please check your internet connection.';
        case 'too-many-requests':
          return 'Too many unsuccessful attempts. Please try again later.';
        default:
          return 'Authentication error: ${error.message}';
      }
    } else if (error is FirebaseException) {
      switch (error.code) {
        case 'permission-denied':
          return 'Permission denied. You don\'t have access to this resource.';
        case 'unavailable':
          return 'Service temporarily unavailable. Please try again later.';
        default:
          return 'Database error: ${error.message}';
      }
    }

    return 'An error occurred: $error';
  }

  /// Handle common operation errors with custom logic
  static Future<T> handleOperation<T>({
    required Future<T> Function() operation,
    required Function(dynamic error) onError,
  }) async {
    try {
      return await operation();
    } catch (e, stackTrace) {
      reportError(e, stackTrace);
      onError(e);
      rethrow;
    }
  }
}
