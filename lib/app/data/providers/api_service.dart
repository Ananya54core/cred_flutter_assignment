import 'package:dio/dio.dart';
import 'network_interceptor.dart';
import '../exceptions/network_exception.dart';

/// Central HTTP client using Dio.
/// All network calls should go through this service.
class ApiService {
  late final Dio _dio;

  ApiService() {
    _dio = Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        sendTimeout: const Duration(seconds: 15),
      ),
    );
    _dio.interceptors.add(NetworkInterceptor());
  }

  /// Generic GET request.
  /// Throws [NetworkException] on failure.
  Future<Response> get(String url) async {
    try {
      final response = await _dio.get(url);
      return response;
    } on DioException catch (e) {
      throw NetworkException.fromDioException(e);
    }
  }
}
