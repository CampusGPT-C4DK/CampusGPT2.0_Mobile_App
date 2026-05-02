import 'dart:io';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'api_client.dart';
import '../config/api_config.dart';

class StudentService {
  final ApiClient apiClient;

  StudentService({required this.apiClient});

  String _taeBase() {
    // TAE model runs as a separate FastAPI service (default port: 7000 in this repo).
    // Your CampusGPT backend uses /api on port 8000; student assignment endpoints live in TAE.
    final backend = APIConfig.getServerUrl(); // e.g. http://10.117.8.62:8000
    try {
      final uri = Uri.parse(backend);
      final port = uri.hasPort ? uri.port : null;
      final taePort = (port == 8000) ? 7000 : (port ?? 7000);
      return uri.replace(port: taePort, path: '').toString();
    } catch (_) {
      // Fallback: simple replace if URI parse fails.
      return backend.replaceAll(':8000', ':7000').replaceAll('/api', '');
    }
  }

  String _rootUrl(String path) {
    final base = _taeBase();
    if (!path.startsWith('/')) return '$base/$path';
    return '$base$path';
  }

  Future<Response> _rootGet(String path,
      {Map<String, dynamic>? queryParameters}) {
    return apiClient.getDio().get(
          _rootUrl(path),
          queryParameters: queryParameters,
        );
  }

  Future<Response> _rootPost(String path, {required dynamic data}) {
    return apiClient.getDio().post(_rootUrl(path), data: data);
  }

  Future<List<dynamic>> getAssignments() async {
    final response = await _rootGet('/student/assignments');
    if (response.statusCode == 200) {
      final data = response.data;
      if (data is Map<String, dynamic>) {
        final status = '${data['status'] ?? ''}'.trim().toLowerCase();
        if (status.isNotEmpty && status != 'success') {
          throw Exception(_extractMessage(data) ?? 'Failed to fetch assignments');
        }
      }
      if (data is Map<String, dynamic> && data['data'] is List) {
        return List<dynamic>.from(data['data'] as List);
      }
      if (data is List) return List<dynamic>.from(data);
    }
    throw Exception(_extractMessage(response.data) ??
        'Failed to fetch assignments (${response.statusCode}). Check server: ${APIConfig.getServerUrl()}');
  }

  Future<List<dynamic>> getMySubmissions() async {
    final response = await _rootGet('/student/my-submissions');
    if (response.statusCode == 200) {
      final data = response.data;
      if (data is Map<String, dynamic>) {
        final status = '${data['status'] ?? ''}'.trim().toLowerCase();
        if (status.isNotEmpty && status != 'success') {
          throw Exception(_extractMessage(data) ?? 'Failed to fetch submissions');
        }
      }
      if (data is Map<String, dynamic> && data['data'] is List) {
        final rows = List<dynamic>.from(data['data'] as List);
        return rows.map((e) => _normalizeSubmissionMap(e)).toList();
      }
      if (data is List) {
        return List<dynamic>.from(data).map((e) => _normalizeSubmissionMap(e)).toList();
      }
    }
    throw Exception(_extractMessage(response.data) ??
        'Failed to fetch submissions (${response.statusCode}). Check server: ${APIConfig.getServerUrl()}');
  }

  Future<Map<String, dynamic>> getSubmission(String submissionId) async {
    final response = await _rootGet('/student/submission/$submissionId');
    if (response.statusCode == 200) {
      final data = response.data;
      if (data is Map<String, dynamic>) {
        final status = '${data['status'] ?? ''}'.trim().toLowerCase();
        if (status.isNotEmpty && status != 'success') {
          throw Exception(_extractMessage(data) ?? 'Failed to fetch submission');
        }
        return _normalizeSubmissionDetail(data);
      }
    }
    throw Exception(_extractMessage(response.data) ??
        'Failed to fetch submission (${response.statusCode}). Check server: ${APIConfig.getServerUrl()}');
  }

  Future<Map<String, dynamic>> submitAssignment({
    required String assignmentId,
    required File pdfFile,
  }) async {
    final formData = FormData.fromMap({
      'assignment_id': assignmentId,
      'file': await MultipartFile.fromFile(
        pdfFile.path,
        filename: pdfFile.uri.pathSegments.isNotEmpty
            ? pdfFile.uri.pathSegments.last
            : 'submission.pdf',
      ),
    });

    final response =
        await _rootPost('/student/submit-assignment', data: formData);
    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = response.data;
      if (data is Map<String, dynamic>) {
        final status = '${data['status'] ?? ''}'.trim().toLowerCase();
        if (status == 'success') return data;
        throw Exception(_extractMessage(data) ?? 'Submission failed');
      }
    }
    throw Exception(_extractMessage(response.data) ??
        'Failed to submit assignment (${response.statusCode}). Check server: ${APIConfig.getServerUrl()}');
  }

  Future<Map<String, dynamic>> getStudentDashboard() async {
    final response = await _rootGet('/dashboard/student-dashboard');
    if (response.statusCode == 200) {
      final data = response.data;
      if (data is Map<String, dynamic>) {
        final status = '${data['status'] ?? ''}'.trim().toLowerCase();
        if (status.isNotEmpty && status != 'success') {
          throw Exception(_extractMessage(data) ?? 'Failed to fetch dashboard');
        }
        return data;
      }
    }
    throw Exception(_extractMessage(response.data) ??
        'Failed to fetch dashboard (${response.statusCode}). Check server: ${APIConfig.getServerUrl()}');
  }

  Future<Map<String, dynamic>> getStudentPerformance() async {
    final response = await _rootGet('/dashboard/student-performance');
    if (response.statusCode == 200) {
      final data = response.data;
      if (data is Map<String, dynamic>) {
        final status = '${data['status'] ?? ''}'.trim().toLowerCase();
        if (status.isNotEmpty && status != 'success') {
          throw Exception(_extractMessage(data) ?? 'Failed to fetch performance');
        }
        return data;
      }
    }
    throw Exception(_extractMessage(response.data) ??
        'Failed to fetch performance (${response.statusCode}). Check server: ${APIConfig.getServerUrl()}');
  }

  Future<Map<String, dynamic>> getEvaluationResult(String submissionId) async {
    // Guide says this endpoint is currently public.
    try {
      final response = await _rootGet('/evaluation/results/$submissionId');
      if (response.statusCode == 200) {
        final data = response.data;
        if (data is Map<String, dynamic>) {
          final status = '${data['status'] ?? ''}'.trim().toLowerCase();
          if (status == 'success' || status == 'not_evaluated') return data;
          throw Exception(_extractMessage(data) ?? 'Failed to fetch result');
        }
      }
      throw Exception(_extractMessage(response.data) ??
          'Failed to fetch result (${response.statusCode}). Check server: ${APIConfig.getServerUrl()}');
    } on DioException catch (e) {
      // This endpoint is public. If auth token is stale/invalid, retry anonymously.
      if (e.response?.statusCode == 401 || e.response?.statusCode == 403) {
        final anon = Dio(BaseOptions(
          connectTimeout: const Duration(seconds: 20),
          receiveTimeout: const Duration(seconds: 20),
          sendTimeout: const Duration(seconds: 20),
        ));
        final anonResp = await anon.get(_rootUrl('/evaluation/results/$submissionId'));
        if (anonResp.statusCode == 200 && anonResp.data is Map<String, dynamic>) {
          final data = anonResp.data as Map<String, dynamic>;
          final status = '${data['status'] ?? ''}'.trim().toLowerCase();
          if (status == 'success' || status == 'not_evaluated') return data;
          throw Exception(_extractMessage(data) ?? 'Failed to fetch result');
        }
      }
      rethrow;
    }
  }

  String? _extractMessage(dynamic data) {
    if (data is Map<String, dynamic>) {
      final detail = data['detail'];
      if (detail is String && detail.trim().isNotEmpty) return detail;
      final message = data['message'];
      if (message is String && message.trim().isNotEmpty) return message;
      final error = data['error'];
      if (error is String && error.trim().isNotEmpty) return error;
    }
    return null;
  }

  Map<String, dynamic> _normalizeSubmissionMap(dynamic raw) {
    final m = (raw is Map) ? Map<String, dynamic>.from(raw) : <String, dynamic>{};
    final evaluation = (m['evaluation'] is Map)
        ? Map<String, dynamic>.from(m['evaluation'] as Map)
        : <String, dynamic>{};
    final status = _deriveStatus(
      originalStatus: '${m['status'] ?? ''}',
      evaluation: evaluation.isEmpty ? null : evaluation,
    );
    m['status'] = status;
    m['allow_resubmission'] = _deriveAllowResubmission(
      fromResponse: m['allow_resubmission'],
      evaluation: evaluation.isEmpty ? null : evaluation,
    );
    return m;
  }

  Map<String, dynamic> _normalizeSubmissionDetail(Map<String, dynamic> data) {
    final normalized = Map<String, dynamic>.from(data);
    final submission = (normalized['submission'] is Map)
        ? Map<String, dynamic>.from(normalized['submission'] as Map)
        : <String, dynamic>{};
    final evaluation = (normalized['evaluation'] is Map)
        ? Map<String, dynamic>.from(normalized['evaluation'] as Map)
        : <String, dynamic>{};

    final status = _deriveStatus(
      originalStatus: '${submission['status'] ?? ''}',
      evaluation: evaluation.isEmpty ? null : evaluation,
    );
    submission['status'] = status;
    normalized['submission'] = submission;
    normalized['allow_resubmission'] = _deriveAllowResubmission(
      fromResponse: normalized['allow_resubmission'],
      evaluation: evaluation.isEmpty ? null : evaluation,
    );
    return normalized;
  }

  String _deriveStatus({required String originalStatus, Map<String, dynamic>? evaluation}) {
    final lower = originalStatus.trim().toLowerCase();
    if (lower == 'passed' || lower == 'failed') return lower;
    if (evaluation != null && evaluation.isNotEmpty) {
      final marks = evaluation['marks_obtained'];
      final total = evaluation['total_marks'];
      if (marks is num && total is num && total > 0) {
        final pct = (marks / total) * 100;
        return pct >= 40 ? 'passed' : 'failed';
      }
      return 'graded';
    }
    return lower.isEmpty ? 'pending' : lower;
  }

  bool _deriveAllowResubmission({dynamic fromResponse, Map<String, dynamic>? evaluation}) {
    if (fromResponse is bool) return fromResponse;
    if (evaluation == null || evaluation.isEmpty) return false;
    final modelEvaluation = evaluation['model_evaluation'];
    if (modelEvaluation is String && modelEvaluation.trim().startsWith('{')) {
      try {
        final decoded = jsonDecode(modelEvaluation);
        if (decoded is Map<String, dynamic>) {
          final meta = decoded['__meta'];
          if (meta is Map<String, dynamic>) {
            return meta['allow_resubmission'] == true;
          }
        }
      } catch (_) {}
    }
    return false;
  }
}

