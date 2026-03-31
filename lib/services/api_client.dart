import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';

class ApiClient {
  late Dio _dio;
  late SharedPreferences _prefs;

  ApiClient(this._prefs) {
    _dio = Dio(
      BaseOptions(
        baseUrl: APIConfig.baseURL,
        connectTimeout:
            const Duration(seconds: 60), // 60s for initial connection
        receiveTimeout: const Duration(
            seconds: 180), // 180s (3 min) for long LLM processing
        sendTimeout: const Duration(seconds: 60), // 60s to send request
        validateStatus: (status) => true, // Don't throw on any status
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = _prefs.getString(APIConfig.tokenStorageKey);
          print('🔐 TOKEN CHECK: Token exists = ${token != null}');
          if (token != null) {
            print('🔐 TOKEN: ${token.substring(0, 20)}...');
            options.headers['Authorization'] = 'Bearer $token';
            print('✅ Authorization header set');
          } else {
            print('⚠️  WARNING: NO TOKEN FOUND');
            print('   → User must log in first');
            print('   → Endpoint: ${options.method} ${options.path}');
            print('   → Response will be 401 Unauthorized');
          }
          print('📡 Request: ${options.method} ${options.path}');
          print('📡 Headers: ${options.headers}');
          return handler.next(options);
        },
        onError: (error, handler) async {
          print('❌ DioError: ${error.response?.statusCode} - ${error.message}');

          // Handle 401 - Token invalid/expired
          if (error.response?.statusCode == 401) {
            print('🔐 Got 401 Unauthorized');
            final hasRefreshToken =
                _prefs.getString(APIConfig.refreshTokenKey) != null;

            if (hasRefreshToken) {
              print('🔐 Refresh token exists, attempting refresh...');
              try {
                await _refreshToken();
                return handler.resolve(
                  await _dio.request(
                    error.requestOptions.path,
                    options: Options(method: error.requestOptions.method),
                    data: error.requestOptions.data,
                    queryParameters: error.requestOptions.queryParameters,
                  ),
                );
              } catch (e) {
                print('❌ Token refresh failed: $e');
                print('🔐 User needs to login again');
                return handler.next(error);
              }
            } else {
              print('❌ No refresh token available');
              print('🔐 User must log in');
            }
          }
          return handler.next(error);
        },
        onResponse: (response, handler) {
          print(
              '✅ Response: ${response.statusCode} - ${response.requestOptions.path}');
          return handler.next(response);
        },
      ),
    );
  }

  Future<void> _refreshToken() async {
    final refreshToken = _prefs.getString(APIConfig.refreshTokenKey);
    if (refreshToken == null) throw Exception('No refresh token');

    try {
      print('🔐 Refreshing token...');
      final response = await _dio.post(
        '/auth/refresh',
        data: {'refresh_token': refreshToken},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final newAccessToken = response.data?['access_token'];
        if (newAccessToken != null) {
          await _prefs.setString(APIConfig.tokenStorageKey, newAccessToken);
          print('✅ Token refreshed successfully');
        }
      } else {
        throw Exception('Failed to refresh token: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Token refresh error: $e');
      rethrow;
    }
  }

  Future<Response> post(String path, {required dynamic data}) async {
    try {
      final dataLabel =
          data is Map ? (data as Map).keys.join(", ") : 'FormData';
      print('📤 POST $path with data: $dataLabel');
      print('⏱️ Timeout: Connect=60s, Send=60s, Receive=180s');

      final stopwatch = Stopwatch()..start();
      final response = await _dio.post(path, data: data);
      stopwatch.stop();

      print(
          '✅ POST Response: ${response.statusCode} (took ${stopwatch.elapsedMilliseconds}ms)');
      return response;
    } on DioException catch (e) {
      print('❌ POST DioException: ${e.message}');
      if (e.type == DioExceptionType.receiveTimeout) {
        print(
            '⏱️ RECEIVE TIMEOUT: Backend still processing. This is normal for LLM responses.');
        print(
            '⏱️ Max receive timeout is 180 seconds. Consider optimizing backend performance.');
      }
      return _handleDioError(e);
    }
  }

  Future<Response> get(String path,
      {Map<String, dynamic>? queryParameters}) async {
    try {
      final response = await _dio.get(path, queryParameters: queryParameters);
      return response;
    } on DioException catch (e) {
      return _handleDioError(e);
    }
  }

  Response _handleDioError(DioException error) {
    final statusCode = error.response?.statusCode ?? 0;
    final errorMessage = _getErrorMessage(error);
    final errorType = _getErrorType(error);

    print('❌ Error [$errorType]: $errorMessage (Status: $statusCode)');

    // Return synthetic Response with error details
    return Response(
      requestOptions: error.requestOptions,
      statusCode: statusCode,
      data: {
        'error': errorMessage,
        'error_type': errorType,
        'detail': errorMessage,
      },
    );
  }

  String _getErrorMessage(DioException error) {
    if (error.response?.statusCode == 401) {
      return 'Unauthorized - Invalid or expired token';
    } else if (error.response?.statusCode == 403) {
      return 'Forbidden - Access denied (token might be expired)';
    } else if (error.type == DioExceptionType.connectionTimeout) {
      return 'Connection timeout - Backend server not responding';
    } else if (error.type == DioExceptionType.sendTimeout) {
      return 'Send timeout - Request took too long';
    } else if (error.type == DioExceptionType.receiveTimeout) {
      return 'Receive timeout - Response took too long';
    } else if (error.type == DioExceptionType.badResponse) {
      return 'Server error - ${error.response?.statusCode}';
    } else {
      return 'Network error - ${error.message}';
    }
  }

  String _getErrorType(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        return 'CONNECTION_TIMEOUT';
      case DioExceptionType.sendTimeout:
        return 'SEND_TIMEOUT';
      case DioExceptionType.receiveTimeout:
        return 'RECEIVE_TIMEOUT';
      case DioExceptionType.badResponse:
        return 'BAD_RESPONSE';
      default:
        return 'UNKNOWN_ERROR';
    }
  }

  Dio getDio() => _dio;
}
