import 'package:dio/dio.dart';
import '../config/api_config.dart';

/// Service to check if the backend server is running and healthy
class BackendHealthService {
  static final BackendHealthService _instance =
      BackendHealthService._internal();
  late Dio _dio;

  BackendHealthService._internal() {
    _dio = Dio(
      BaseOptions(
        baseUrl: APIConfig.baseURL,
        connectTimeout: const Duration(seconds: 5),
        receiveTimeout: const Duration(seconds: 5),
        validateStatus: (status) => true, // Don't throw on any status
      ),
    );
  }

  factory BackendHealthService() {
    return _instance;
  }

  /// Check if the backend server is running
  /// Returns true if server is reachable, false otherwise
  Future<bool> isBackendHealthy() async {
    try {
      print('🏥 Checking backend health at ${APIConfig.baseURL}...');

      // Try to reach the /auth/me endpoint (should be available even without auth)
      // Or we can check /health endpoint if it exists
      final response = await _dio.get('/auth/me');

      // Even 401 (unauthorized) means server is running
      if (response.statusCode! >= 200 && response.statusCode! < 600) {
        print('🏥 Backend is healthy ✅');
        return true;
      }

      return false;
    } on DioException catch (e) {
      switch (e.type) {
        case DioExceptionType.connectionTimeout:
          print('❌ Backend connection timeout');
          return false;
        case DioExceptionType.receiveTimeout:
          print('❌ Backend receive timeout');
          return false;
        case DioExceptionType.unknown:
          print('❌ Cannot connect to backend: ${e.message}');
          return false;
        default:
          print('❌ Backend health check failed: ${e.type}');
          return false;
      }
    } catch (e) {
      print('❌ Unexpected error checking backend health: $e');
      return false;
    }
  }

  /// Get backend URL for display in error messages
  static String getBackendUrl() {
    return APIConfig.baseURL.replaceAll('/api', '');
  }
}
