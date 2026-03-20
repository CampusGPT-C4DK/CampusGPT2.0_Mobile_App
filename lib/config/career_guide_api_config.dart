/// Career Guide API Configuration
/// Separate configuration for Career Guidance backend (Port 5000)

class CareerGuideAPIConfig {
  // ============================================================================
  // CAREER GUIDE API CONFIGURATION (Port 5000)
  // ============================================================================
  // The Career Guide service runs on a DIFFERENT port than the main backend
  // Main Backend: Port 8000 (for auth, general API)
  // Career Guide: Port 5000 (for career guidance ML service)

  // For Android Emulator (default) - uses 10.0.2.2 to reach host machine
  // static const String baseURL = 'http://10.0.2.2:5000/api';

  // For iOS Simulator - use localhost instead
  // static const String baseURL = 'http://localhost:5000/api';

  // For Physical Device on same network - replace with your machine IP
  // Find your IPv4 address using: ipconfig (in PowerShell)
  // Example: http://192.168.1.100:5000/api
  // static const String baseURL = 'http://192.168.1.x:5000/api';

  // To find your machine IP on Windows:
  // - Open PowerShell and run: ipconfig
  // - Look for "IPv4 Address" on your WiFi adapter
  // - Use that IP address above (e.g., 192.168.1.100)

  static const String baseURL =
      'http://10.255.176.62:5000'; // Base URL WITHOUT /api prefix

  // ============================================================================
  // CONNECTION SETTINGS
  // ============================================================================
  static const int connectionTimeout = 60000; // 60s for ML processing
  static const int sendTimeout = 60000;
  static const int receiveTimeout =
      300000; // 5 minutes for ML inference (increased from 3min)

  // ============================================================================
  // ENDPOINTS
  // ============================================================================
  // PRIMARY: Use /api/analyze for file upload (web endpoint - NO AUTH NEEDED)
  // This endpoint works with individual form fields and expects 'resume' field
  static const String generateGuidanceEndpoint = '/api/analyze';

  // SECONDARY (Auth required): Use /generate-guidance-with-resume for multipart upload
  // This endpoint requires Bearer token and uses 'resume_file' + 'qa_responses' JSON
  static const String generateGuidanceWithResumeEndpoint =
      '/generate-guidance-with-resume';

  static const String healthCheckEndpoint = '/health';
}
