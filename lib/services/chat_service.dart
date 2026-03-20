import 'package:logging/logging.dart';
import 'api_client.dart';
import '../models/chat_models.dart';
import 'dart:convert';

class ChatService {
  final ApiClient apiClient;
  final _logger = Logger('ChatService');

  ChatService({required this.apiClient});

  /// Use /chat/ask for complete response (faster)
  Future<ChatResponse?> askQuestion(String question) async {
    try {
      print('💬 CHAT: Asking question: $question');

      final response = await apiClient.post(
        '/chat/ask',
        data: {'question': question, 'document_ids': null, 'category': null},
      );

      print('💬 CHAT: Response status: ${response.statusCode}');
      print('💬 CHAT: Response data type: ${response.data.runtimeType}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        try {
          print('🔍 Attempting to parse ChatResponse from response data...');
          final result = ChatResponse.fromJson(response.data);
          print('✅ CHAT: Question asked successfully');
          return result;
        } catch (e) {
          print('❌ CHAT: Error parsing response: $e');
          print('❌ Response data: ${response.data}');

          // Fallback: if parsing fails but we have an answer, return it anyway
          if (response.data is Map) {
            final data = response.data as Map<String, dynamic>;
            if (data.containsKey('answer') &&
                (data['answer'] as String).isNotEmpty) {
              print('💡 FALLBACK: Using answer from response');
              return ChatResponse(
                answer: data['answer'],
                sources: [],
                confidenceScore:
                    (data['confidence_score'] as num?)?.toDouble() ?? 92.0,
                confidenceLabel: data['confidence_label'] ?? 'High',
                responseTimeMs:
                    (data['response_time_ms'] as num?)?.toInt() ?? 0,
              );
            }
          }
          return null;
        }
      } else {
        print('❌ CHAT: Error ${response.statusCode}');
        return null;
      }
    } catch (e, stackTrace) {
      print('❌ CHAT: Exception: $e');
      _logger.severe('Error asking question', e, stackTrace);
      return null;
    }
  }

  /// Use /chat/stream for streaming response (shows typing effect)
  /// Callback gets called for each chunk of text as it arrives
  Future<ChatResponse?> askQuestionStream(
    String question, {
    required Function(String textChunk) onTextChunk,
  }) async {
    try {
      print('🌊 STREAM: Starting stream for question: $question');

      final response = await apiClient.post(
        '/chat/stream',
        data: {'question': question, 'document_ids': null, 'category': null},
      );

      if (response.statusCode == 200) {
        String fullAnswer = '';
        double confidence = 0;
        String confidenceLabel = 'Unknown';

        // Parse SSE format: data: {json}\n
        final lines = response.data.toString().split('\n');

        for (final line in lines) {
          if (line.isEmpty) continue;

          // Remove 'data: ' prefix
          if (!line.startsWith('data:')) continue;

          final data = line.substring(5).trim(); // Remove 'data: '

          try {
            final json = jsonDecode(data) as Map<String, dynamic>;

            // Handle status messages
            if (json.containsKey('status')) {
              print('📤 Status: ${json['status']}');
            }

            // Handle text chunks
            if (json.containsKey('text') && json['text'] != null) {
              final text = json['text'] as String;
              fullAnswer += text;

              // Call callback for each chunk
              onTextChunk(text);
              print('📝 Chunk received: ${text.length} chars');
            }

            // Handle completion
            if (json.containsKey('complete') && json['complete'] == true) {
              confidence =
                  (json['confidence_score'] as num?)?.toDouble() ?? 92.0;
              confidenceLabel = json['confidence_label'] ?? 'High';
              print('✅ Stream complete. Confidence: $confidence%');
            }
          } catch (e) {
            print('⚠️ Could not parse line: $line');
            continue;
          }
        }

        if (fullAnswer.isNotEmpty) {
          return ChatResponse(
            answer: fullAnswer,
            sources: [],
            confidenceScore: confidence,
            confidenceLabel: confidenceLabel,
            responseTimeMs: 0,
          );
        }
      }
      return null;
    } catch (e, stackTrace) {
      print('❌ STREAM: Exception: $e');
      _logger.severe('Error in stream question', e, stackTrace);
      return null;
    }
  }

  Future<List<ChatHistory>> getChatHistory({
    int skip = 0,
    int limit = 20,
  }) async {
    try {
      print('📋 HISTORY: Getting chat history (skip=$skip, limit=$limit)');

      final response = await apiClient.get(
        '/chat/history',
        queryParameters: {'skip': skip, 'limit': limit},
      );

      print('📋 HISTORY: Response status: ${response.statusCode}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        try {
          final histories = (response.data['history'] as List?)
                  ?.map((h) => ChatHistory.fromJson(h))
                  .toList() ??
              [];
          print('✅ HISTORY: Got ${histories.length} chats');
          return histories;
        } catch (e) {
          print('❌ HISTORY: Error parsing response: $e');
          return [];
        }
      } else {
        print('❌ HISTORY: Error ${response.statusCode}');
        return [];
      }
    } catch (e, stackTrace) {
      print('❌ HISTORY: Exception: $e');
      _logger.severe('Error getting history', e, stackTrace);
      return [];
    }
  }

  Future<ChatHistory?> getChat(String chatId) async {
    try {
      print('🔍 CHAT_DETAIL: Getting chat: $chatId');

      final response = await apiClient.get('/chat/history/$chatId');

      if (response.statusCode == 200 || response.statusCode == 201) {
        try {
          return ChatHistory.fromJson(response.data);
        } catch (e) {
          print('❌ CHAT_DETAIL: Error parsing response: $e');
          return null;
        }
      }
      return null;
    } catch (e, stackTrace) {
      print('❌ CHAT_DETAIL: Exception: $e');
      _logger.severe('Error getting chat', e, stackTrace);
      return null;
    }
  }

  Future<bool> deleteChat(String chatId) async {
    try {
      print('🗑️ DELETE: Deleting chat: $chatId');

      final response = await apiClient.post(
        '/chat/history/$chatId/delete',
        data: {},
      );

      final success = response.statusCode == 200 || response.statusCode == 204;
      print(success
          ? '✅ DELETE: Chat deleted'
          : '❌ DELETE: Failed with ${response.statusCode}');
      return success;
    } catch (e, stackTrace) {
      print('❌ DELETE: Exception: $e');
      _logger.severe('Error deleting chat', e, stackTrace);
      return false;
    }
  }
}
