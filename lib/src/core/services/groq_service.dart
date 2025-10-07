import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:groq/groq.dart';

/// Service for interacting with Groq AI API
class GroqService {
  late final Groq _groq;
  static const String _defaultModel = 'llama-3.3-70b-versatile';

  GroqService() {
    final apiKey = dotenv.env['GROQ_API_KEY'];
    if (apiKey == null || apiKey.isEmpty || apiKey == 'your_groq_api_key_here') {
      throw Exception(
        'GROQ_API_KEY not found in .env file. Please add your Groq API key.',
      );
    }
    _groq = Groq(
      apiKey: apiKey,
      model: _defaultModel,
    );
  }

  /// Send a chat message to Groq and get a response
  Future<String> chat({
    required String prompt,
    String? systemPrompt,
  }) async {
    try {
      _groq.startChat();
      
      if (systemPrompt != null && systemPrompt.isNotEmpty) {
        _groq.setCustomInstructionsWith(systemPrompt);
      }

      final response = await _groq.sendMessage(prompt);
      
      return response.choices.first.message.content;
    } catch (e) {
      if (e is GroqException) {
        throw Exception('Groq API error: ${e.message}');
      }
      throw Exception('Groq error: $e');
    }
  }

  /// Send a structured JSON response request
  Future<String> chatJson({
    required String prompt,
    String? systemPrompt,
  }) async {
    final enhancedSystemPrompt = '''
${systemPrompt ?? 'You are a helpful assistant.'}

IMPORTANT: Respond ONLY with valid JSON. Do not include any markdown formatting, code blocks, or explanatory text. Just pure JSON.
''';

    return chat(
      prompt: prompt,
      systemPrompt: enhancedSystemPrompt,
    );
  }

  /// Clear chat history
  void clearChat() {
    _groq.clearChat();
  }
}
