import 'package:dio/dio.dart';

/// Custom exception class for network errors.
/// Maps Dio errors to user-friendly messages.
class NetworkException implements Exception {
  final String message;
  final int? statusCode;
  final DioExceptionType? type;

  NetworkException({
    required this.message,
    this.statusCode,
    this.type,
  });

  /// Factory to create [NetworkException] from a [DioException].
  factory NetworkException.fromDioException(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        return NetworkException(
          message: 'Connection timed out. Please check your internet.',
          type: error.type,
        );
      case DioExceptionType.sendTimeout:
        return NetworkException(
          message: 'Request timed out while sending data.',
          type: error.type,
        );
      case DioExceptionType.receiveTimeout:
        return NetworkException(
          message: 'Server took too long to respond.',
          type: error.type,
        );
      case DioExceptionType.badResponse:
        return NetworkException(
          message: _mapStatusCode(error.response?.statusCode),
          statusCode: error.response?.statusCode,
          type: error.type,
        );
      case DioExceptionType.cancel:
        return NetworkException(
          message: 'Request was cancelled.',
          type: error.type,
        );
      case DioExceptionType.connectionError:
        return NetworkException(
          message: 'No internet connection. Please try again.',
          type: error.type,
        );
      default:
        return NetworkException(
          message: 'Something went wrong. Please try again.',
          type: error.type,
        );
    }
  }

  static String _mapStatusCode(int? statusCode) {
    switch (statusCode) {
      case 400:
        return 'Bad request.';
      case 401:
        return 'Unauthorized. Please login again.';
      case 403:
        return 'Access denied.';
      case 404:
        return 'Resource not found.';
      case 500:
        return 'Internal server error. Please try later.';
      case 502:
        return 'Bad gateway. Server is temporarily unavailable.';
      case 503:
        return 'Service unavailable. Please try later.';
      default:
        return 'Server error (${statusCode ?? 'unknown'}). Please try later.';
    }
  }

  @override
  String toString() => 'NetworkException: $message (code: $statusCode)';
}
