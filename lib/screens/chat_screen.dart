import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../config/app_colors.dart';
import '../config/animations.dart';
import '../models/chat_models.dart';
import '../providers/providers.dart';
import '../widgets/chat_bubble.dart';
import '../widgets/chat_input_field.dart';

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _messageController = TextEditingController();
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: AnimationDuration.normal,
        curve: Curves.easeOutCubic,
      );
    }
  }

  Future<void> _handleSendMessage() async {
    final message = _messageController.text.trim();
    if (message.isEmpty) return;

    _messageController.clear();

    final chatMessagesNotifier = ref.read(chatMessagesProvider.notifier);
    final chatService = ref.read(chatServiceProvider);

    // Add user message
    chatMessagesNotifier.addUserMessage(message);
    _scrollToBottom();

    try {
      ref.read(chatLoadingProvider.notifier).state = true;
      
      // Show loading message
      print('⏳ Sending question to backend...');

      // Ask the question
      final response = await chatService.askQuestion(message);

      if (response != null) {
        // Clean markdown formatting from answer (remove stars)
        final cleanAnswer = response.answer
            .replaceAll('**', '')
            .replaceAll('*', '')
            .replaceAll('• ', '→ ');
        
        // Add bot message with confidence only (no sources)
        chatMessagesNotifier.addBotMessage(
          text: cleanAnswer,
          sources: [],
          confidence: response.confidenceScore,
        );
      } else {
        // Show error message if response is null
        chatMessagesNotifier.addBotMessage(
          text: '⚠️ Unable to get answer. Backend may still be processing your question.\n\nPlease try:\n1. Check your internet connection\n2. Try again in a moment\n3. Ask a simpler question',
          sources: [],
          confidence: 0,
        );
      }

      _scrollToBottom();
    } catch (e) {
      print('❌ SEND MESSAGE ERROR: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: AppColors.error,
          duration: const Duration(seconds: 5),
        ),
      );
    } finally {
      ref.read(chatLoadingProvider.notifier).state = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(currentUserProvider);
    final chatMessages = ref.watch(chatMessagesProvider);
    final isLoading = ref.watch(chatLoadingProvider);

    return Scaffold(
      appBar: AppBar(
        title: currentUser.when(
          data: (user) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'CampusGPT',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              if (user != null)
                Text(
                  'Hello, ${user.fullName}',
                  style: Theme.of(
                    context,
                  ).textTheme.labelSmall?.copyWith(color: AppColors.textMedium),
                ),
            ],
          ),
          loading: () => const Text('Loading...'),
          error: (err, _) => Text('Error: $err'),
        ),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textDark,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).pushNamed('/history');
            },
            icon: const Icon(Icons.history),
            tooltip: 'Chat History',
          ),
          PopupMenuButton(
            itemBuilder: (context) => [
              PopupMenuItem(
                child: const Row(
                  children: [
                    Icon(Icons.person, size: 20),
                    SizedBox(width: 12),
                    Text('Profile'),
                  ],
                ),
                onTap: () {
                  Navigator.of(context).pushNamed('/profile');
                },
              ),
              PopupMenuItem(
                child: const Row(
                  children: [
                    Icon(Icons.logout, size: 20),
                    SizedBox(width: 12),
                    Text('Logout'),
                  ],
                ),
                onTap: () {
                  ref.read(authStateProvider.notifier).logout();
                  context.go('/login');
                },
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Chat Messages
          Expanded(
            child: chatMessages.isEmpty
                ? _buildEmptyState(context)
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    itemCount: chatMessages.length,
                    itemBuilder: (context, index) {
                      final message = chatMessages[index];
                      if (message is Map<String, dynamic>) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.md),
                          child: ChatBubble(
                            message: message['text'] ?? '',
                            isUser: message['isUser'] ?? false,
                            timestamp: message['timestamp'] ?? DateTime.now(),
                            sources: (message['isUser'] == false)
                                ? message['sources'] as List<String>?
                                : null,
                            confidence: (message['isUser'] == false)
                                ? message['confidence'] as double?
                                : null,
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
          ),
          // Loading indicator
          if (isLoading)
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Row(
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Text(
                    'CampusGPT is thinking...',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textMedium,
                    ),
                  ),
                ],
              ),
            ),
          // Input Field
          ChatInputField(
            controller: _messageController,
            onSendPressed: _handleSendMessage,
            isLoading: isLoading,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(colors: AppColors.gradient),
            ),
            child: const Icon(
              Icons.school_rounded,
              size: 60,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Text(
            'Welcome to CampusGPT',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Ask me anything about your course materials',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppColors.textMedium),
          ),
          const SizedBox(height: AppSpacing.lg),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
            child: Text(
              'I can help you understand complex topics, answer questions, and provide insights from your course documents.',
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.labelMedium?.copyWith(color: AppColors.textLight),
            ),
          ),
        ],
      ),
    );
  }
}
