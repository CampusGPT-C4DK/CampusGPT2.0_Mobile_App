import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../config/app_colors.dart';
import '../config/animations.dart';
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

    // ✅ CHECK: Require user to be logged in
    final authService = ref.read(authServiceProvider);
    if (!authService.isLoggedIn()) {
      print('🔐 User not logged in, redirecting to login');
      _messageController.clear(); // Clear the input field

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            '🔐 Please log in first to ask questions',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 3),
          action: SnackBarAction(
            label: 'LOGIN',
            textColor: Colors.white,
            onPressed: () {
              context.go('/login');
            },
          ),
        ),
      );
      return;
    }

    _messageController.clear();

    final chatMessagesNotifier = ref.read(chatMessagesProvider.notifier);
    final chatService = ref.read(chatServiceProvider);

    // Add user message
    chatMessagesNotifier.addUserMessage(message);
    _scrollToBottom();

    try {
      ref.read(chatLoadingProvider.notifier).state = true;
      final response = await chatService.askQuestion(message);

      if (response != null) {
        final cleanAnswer = response.answer
            .replaceAll('**', '')
            .replaceAll('*', '')
            .replaceAll('• ', '→ ');

        chatMessagesNotifier.addBotMessage(
          text: cleanAnswer,
          sources: [],
          confidence: response.confidenceScore,
        );
      } else {
        chatMessagesNotifier.addBotMessage(
          text:
              '⚠️ Unable to get answer. Backend may still be processing your question.',
          sources: [],
          confidence: 0,
        );
      }

      _scrollToBottom();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text('Error: $e', style: const TextStyle(color: Colors.white)),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
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

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && context.mounted) {
          context.pop();
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.bgDark, // Light grey/white
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          flexibleSpace: ClipRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.85),
                  border: const Border(
                      bottom: BorderSide(color: AppColors.border, width: 0.5)),
                ),
              ),
            ),
          ),
          iconTheme: const IconThemeData(color: AppColors.textDark),
          title: currentUser.when(
            data: (user) => Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.school_rounded,
                      color: AppColors.primary, size: 20),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'AI Assistant',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: AppColors.textDark,
                          ),
                    ),
                  ],
                ),
              ],
            ),
            loading: () => const Text('Loading...',
                style: TextStyle(color: AppColors.textDark)),
            error: (err, stack) =>
                const Text('Chat', style: TextStyle(color: AppColors.textDark)),
          ),
          actions: [
            IconButton(
              onPressed: () {
                if (context.mounted)
                  Future.microtask(() => context.push('/history'));
              },
              icon:
                  const Icon(Icons.history_rounded, color: AppColors.textDark),
            ),
          ],
        ),
        body: Column(
          children: [
            SizedBox(
                height: MediaQuery.of(context).padding.top +
                    56), // Account for AppBar
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
                            padding:
                                const EdgeInsets.only(bottom: AppSpacing.md),
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
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.border),
                      boxShadow: [
                        BoxShadow(
                            color: AppColors.shadowColor,
                            blurRadius: 10,
                            offset: const Offset(0, 4))
                      ]),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                                AppColors.primary)),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Text(
                        'Generating response...',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.primaryDark,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ],
                  ),
                ),
              ),
            // Input Field wrapped with aesthetic container
            Container(
              decoration: const BoxDecoration(
                  color: Colors.white,
                  border: Border(
                      top: BorderSide(color: AppColors.border, width: 1)),
                  boxShadow: [
                    BoxShadow(
                        color: AppColors.shadowColor,
                        blurRadius: 10,
                        offset: Offset(0, -4))
                  ]),
              child: ChatInputField(
                controller: _messageController,
                onSendPressed: _handleSendMessage,
                isLoading: isLoading,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primary.withOpacity(0.05),
              border: Border.all(
                  color: AppColors.primary.withOpacity(0.1), width: 2),
            ),
            child: const Icon(Icons.menu_book_rounded,
                size: 64, color: AppColors.primary),
          ),
          const SizedBox(height: AppSpacing.xl),
          Text(
            'How can I help you today?',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
                color: AppColors.textDark,
                letterSpacing: -0.5),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Ask me questions about campus resources,\ncareer paths, or university events.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textMedium,
                height: 1.5,
                fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}
