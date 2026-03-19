import 'package:shared_preferences/shared_preferences.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:dio/dio.dart';
import 'api_client.dart';
import '../config/api_config.dart';
import '../models/user_model.dart';

class AuthService {
  final ApiClient apiClient;
  final SharedPreferences prefs;

  AuthService({required this.apiClient, required this.prefs});

  Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    required String fullName,
  }) async {
    try {
      print('🔐 REGISTER: Starting registration for $email');

      final response = await apiClient.post(
        '/auth/register',
        data: {
          'email': email,
          'password': password,
          'full_name': fullName,
          'role': 'student',
        },
      );

      print('🔐 REGISTER: Got response ${response.statusCode}');
      print('🔐 REGISTER: Response data type: ${response.data.runtimeType}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        final accessToken = response.data?['access_token'];
        final refreshToken = response.data?['refresh_token'];

        if (accessToken == null || refreshToken == null) {
          print('❌ REGISTER: No tokens in response');
          return {
            'success': false,
            'message': 'Server error: No authentication tokens received',
          };
        }

        await saveTokens(accessToken, refreshToken);

        return {
          'success': true,
          'message': 'Registration successful',
          'user': response.data?['user'],
        };
      }

      // Handle error responses
      String errorMessage = _extractErrorMessage(response.data);
      print('❌ REGISTER FAILED: $errorMessage');

      return {
        'success': false,
        'message': errorMessage,
      };
    } catch (e) {
      print('❌ REGISTER ERROR: ${e.toString()}');
      return {
        'success': false,
        'message': _parseError(e),
      };
    }
  }

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      print('🔐 LOGIN: Starting login for $email');
      print('🔐 LOGIN: Backend URL: ${APIConfig.baseURL}');

      final response = await apiClient.post(
        '/auth/login',
        data: {'email': email, 'password': password},
      );

      print('🔐 LOGIN: Got response ${response.statusCode}');
      print('🔐 LOGIN: Response data: ${response.data}');

      // Handle success responses (200, 201)
      if (response.statusCode == 200 || response.statusCode == 201) {
        final accessToken = response.data?['access_token'];
        final refreshToken = response.data?['refresh_token'];

        print('🔐 LOGIN: Access token exists: ${accessToken != null}');
        print('🔐 LOGIN: Refresh token exists: ${refreshToken != null}');

        if (accessToken == null || refreshToken == null) {
          print('❌ LOGIN: No tokens in response. Data: ${response.data}');
          return {
            'success': false,
            'message': 'Server error: No authentication tokens received',
          };
        }

        await saveTokens(accessToken, refreshToken);

        return {
          'success': true,
          'message': 'Login successful',
          'user': response.data?['user'],
        };
      }

      // Handle invalid credentials
      if (response.statusCode == 401) {
        print('❌ LOGIN FAILED: Invalid credentials (401)');
        return {
          'success': false,
          'message': 'Invalid email or password',
        };
      }

      // Handle other error responses
      if (response.statusCode == 0) {
        // This means ApiClient caught an exception and created error response
        String errorMessage = _extractErrorMessage(response.data);
        print('❌ LOGIN FAILED: ${response.statusCode} - $errorMessage');
        return {
          'success': false,
          'message': errorMessage,
        };
      }

      // Handle other HTTP status codes
      String errorMessage = _extractErrorMessage(response.data);
      print('❌ LOGIN FAILED: ${response.statusCode} - $errorMessage');

      return {
        'success': false,
        'message': errorMessage,
      };
    } catch (e) {
      print('❌ LOGIN ERROR CAUGHT: ${e.toString()}');
      print('❌ LOGIN ERROR TYPE: ${e.runtimeType}');
      return {
        'success': false,
        'message': _parseError(e),
      };
    }
  }

  Future<void> saveTokens(String accessToken, String refreshToken) async {
    try {
      await prefs.setString(APIConfig.tokenStorageKey, accessToken);
      await prefs.setString(APIConfig.refreshTokenKey, refreshToken);
      await prefs.setString('token_saved_at', DateTime.now().toIso8601String());
      print('🔐 Tokens saved successfully ✅');
    } catch (e) {
      print('🔐 Error saving tokens: $e ❌');
      rethrow;
    }
  }

  Future<UserModel?> getCurrentUser() async {
    try {
      print('👤 Fetching current user...');
      final response = await apiClient.get('/auth/me');

      if (response.statusCode == 200) {
        print('👤 Current user fetched successfully');
        return UserModel.fromJson(response.data);
      }

      print('❌ Failed to fetch user: ${response.statusCode}');
      return null;
    } catch (e) {
      print('❌ Error fetching current user: $e');
      return null;
    }
  }

  Future<void> logout() async {
    try {
      await prefs.remove(APIConfig.tokenStorageKey);
      await prefs.remove(APIConfig.refreshTokenKey);
      await prefs.remove('token_saved_at');
      print('🔐 User logout: All tokens cleared ✅');
    } catch (e) {
      print('🔐 Error during logout: $e ❌');
      rethrow;
    }
  }

  bool isTokenExpired() {
    final accessToken = prefs.getString(APIConfig.tokenStorageKey);
    if (accessToken == null) {
      print('🔐 No token stored');
      return true;
    }

    try {
      final isExpired = JwtDecoder.isExpired(accessToken);
      print(
          '🔐 Token expiration check: ${isExpired ? 'EXPIRED ❌' : 'VALID ✅'}');
      return isExpired;
    } catch (e) {
      print('⚠️ Error checking token expiration: $e');
      return true;
    }
  }

  String? getAccessToken() {
    final token = prefs.getString(APIConfig.tokenStorageKey);
    print(
        '🔐 Getting access token: ${token != null ? 'EXISTS ✅' : 'NOT FOUND ❌'}');
    return token;
  }

  bool isLoggedIn() {
    final token = getAccessToken();
    final isExpired = isTokenExpired();
    final loggedIn = token != null && !isExpired;
    print('🔐 Login state check: ${loggedIn ? 'LOGGED IN ✅' : 'LOGGED OUT ❌'}');
    return loggedIn;
  }

  /// Send password reset email using query parameters
  Future<Map<String, dynamic>> forgotPassword({
    required String email,
  }) async {
    try {
      print('🔐 Sending password reset email to: $email');

      // Use GET request with query parameters as per backend API
      final response = await apiClient.get(
        '/auth/forgot-password',
        queryParameters: {'email': email},
      );

      if (response.statusCode == 200) {
        print('✅ Password reset email sent to: $email');
        return {
          'success': true,
          'message': response.data?['message'] ??
              'Reset link sent to your email. Check your inbox.',
          'email': email,
        };
      }

      String errorMessage = _extractErrorMessage(response.data);
      print('❌ Forgot password failed: $errorMessage');
      return {
        'success': false,
        'message': errorMessage,
      };
    } catch (e) {
      print('❌ Forgot password error: ${e.toString()}');
      return {
        'success': false,
        'message': _parseError(e),
      };
    }
  }

  /// Reset password using query parameters
  Future<Map<String, dynamic>> resetPassword({
    required String email,
    required String password,
    required String token,
  }) async {
    try {
      print('🔐 Resetting password for: $email');

      // Use GET request with query parameters as per backend API
      final response = await apiClient.get(
        '/auth/reset-password',
        queryParameters: {
          'email': email,
          'password': password,
          'token': token,
        },
      );

      if (response.statusCode == 200) {
        print('✅ Password reset successful');
        return {
          'success': true,
          'message': response.data?['message'] ??
              'Password reset successful. Please login with your new password.',
        };
      }

      String errorMessage = _extractErrorMessage(response.data);
      print('❌ Reset password failed: $errorMessage');
      return {
        'success': false,
        'message': errorMessage,
      };
    } catch (e) {
      print('❌ Reset password error: ${e.toString()}');
      return {
        'success': false,
        'message': _parseError(e),
      };
    }
  }

  /// Update password using recovery token (from deep link)
  /// This method is called when user clicks the reset link in email
  Future<Map<String, dynamic>> updatePasswordWithRecoveryToken({
    required String newPassword,
    required String token,
  }) async {
    try {
      print('🔐 Updating password with recovery token');

      final response = await apiClient.post(
        '/auth/confirm-reset',
        data: {
          'password': newPassword,
          'token': token,
        },
      );

      if (response.statusCode == 200) {
        print('✅ Password updated successfully with recovery token');
        return {
          'success': true,
          'message': response.data['message'] ??
              'Password updated successfully. Please login with your new password.',
        };
      }

      String errorMessage = _extractErrorMessage(response.data);
      print('❌ Update password failed: $errorMessage');
      return {
        'success': false,
        'message': errorMessage,
      };
    } catch (e) {
      print('❌ Update password error: ${e.toString()}');
      return {
        'success': false,
        'message': _parseError(e),
      };
    }
  }

  /// Extract error message from response data
  String _extractErrorMessage(dynamic data) {
    if (data is Map<String, dynamic>) {
      // Try different error message fields
      if (data['detail'] is String) return data['detail'];
      if (data['message'] is String) return data['message'];
      if (data['error'] is String) return data['error'];
      if (data['error_type'] is String) {
        final errorType = data['error_type'];
        return _getServerErrorMessage(errorType);
      }
    }
    return 'An error occurred. Please try again.';
  }

  /// Parse different types of errors
  String _parseError(dynamic error) {
    print('📍 Parsing error: ${error.runtimeType} - $error');

    if (error is DioException) {
      return _parseDioError(error);
    }

    return error.toString().contains('SocketException')
        ? 'Cannot connect to backend server. Make sure the server is running at ${APIConfig.baseURL}'
        : 'An error occurred. Please try again.';
  }

  /// Parse Dio errors with detailed messages
  String _parseDioError(DioException error) {
    if (error.response != null) {
      final statusCode = error.response!.statusCode ?? 500;
      final data = error.response!.data;

      if (statusCode == 401) {
        return 'Invalid credentials. Please check your email and password.';
      } else if (statusCode == 403) {
        return 'Access denied. The server may not be activated. Please restart the backend server.';
      } else if (statusCode == 404) {
        return 'Backend server not responding. Make sure the server is running at ${APIConfig.baseURL}';
      } else if (statusCode == 500) {
        return 'Backend server error (500). Please activate/restart the server.';
      } else if (statusCode >= 400 && statusCode < 500) {
        return data is Map
            ? _extractErrorMessage(data)
            : 'Request failed: $statusCode';
      }
    }

    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
        return 'Backend server is not responding. Make sure the server is running at ${APIConfig.baseURL}';

      case DioExceptionType.badResponse:
        return 'Backend server error. Please activate the server.';

      case DioExceptionType.unknown:
        if (error.message?.toLowerCase().contains('socketeexception') ??
            false) {
          return 'Cannot connect to backend server at ${APIConfig.baseURL}. Make sure the server is running.';
        }
        return 'Network error. Check your connection and that the server is running.';

      default:
        return 'An error occurred. Please try again.';
    }
  }

  /// Get server-specific error messages
  String _getServerErrorMessage(String errorType) {
    switch (errorType) {
      case 'CONNECTION_TIMEOUT':
      case 'RECEIVE_TIMEOUT':
      case 'SEND_TIMEOUT':
        return 'Server took too long to respond. Please activate the server.';
      case 'BAD_RESPONSE':
        return 'Backend server error. Please activate or restart the server.';
      case 'UNKNOWN_ERROR':
        return 'Unknown server error. Please check backend status.';
      default:
        return 'Server error occurred.';
    }
  }
}
