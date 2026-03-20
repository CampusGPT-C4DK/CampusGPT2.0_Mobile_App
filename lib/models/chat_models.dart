class ChatResponse {
  final String answer;
  final List<Source> sources;
  final double confidenceScore;
  final String confidenceLabel;
  final int responseTimeMs;

  ChatResponse({
    required this.answer,
    required this.sources,
    required this.confidenceScore,
    required this.confidenceLabel,
    required this.responseTimeMs,
  });

  factory ChatResponse.fromJson(Map<String, dynamic> json) {
    print('🔍 PARSING ChatResponse from: ${json.keys.toList()}');
    print('🔍 Full response: $json');

    // Extract answer
    final answer = json['answer'] ?? '';
    print('✅ Answer extracted: ${answer.substring(0, 50)}...');

    // Extract sources - handle multiple possible formats
    List<Source> sources = [];

    // Try 'sources' field first
    if (json['sources'] != null && json['sources'] is List) {
      sources = (json['sources'] as List)
          .map((s) => Source.fromJson(s as Map<String, dynamic>))
          .toList();
      print(
          '✅ Sources extracted from sources field: ${sources.length} sources');
    }
    // Try 'retrieved_chunks' field (backend format)
    else if (json['retrieved_chunks'] != null) {
      var chunks = json['retrieved_chunks'];
      if (chunks is String) {
        try {
          // Parse JSON string
          chunks = chunks.replaceAll("'", '"');
          print(
              '🔍 Retrieved chunks as string: ${chunks.substring(0, 100)}...');
        } catch (e) {
          print('⚠️ Could not parse retrieved_chunks: $e');
        }
      }
      if (chunks is List) {
        sources = chunks
            .map((s) {
              if (s is Map<String, dynamic>) {
                return Source.fromJson(s);
              }
              return null;
            })
            .whereType<Source>()
            .toList();
        print(
            '✅ Sources extracted from retrieved_chunks: ${sources.length} sources');
      }
    } else {
      print('⚠️ No sources found in response');
    }

    // Extract confidence score
    final confidenceScore =
        (json['confidence_score'] as num?)?.toDouble() ?? 0.0;
    print('✅ Confidence score: $confidenceScore');

    return ChatResponse(
      answer: answer,
      sources: sources,
      confidenceScore: confidenceScore,
      confidenceLabel: json['confidence_label'] ?? 'Unknown',
      responseTimeMs: (json['response_time_ms'] as num?)?.toInt() ?? 0,
    );
  }
}

class Source {
  final String id;
  final String documentName;
  final String chunkContent;
  final double relevanceScore;

  Source({
    required this.id,
    required this.documentName,
    required this.chunkContent,
    required this.relevanceScore,
  });

  factory Source.fromJson(Map<String, dynamic> json) {
    print('🔍 Parsing Source: ${json.keys.toList()}');

    // Handle different field names from backend
    final id = json['id'] ?? json['chunk_id'] ?? json['document_id'] ?? '';

    final documentName = json['document_name'] ?? json['title'] ?? 'Document';

    final chunkContent = json['chunk_content'] ??
        json['content'] ??
        json['content_preview'] ??
        '';

    final relevanceScore = (json['relevance_score'] as num? ??
            json['importance_score'] as num? ??
            0)
        .toDouble();

    print('✅ Source parsed: id=$id, name=$documentName, score=$relevanceScore');

    return Source(
      id: id,
      documentName: documentName,
      chunkContent: chunkContent,
      relevanceScore: relevanceScore,
    );
  }
}

class ChatHistory {
  final String id;
  final String question;
  final String answer;
  final double confidenceScore;
  final int responseTimeMs;
  final DateTime createdAt;

  ChatHistory({
    required this.id,
    required this.question,
    required this.answer,
    required this.confidenceScore,
    required this.responseTimeMs,
    required this.createdAt,
  });

  factory ChatHistory.fromJson(Map<String, dynamic> json) {
    return ChatHistory(
      id: json['id'] ?? '',
      question: json['question'] ?? '',
      answer: json['answer'] ?? '',
      confidenceScore: (json['confidence_score'] as num?)?.toDouble() ?? 0.0,
      responseTimeMs: json['response_time_ms'] ?? 0,
      createdAt: DateTime.parse(
        json['created_at'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }
}

class ChatMessage {
  final String id;
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final List<String>? sources;
  final double? confidence;

  ChatMessage({
    required this.id,
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.sources,
    this.confidence,
  });
}
