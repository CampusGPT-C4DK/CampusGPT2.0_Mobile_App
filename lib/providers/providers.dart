import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_client.dart';
import '../services/auth_service.dart';
import '../services/chat_service.dart';
import '../models/user_model.dart';

// SharedPreferences Provider - Now synchronous, must be overridden in main
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError(
      'sharedPreferencesProvider must be overridden in main()');
});

// API Client Provider
final apiClientProvider = Provider<ApiClient>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return ApiClient(prefs);
});

// Auth Service Provider
final authServiceProvider = Provider<AuthService>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  final prefs = ref.watch(sharedPreferencesProvider);
  return AuthService(apiClient: apiClient, prefs: prefs);
});

// Chat Service Provider
final chatServiceProvider = Provider<ChatService>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return ChatService(apiClient: apiClient);
});

// Auth State Provider with Persistent Login Check
final authStateProvider = StateNotifierProvider<AuthStateNotifier, bool>((ref) {
  final authService = ref.watch(authServiceProvider);
  return AuthStateNotifier(authService, ref);
});

// Auth initialization provider - ensures auth is checked on startup
final authInitializationProvider = FutureProvider<bool>((ref) async {
  final authService = ref.watch(authServiceProvider);
  final isLoggedIn = authService.isLoggedIn();

  // Update the auth state provider through its notifier
  try {
    ref.read(authStateProvider.notifier).setAuthState(isLoggedIn);
  } catch (e) {
    print('Error updating auth state: $e');
  }

  return isLoggedIn;
});

// Current User Provider - Family allows refresh
final currentUserProvider = FutureProvider.autoDispose<UserModel?>((ref) async {
  final authService = ref.watch(authServiceProvider);
  final user = await authService.getCurrentUser();
  print('👤 Current user loaded: ${user?.email ?? 'None'}');
  return user;
});

// Login Loading Provider
final loginLoadingProvider = StateProvider<bool>((ref) => false);

// Chat Messages Provider
final chatMessagesProvider =
    StateNotifierProvider<ChatMessagesNotifier, List<dynamic>>((ref) {
  return ChatMessagesNotifier();
});

// Chat Loading Provider
final chatLoadingProvider = StateProvider<bool>((ref) => false);

// Chat History Provider
final chatHistoryProvider = FutureProvider<List>((ref) async {
  final chatService = ref.watch(chatServiceProvider);
  return chatService.getChatHistory();
});

class AuthStateNotifier extends StateNotifier<bool> {
  final AuthService _authService;
  final Ref _ref;

  AuthStateNotifier(this._authService, this._ref) : super(false);

  Future<bool> login(String email, String password) async {
    print('🔐 Attempting login for: $email');
    final result = await _authService.login(email: email, password: password);
    state = result['success'] == true;
    print('🔐 Login result: ${state ? 'SUCCESS ✅' : 'FAILED ❌'}');

    if (state) {
      // Invalidate user provider to fetch fresh data
      _ref.invalidate(currentUserProvider);
      _ref.invalidate(chatHistoryProvider);
      print('👤 User cache invalidated - fetching fresh data ✅');
    }

    return state;
  }

  Future<bool> register(String email, String password, String fullName) async {
    print('🔐 Attempting registration for: $email');
    final result = await _authService.register(
      email: email,
      password: password,
      fullName: fullName,
    );
    state = result['success'] == true;
    print('🔐 Registration result: ${state ? 'SUCCESS ✅' : 'FAILED ❌'}');

    if (state) {
      // Invalidate user provider to fetch fresh data for new user
      _ref.invalidate(currentUserProvider);
      _ref.invalidate(chatHistoryProvider);
      print('👤 User cache invalidated - new user data loaded ✅');
    }

    return state;
  }

  Future<void> logout() async {
    print('🔐 User logging out...');
    try {
      await _authService.logout();
      state = false;

      // Clear all user-related data
      _ref.invalidate(currentUserProvider);
      _ref.invalidate(chatMessagesProvider);
      _ref.invalidate(chatHistoryProvider);
      _ref.read(chatMessagesProvider.notifier).clearMessages();

      print('🔐 User logged out ✅ - All data cleared');
    } catch (e) {
      print('❌ Error during logout: $e');
      rethrow;
    }
  }

  void setAuthState(bool value) {
    print('🔐 Setting auth state to: $value');
    state = value;
  }
}

class ChatMessagesNotifier extends StateNotifier<List<dynamic>> {
  ChatMessagesNotifier() : super([]);

  void addUserMessage(String text) {
    state = [
      ...state,
      {'isUser': true, 'text': text, 'timestamp': DateTime.now()},
    ];
  }

  void addBotMessage({
    required String text,
    List<String>? sources,
    double? confidence,
  }) {
    state = [
      ...state,
      {
        'isUser': false,
        'text': text,
        'timestamp': DateTime.now(),
        'sources': sources,
        'confidence': confidence,
      },
    ];
  }

  void clearMessages() {
    state = [];
  }
}
