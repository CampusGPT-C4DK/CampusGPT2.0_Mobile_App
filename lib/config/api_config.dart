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
  // static const String baseURL = 'http://192.168.x.x:8000/api'; // Set your actual IP
  static const String baseURL = 'http://10.128.46.62:8000/api'; // Example IP

  // To find your machine IP on Windows:
  // - Open PowerShell and run: ipconfig
  // - Look for "IPv4 Address" on your WiFi adapter
  // - Use that IP address above (e.g., 192.168.1.100)

  // ============================================================================
  // CONNECTION SETTINGS
  // ============================================================================
  static const int connectionTimeout = 30000;
  static const int receiveTimeout = 30000;

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
