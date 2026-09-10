import 'package:dio/dio.dart';
import '../config/api_config.dart';
import '../errors/app_exception.dart';
import '../security/token_manager.dart';
import 'api_interceptor.dart';

/// Central Dio HTTP client wrapper with configured interceptors and error mappings.
class ApiClient {
  late final Dio _dio;

  ApiClient({required TokenManager tokenManager, String? customBaseUrl}) {
    _dio = Dio(
      BaseOptions(
        baseUrl: customBaseUrl ?? ApiConfig.baseUrl,
        connectTimeout: ApiConfig.connectTimeout,
        receiveTimeout: ApiConfig.receiveTimeout,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    _dio.interceptors.addAll([
      AuthInterceptor(tokenManager),
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        logPrint: (obj) {}, // Kept quiet in default mode, enabled in debug
      ),
    ]);
  }

  Dio get dio => _dio;

  AppException handleError(dynamic error) {
    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
        case DioExceptionType.connectionError:
          return const NetworkException('Connection timeout. Please check your internet connection.');
        case DioExceptionType.badResponse:
          final statusCode = error.response?.statusCode;
          final data = error.response?.data;
          String msg = 'An error occurred';
          if (data is Map<String, dynamic> && data['message'] != null) {
            msg = data['message'].toString();
          }
          if (statusCode == 401 || statusCode == 403) {
            return AuthException(msg, code: statusCode.toString());
          }
          if (statusCode == 422 || statusCode == 400) {
            return ValidationException(msg, code: statusCode.toString(), details: data);
          }
          return ServerException(msg, code: statusCode.toString());
        default:
          return NetworkException(error.message ?? 'Unknown network failure');
      }
    }
    return ServerException(error.toString());
  }
}
