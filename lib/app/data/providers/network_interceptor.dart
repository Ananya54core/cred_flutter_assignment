import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// Dio interceptor for logging and attaching default headers.
class NetworkInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.headers.addAll({
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    });

    if (kDebugMode) {
      debugPrint('┌─────────────────────────────────────────');
      debugPrint('│ REQUEST: ${options.method} ${options.uri}');
      debugPrint('│ Headers: ${options.headers}');
      debugPrint('└─────────────────────────────────────────');
    }

    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (kDebugMode) {
      debugPrint('┌─────────────────────────────────────────');
      debugPrint('│ RESPONSE: ${response.statusCode} ${response.requestOptions.uri}');
      debugPrint('└─────────────────────────────────────────');
    }

    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (kDebugMode) {
      debugPrint('┌─────────────────────────────────────────');
      debugPrint('│ ERROR: ${err.type} ${err.message}');
      debugPrint('│ URL: ${err.requestOptions.uri}');
      debugPrint('└─────────────────────────────────────────');
    }

    handler.next(err);
  }
}
