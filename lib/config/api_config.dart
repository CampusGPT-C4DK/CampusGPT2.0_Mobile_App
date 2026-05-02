class APIConfig {
  // ============================================================================
  // BACKEND URL CONFIGURATION
  // ============================================================================
  // Choose the appropriate base URL based on your setup:

  // For Android Emulator (default) - uses 10.0.2.2 to reach host machine
  // static const String baseURL = 'http://10.0.2.2:8000/api';

  // For iOS Simulator - use localhost instead
  // static const String baseURL = 'http://localhost:8000/api';

  // For Physical Device on same network - replace with your machine IP
  // Find your IPv4 address using: ipconfig (in PowerShell)
  // Example: http://192.168.1.100:8000/api
  // static const String baseURL = 'http://192.168.1.x:8000/api';

  // To find your machine IP on Windows:
  // - Open PowerShell and run: ipconfig
  // - Look for "IPv4 Address" on your WiFi adapter
  // - Use that IP address above (e.g., 192.168.1.100)

  static const String baseURL = 'http://10.117.8.62:8000/api';

  // ============================================================================
  // CONNECTION SETTINGS
  // ============================================================================
  static const int connectionTimeout = 60000; // 60s for initial connection
  static const int receiveTimeout =
      120000; // 120s (2 min) for LLM processing + model loading

  // ============================================================================
  // SECRET KEYS FOR LOCAL STORAGE
  // ============================================================================
  static const String tokenStorageKey = 'access_token';
  static const String refreshTokenKey = 'refresh_token';

  // ============================================================================
  // HELPER METHOD
  // ============================================================================
  /// Get the base server URL without /api
  static String getServerUrl() {
    return baseURL.replaceAll('/api', '');
  }
}
