import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:groq/groq.dart';

/// Service for interacting with Groq AI API
class GroqService {
  /// If no API key is provided in the environment, the service will run in
  /// a deterministic mock mode which returns predictable responses. This
  /// prevents tests that don't configure env vars from failing at
  /// construction time.
  GroqService() : _isMock = _initMockMode() {
    if (_isMock) {
      _groq = null;
      return;
    }

    final apiKey = dotenv.env['GROQ_API_KEY'];
    _groq = Groq(
      apiKey: apiKey!,
      model: _defaultModel,
    );
  }
  late final Groq? _groq;
  final bool _isMock;
  static const String _defaultModel = 'llama-3.3-70b-versatile';

  static bool _initMockMode() {
    try {
      // Check MOCK_AI environment variable first
      final mockAi = dotenv.env['MOCK_AI'];

      if (mockAi != null && mockAi.toLowerCase() == 'true') {
        return true;
      }

      // If MOCK_AI is explicitly set to false, use real API
      if (mockAi != null && mockAi.toLowerCase() == 'false') {
        final apiKey = dotenv.env['GROQ_API_KEY'];
        if (apiKey == null ||
            apiKey.isEmpty ||
            apiKey == 'your_groq_api_key_here') {
          throw Exception('MOCK_AI=false but GROQ_API_KEY is not configured');
        }
        return false;
      }

      // Default behavior: check API key
      final apiKey = dotenv.env['GROQ_API_KEY'];
      if (apiKey == null ||
          apiKey.isEmpty ||
          apiKey == 'your_groq_api_key_here') {
        return true;
      }
      return false;
    } catch (_) {
      // If dotenv isn't available or hasn't been loaded, default to mock mode
      return true;
    }
  }

  /// Send a chat message to Groq and get a response
  Future<String> chat({
    required String prompt,
    String? systemPrompt,
  }) async {
    if (_isMock) {
      // Deterministic mock response for tests
      return Future.value(
        'MOCK: ${prompt.substring(0, prompt.length > 80 ? 80 : prompt.length)}',
      );
    }

    try {
      _groq!.startChat();

      if (systemPrompt != null && systemPrompt.isNotEmpty) {
        _groq!.setCustomInstructionsWith(systemPrompt);
      }

      final response = await _groq!.sendMessage(prompt);

      return response.choices.first.message.content;
    } catch (e) {
      if (e is GroqException) {
        // Handle specific error types
        if (e.message.toLowerCase().contains('rate limit') ||
            e.message.toLowerCase().contains('quota') ||
            e.message.toLowerCase().contains('too many requests')) {
          throw Exception(
              'Rate limit exceeded. Please wait a moment and try again.');
        } else if (e.message.toLowerCase().contains('unauthorized') ||
            e.message.toLowerCase().contains('invalid api key')) {
          throw Exception(
              'Invalid API key. Please check your Groq API configuration.');
        } else if (e.message.toLowerCase().contains('timeout')) {
          throw Exception('Request timed out. Please try again.');
        } else {
          throw Exception('Groq API error: ${e.message}');
        }
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
    _groq?.clearChat();
  }
}
