import 'package:dio/dio.dart';
import 'dart:io';
import 'dart:convert';
import '../models/career_guidance_model.dart';
import '../config/career_guide_api_config.dart';

class CareerGuidanceService {
  late Dio _dio;

  CareerGuidanceService() {
    _dio = Dio(
      BaseOptions(
        baseUrl: CareerGuideAPIConfig.baseURL,
        connectTimeout:
            Duration(milliseconds: CareerGuideAPIConfig.connectionTimeout),
        sendTimeout: Duration(milliseconds: CareerGuideAPIConfig.sendTimeout),
        receiveTimeout:
            Duration(milliseconds: CareerGuideAPIConfig.receiveTimeout),
        validateStatus: (status) => status != null && status < 500,
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          print('🎯 Career Guide Request: ${options.method} ${options.path}');
          print('📍 Base URL: ${options.baseUrl}');
          return handler.next(options);
        },
        onError: (error, handler) {
          print(
              '❌ Career Guide Error: ${error.response?.statusCode} - ${error.message}');
          return handler.next(error);
        },
        onResponse: (response, handler) {
          print(
              '✅ Career Guide Response: ${response.statusCode} - ${response.requestOptions.path}');
          return handler.next(response);
        },
      ),
    );
  }

  /// Read resume file content from local path
  /// Supports .txt files directly (not PDF - use for preview only)
  Future<String> _readTextFile(String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        throw Exception('Resume file not found: $filePath');
      }

      // Only read text files as strings
      if (!filePath.toLowerCase().endsWith('.txt')) {
        throw Exception(
            'For PDF/DOCX files, the backend handles parsing. For text files, use .txt format.');
      }

      final content = await file.readAsString();
      if (content.isEmpty) {
        throw Exception('Resume file is empty');
      }

      print(
          '📄 Text file read: ${filePath.split('/').last} (${content.length} chars)');
      return content;
    } catch (e) {
      print('❌ Error reading text file: $e');
      rethrow;
    }
  }

  /// Generate career guidance - sends resume as multipart file if provided
  ///
  /// Parameters:
  /// - [qaResponses]: Required Q&A form data
  /// - [resumeFilePath]: Optional path to resume file (PDF, DOCX, TXT supported)
  /// - [resumeUrl]: Optional URL to resume file
  ///
  /// Returns [CareerGuidanceResponse] with career recommendations
  Future<CareerGuidanceResponse> generateCareerGuidance({
    String? resumeFilePath,
    String? resumeUrl,
    required QAResponses qaResponses,
  }) async {
    try {
      print('🎯 Generating career guidance...');
      print(
          '📤 Endpoint: POST ${CareerGuideAPIConfig.baseURL}${CareerGuideAPIConfig.generateGuidanceEndpoint}');

      // ✅ OPTION 1: Send resume as multipart file (BEST for PDF/DOCX)
      if (resumeFilePath != null && resumeFilePath.isNotEmpty) {
        print('📄 Uploading resume file as multipart: $resumeFilePath');

        // Create FormData for multipart upload - using /api/analyze endpoint
        // This endpoint: NO AUTH REQUIRED, uses individual form fields, expects 'resume' field
        FormData formData = FormData.fromMap({
          // Web endpoint expects 'resume' field (not 'resume_file')
          'resume': await MultipartFile.fromFile(
            resumeFilePath,
            filename: resumeFilePath.split('/').last,
          ),
          // Send individual Q&A fields (simpler than JSON string)
          'interests': qaResponses.interests,
          'known_skills': qaResponses.knownSkills,
          'career_goal': qaResponses.careerGoal,
          'projects_done': qaResponses.projectsDone,
          'education_branch': qaResponses.educationBranch,
          'year_of_study': qaResponses.yearOfStudy,
          'has_internship': qaResponses.hasInternship.toString(),
          'self_weakness': qaResponses.selfWeakness,
          if (qaResponses.preferredWork != null)
            'preferred_work': qaResponses.preferredWork,
        });

        print('📨 Sending multipart form data with file...');
        print(
            '📋 Q&A Data: interests=${qaResponses.interests}, skills=${qaResponses.knownSkills}');
        print(
            '🔄 Endpoint: ${CareerGuideAPIConfig.generateGuidanceEndpoint} (web endpoint, NO AUTH)');

        final response = await _dio.post(
          CareerGuideAPIConfig.generateGuidanceEndpoint,
          data: formData,
        );

        return _handleResponse(response);
      }

      // ✅ OPTION 2: Send resume URL (if provided)
      if (resumeUrl != null && resumeUrl.isNotEmpty) {
        print('🔗 Using resume URL: $resumeUrl');

        final request = CareerGuidanceRequest(
          resumeUrl: resumeUrl,
          qaResponses: qaResponses,
        );

        final response = await _dio.post(
          CareerGuideAPIConfig.generateGuidanceEndpoint,
          data: request.toJson(),
        );

        return _handleResponse(response);
      }

      // ✅ OPTION 3: Send only Q&A (no resume)
      print('📝 No resume provided - sending Q&A only');
      final request = CareerGuidanceRequest(
        qaResponses: qaResponses,
      );

      final response = await _dio.post(
        CareerGuideAPIConfig.generateGuidanceEndpoint,
        data: request.toJson(),
      );

      return _handleResponse(response);
    } on DioException catch (e) {
      // Detailed error logging for debugging
      print('❌ Dio Error Type: ${e.type}');
      print('❌ Dio Error Message: ${e.message}');
      print('❌ Error Code: ${e.error}');
      print('📡 Response Status: ${e.response?.statusCode}');
      print('📡 Response Data: ${e.response?.data}');

      // Network error diagnostics
      String errorMsg = '';

      if (e.type == DioExceptionType.connectionTimeout) {
        errorMsg = '⏱️ Connection Timeout (30s)\n\n'
            '❌ Backend not reachable at: http://10.255.176.62:5000\n\n'
            '✅ Fix: \n'
            '1. Start backend: cd Career_guide && python app.py\n'
            '2. Verify backend logs show "Running on http://10.255.176.62:5000"\n'
            '3. Check device is on SAME WiFi network as PC\n'
            '4. Test in browser: http://10.255.176.62:5000/health (on device)\n'
            '5. If browser fails, disable Windows Firewall';
      } else if (e.type == DioExceptionType.receiveTimeout) {
        errorMsg = '⏱️ Backend Processing Timeout (180s)\n\n'
            '❌ Backend took too long to respond\n\n'
            '✅ Fix:\n'
            '1. Check backend logs for errors\n'
            '2. Verify file is readable (< 10MB)\n'
            '3. Check ML model is loaded (ml/career_classifier.pkl exists)\n'
            '4. Restart backend: python app.py';
      } else if (e.type == DioExceptionType.unknown) {
        errorMsg = '❌ Network Connection Failed\n\n'
            'Device cannot reach backend.\n\n'
            '✅ Troubleshooting:\n'
            '1. On your phone, open browser and test:\n'
            '   http://10.255.176.62:5000/health\n'
            '2. If it shows JSON → Network OK, problem elsewhere\n'
            '3. If it fails → Network blocked by:\n'
            '   - Different WiFi network\n'
            '   - Windows Firewall blocking port 5000\n'
            '   - Antivirus blocking connection\n'
            '   - Router blocking internal traffic\n\n'
            'Full error: ${e.message}';
      } else {
        errorMsg = '❌ Network Error: ${e.type}\n\n'
            'Message: ${e.message}\n\n'
            '✅ See NETWORK_TROUBLESHOOTING.md for help';
      }

      throw Exception(errorMsg);
    } catch (e) {
      print('❌ Unexpected Error: $e');
      print('❌ Error Type: ${e.runtimeType}');
      throw Exception('Unexpected error: $e');
    }
  }

  /// Handle API response processing
  CareerGuidanceResponse _handleResponse(Response response) {
    print('📥 Response Status: ${response.statusCode}');
    print('📥 Response Body: ${response.data}');

    if (response.statusCode == 200 || response.statusCode == 201) {
      final guidance = CareerGuidanceResponse.fromJson(response.data);
      print('✅ Career guidance generated successfully');
      return guidance;
    } else {
      final errorMsg = response.data?['error'] ??
          response.data?['message'] ??
          'Unknown error';
      print('❌ API Error: $errorMsg');
      throw Exception('Failed to generate career guidance: $errorMsg');
    }
  }

  /// Health check for Career Guide service
  Future<bool> healthCheck() async {
    try {
      print('🏥 Checking Career Guide service health...');
      final response = await _dio.get(CareerGuideAPIConfig.healthCheckEndpoint);

      if (response.statusCode == 200) {
        print('✅ Career Guide service is running');
        return true;
      } else {
        print('⚠️ Career Guide service returned status ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('❌ Career Guide service is not available: $e');
      return false;
    }
  }
}
