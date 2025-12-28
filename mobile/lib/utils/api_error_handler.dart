import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import '../config/env_config.dart';

/// API exception with detailed error information
class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final String? errorCode;
  final dynamic originalError;

  ApiException({
    required this.message,
    this.statusCode,
    this.errorCode,
    this.originalError,
  });

  @override
  String toString() => message;

  /// User-friendly error message
  String get userMessage {
    if (statusCode == 401) {
      return 'Your session has expired. Please sign in again.';
    } else if (statusCode == 403) {
      return 'You don\'t have permission to perform this action.';
    } else if (statusCode == 404) {
      return 'The requested resource was not found.';
    } else if (statusCode == 429) {
      return 'Too many requests. Please wait a moment and try again.';
    } else if (statusCode != null && statusCode! >= 500) {
      return 'Our servers are temporarily unavailable. Please try again later.';
    } else if (isNetworkError) {
      return 'No internet connection. Please check your network and try again.';
    } else if (isTimeoutError) {
      return 'Request timed out. Please try again.';
    }
    return 'Something went wrong. Please try again.';
  }

  /// Check if this is a network error
  bool get isNetworkError {
    return originalError is SocketException ||
        errorCode == 'NETWORK_ERROR';
  }

  /// Check if this is a timeout error
  bool get isTimeoutError {
    return originalError is TimeoutException ||
        errorCode == 'TIMEOUT';
  }

  /// Check if this is a server error
  bool get isServerError {
    return statusCode != null && statusCode! >= 500;
  }

  /// Check if this error is retryable
  bool get isRetryable {
    return isNetworkError || isTimeoutError || isServerError;
  }
}

/// Retry configuration
class RetryConfig {
  final int maxAttempts;
  final Duration initialDelay;
  final double backoffMultiplier;
  final Duration maxDelay;

  const RetryConfig({
    this.maxAttempts = 3,
    this.initialDelay = const Duration(seconds: 1),
    this.backoffMultiplier = 2.0,
    this.maxDelay = const Duration(seconds: 30),
  });

  static RetryConfig get defaultConfig => RetryConfig(
    maxAttempts: EnvConfig.maxRetryAttempts,
    initialDelay: Duration(milliseconds: EnvConfig.retryDelayMs),
  );
}

/// Retry utility for API calls
class RetryHandler {
  /// Execute a function with retry logic
  static Future<T> retry<T>({
    required Future<T> Function() action,
    required bool Function(Exception) shouldRetry,
    RetryConfig config = const RetryConfig(),
    void Function(int attempt, Exception error)? onRetry,
  }) async {
    int attempt = 0;
    Duration delay = config.initialDelay;

    while (true) {
      attempt++;
      try {
        return await action();
      } on Exception catch (e) {
        if (attempt >= config.maxAttempts || !shouldRetry(e)) {
          rethrow;
        }

        onRetry?.call(attempt, e);
        
        if (EnvConfig.enableLogging) {
          debugPrint('Retry attempt $attempt after error: $e');
        }

        await Future.delayed(delay);
        
        // Exponential backoff
        delay = Duration(
          milliseconds: (delay.inMilliseconds * config.backoffMultiplier).toInt(),
        );
        if (delay > config.maxDelay) {
          delay = config.maxDelay;
        }
      }
    }
  }
}

/// Result wrapper for API calls
class Result<T> {
  final T? data;
  final ApiException? error;

  Result._({this.data, this.error});

  factory Result.success(T data) => Result._(data: data);
  factory Result.failure(ApiException error) => Result._(error: error);

  bool get isSuccess => data != null;
  bool get isFailure => error != null;

  /// Execute different callbacks based on result
  R fold<R>({
    required R Function(T data) onSuccess,
    required R Function(ApiException error) onFailure,
  }) {
    if (isSuccess) {
      return onSuccess(data as T);
    } else {
      return onFailure(error!);
    }
  }
}
